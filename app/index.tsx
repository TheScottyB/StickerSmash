import { Component, useCallback, useRef, useState, type ReactNode } from 'react';
import {
  Alert,
  LayoutChangeEvent,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { Image } from 'expo-image';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';
import { File, Paths } from 'expo-file-system';
import { captureRef } from 'react-native-view-shot';

import StickersModal from '@/components/StickersModal';
import { DraggableSticker } from '@/components/DraggableSticker';
import { usePhotoPermissions } from '@/hooks/usePhotoPermissions';
import type { Sticker } from '@/constants/stickers';

const MAX_IMAGE_SIZE = 5 * 1024 * 1024;
const MAX_IMAGE_DIMENSION = 1200;

type SelectedImage = {
  uri: string;
  width: number;
  height: number;
};

type PlacedSticker = {
  id: string;
  emoji: string;
  initialX: number;
  initialY: number;
};

class ErrorBoundary extends Component<{ children: ReactNode }, { hasError: boolean }> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('StickerSmash error:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Something went wrong!</Text>
          <TouchableOpacity
            style={styles.button}
            onPress={() => this.setState({ hasError: false })}
          >
            <Text style={styles.buttonText}>Try Again</Text>
          </TouchableOpacity>
        </View>
      );
    }
    return this.props.children;
  }
}

function isInAppCache(uri: string) {
  return uri.startsWith(Paths.cache.uri) || uri.startsWith(Paths.document.uri);
}

function deleteCachedFile(uri: string) {
  if (!isInAppCache(uri)) return;
  try {
    const file = new File(uri);
    if (file.exists) file.delete();
  } catch (error) {
    console.warn('Failed to delete temp file:', error);
  }
}

async function compressIfNeeded(asset: ImagePicker.ImagePickerAsset): Promise<SelectedImage> {
  const tooLarge = asset.fileSize !== undefined && asset.fileSize > MAX_IMAGE_SIZE;
  if (!tooLarge) {
    return { uri: asset.uri, width: asset.width, height: asset.height };
  }

  const context = ImageManipulator.manipulate(asset.uri);
  context.resize({ width: MAX_IMAGE_DIMENSION });
  const rendered = await context.renderAsync();
  const result = await rendered.saveAsync({ compress: 0.7, format: SaveFormat.JPEG });
  return { uri: result.uri, width: result.width, height: result.height };
}

export default function App() {
  const { requestSavePermission } = usePhotoPermissions();

  const [selectedImage, setSelectedImage] = useState<SelectedImage | null>(null);
  const [placedStickers, setPlacedStickers] = useState<PlacedSticker[]>([]);
  const [selectedStickerId, setSelectedStickerId] = useState<string | null>(null);
  const [isStickersModalVisible, setIsStickersModalVisible] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [containerLayout, setContainerLayout] = useState({ width: 0, height: 0 });

  const canvasRef = useRef<View>(null);
  const nextStickerIdRef = useRef(0);

  const pickImage = useCallback(async () => {
    if (isProcessing) return;
    setIsProcessing(true);

    try {
      const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(
          'Permission Required',
          'You need to grant camera roll permissions to use this feature.',
        );
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        quality: 1,
        exif: true,
      });

      if (result.canceled || result.assets.length === 0) return;

      const next = await compressIfNeeded(result.assets[0]);

      setSelectedImage((previous) => {
        if (previous?.uri) deleteCachedFile(previous.uri);
        return next;
      });
      setPlacedStickers([]);
      setSelectedStickerId(null);
    } catch (error) {
      Alert.alert(
        'Error',
        `Failed to pick image: ${error instanceof Error ? error.message : String(error)}`,
      );
    } finally {
      setIsProcessing(false);
    }
  }, [isProcessing]);

  const openStickersModal = useCallback(() => {
    if (selectedImage) {
      setIsStickersModalVisible(true);
    } else {
      Alert.alert('No Image Selected', 'Please select an image first before adding stickers.');
    }
  }, [selectedImage]);

  const handleSelectSticker = useCallback(
    (sticker: Sticker) => {
      const id = `sticker-${nextStickerIdRef.current++}`;
      setPlacedStickers((previous) => [
        ...previous,
        {
          id,
          emoji: sticker.emoji,
          initialX: containerLayout.width / 2 - 20,
          initialY: containerLayout.height / 2 - 20,
        },
      ]);
      setSelectedStickerId(id);
      setIsStickersModalVisible(false);
    },
    [containerLayout.width, containerLayout.height],
  );

  const handleDeleteSticker = useCallback((stickerId: string) => {
    setPlacedStickers((previous) => previous.filter((sticker) => sticker.id !== stickerId));
    setSelectedStickerId((current) => (current === stickerId ? null : current));
  }, []);

  const saveImage = useCallback(async () => {
    if (isProcessing) return;
    if (!canvasRef.current || !selectedImage) {
      Alert.alert('Error', 'No image to save.');
      return;
    }

    setIsProcessing(true);
    let tempUri = '';

    try {
      setSelectedStickerId(null);
      tempUri = await captureRef(canvasRef, { format: 'png', quality: 1 });

      const hasPermission = await requestSavePermission();
      if (!hasPermission) {
        deleteCachedFile(tempUri);
        return;
      }

      await MediaLibrary.createAssetAsync(tempUri);
      Alert.alert('Success!', 'Your sticker creation has been saved to your camera roll.');
      deleteCachedFile(tempUri);
    } catch (error) {
      if (tempUri) deleteCachedFile(tempUri);
      Alert.alert(
        'Error',
        `Failed to save image: ${error instanceof Error ? error.message : String(error)}`,
      );
    } finally {
      setIsProcessing(false);
    }
  }, [isProcessing, requestSavePermission, selectedImage]);

  const onCanvasLayout = useCallback((event: LayoutChangeEvent) => {
    const { width, height } = event.nativeEvent.layout;
    setContainerLayout({ width, height });
  }, []);

  return (
    <ErrorBoundary>
      <View style={styles.container}>
        <StatusBar style="light" />

        <View style={styles.imageContainer} onLayout={onCanvasLayout}>
          {selectedImage ? (
            <View collapsable={false} ref={canvasRef} style={styles.canvas}>
              <Image
                source={{ uri: selectedImage.uri }}
                style={styles.image}
                contentFit="contain"
                cachePolicy="memory-disk"
                transition={150}
              />
              {placedStickers.map((sticker) => (
                <DraggableSticker
                  key={sticker.id}
                  id={sticker.id}
                  emoji={sticker.emoji}
                  initialX={sticker.initialX}
                  initialY={sticker.initialY}
                  isSelected={selectedStickerId === sticker.id}
                  onSelect={setSelectedStickerId}
                  onDelete={handleDeleteSticker}
                />
              ))}
            </View>
          ) : (
            <Text style={styles.placeholderText}>Your sticker creation will appear here!</Text>
          )}
        </View>

        <View style={styles.footerContainer}>
          <TouchableOpacity
            style={[styles.button, isProcessing && styles.disabledButton]}
            onPress={pickImage}
            disabled={isProcessing}
          >
            <Text style={styles.buttonText}>Choose a photo</Text>
          </TouchableOpacity>

          {selectedImage && (
            <TouchableOpacity
              style={[styles.button, styles.stickerButton]}
              onPress={openStickersModal}
            >
              <Text style={styles.buttonText}>Add Sticker</Text>
            </TouchableOpacity>
          )}

          {selectedImage && placedStickers.length > 0 && (
            <TouchableOpacity
              style={[styles.button, styles.saveButton, isProcessing && styles.disabledButton]}
              onPress={saveImage}
              disabled={isProcessing}
            >
              <Text style={styles.buttonText}>
                {isProcessing ? 'Processing…' : 'Save Creation'}
              </Text>
            </TouchableOpacity>
          )}
        </View>

        <StickersModal
          isVisible={isStickersModalVisible}
          onClose={() => setIsStickersModalVisible(false)}
          onSelectSticker={handleSelectSticker}
        />
      </View>
    </ErrorBoundary>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#25292e',
    alignItems: 'center',
    justifyContent: 'center',
  },
  imageContainer: {
    flex: 1,
    width: '80%',
    marginTop: 58,
    borderRadius: 18,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#1f2327',
  },
  canvas: {
    position: 'relative',
    width: '100%',
    height: '100%',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  placeholderText: {
    color: '#ffffff',
    fontSize: 16,
    textAlign: 'center',
    padding: 20,
  },
  footerContainer: {
    width: '100%',
    alignItems: 'center',
    marginBottom: Platform.OS === 'ios' ? 50 : 30,
  },
  button: {
    backgroundColor: '#0e7aff',
    padding: 16,
    borderRadius: 10,
    marginTop: 16,
    minWidth: 200,
    alignItems: 'center',
  },
  disabledButton: {
    backgroundColor: '#3a3d40',
    opacity: 0.7,
  },
  stickerButton: {
    backgroundColor: '#8a57ff',
    marginTop: 12,
  },
  saveButton: {
    backgroundColor: '#4CAF50',
    marginTop: 12,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  errorContainer: {
    flex: 1,
    backgroundColor: '#25292e',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  errorText: {
    color: '#ffffff',
    fontSize: 18,
    marginBottom: 20,
    textAlign: 'center',
  },
});
