import React, { useState, useRef, useEffect, useCallback, Component } from 'react';
import { 
  StyleSheet, 
  View, 
  Text, 
  Image, 
  TouchableOpacity, 
  Platform, 
  Alert,
  PanResponder,
  Animated,
  GestureResponderEvent,
  LayoutChangeEvent,
  Dimensions
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import * as ImageManipulator from 'expo-image-manipulator';
import * as FileSystem from 'expo-file-system';
import { captureRef } from 'react-native-view-shot';
import StickersModal, { Sticker } from '../components/StickersModal';

type ImageResult = {
  uri: string;
  width: number;
  height: number;
  fileSize?: number;
};

type PlacedSticker = {
  id: string;
  emoji: string;
  position: {
    x: number;
    y: number;
  };
  scale: number;
  rotation: number;
  isSelected: boolean;
};

type GestureState = {
  stickerId: string | null;
  initialDistance: number | null;
  initialRotation: number | null;
  initialTouchAngle: number | null;
  lastPosition: { x: number, y: number } | null;
};

// Maximum file size (5MB)
const MAX_IMAGE_SIZE = 5 * 1024 * 1024;

// Error boundary component to handle UI errors
class ErrorBoundary extends Component<{children: React.ReactNode}, {hasError: boolean}> {
  constructor(props: {children: React.ReactNode}) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('StickerSmash error:', error, errorInfo);
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

export default function App() {
  const [selectedImage, setSelectedImage] = useState<ImageResult | null>(null);
  const [isStickersModalVisible, setIsStickersModalVisible] = useState(false);
  const [placedStickers, setPlacedStickers] = useState<PlacedSticker[]>([]);
  const [currentStickerId, setCurrentStickerId] = useState(0);
  const [isProcessing, setIsProcessing] = useState(false);
  const [permissionStatus, setPermissionStatus] = useState<MediaLibrary.PermissionStatus>();
  
  // Ref for the image container to capture for sharing
  const imageContainerRef = useRef<View>(null);
  const [containerLayout, setContainerLayout] = useState({ width: 0, height: 0 });
  const screenDimensions = Dimensions.get('window');
  
  // Gesture handling state
  const [gestureState, setGestureState] = useState<GestureState>({
    stickerId: null,
    initialDistance: null,
    initialRotation: null,
    initialTouchAngle: null,
    lastPosition: null,
  });

  // Check permissions on mount
  useEffect(() => {
    checkPermissions();
    
    // Clean up any temporary images when component unmounts
    return () => {
      if (selectedImage?.uri) {
        deleteTempFile(selectedImage.uri).catch(console.warn);
      }
    };
  }, []);

  // Check both required permissions
  const checkPermissions = async () => {
    const libraryPermission = await ImagePicker.getMediaLibraryPermissionsAsync();
    const mediaPermission = await MediaLibrary.getPermissionsAsync();
    
    setPermissionStatus(mediaPermission.status);
    
    if (libraryPermission.status === 'denied' || mediaPermission.status === 'denied') {
      Alert.alert(
        "Permissions Required",
        "This app needs access to your media library to function properly.",
        [
          { text: "Cancel" },
          { 
            text: "Settings", 
            onPress: () => {
              // This would ideally open settings, but we'll just request again
              checkPermissions();
            }
          }
        ]
      );
    } else if (libraryPermission.status === 'limited' || mediaPermission.status === 'limited') {
      Alert.alert(
        "Limited Access",
        "You've granted limited access to your photos. Some features may be restricted.",
        [{ text: "OK" }]
      );
    }
  };

  // Delete temporary files to prevent file system clutter
  const deleteTempFile = async (uri: string) => {
    try {
      // Only delete files in app's cache directory
      if (uri.startsWith(FileSystem.cacheDirectory || '') || 
          uri.startsWith(FileSystem.documentDirectory || '')) {
        await FileSystem.deleteAsync(uri, { idempotent: true });
      }
    } catch (error) {
      console.warn('Failed to delete temp file:', error);
    }
  };

  // Check if position is within container bounds
  const isWithinBounds = useCallback((x: number, y: number) => {
    return x >= 0 && 
           x <= containerLayout.width && 
           y >= 0 && 
           y <= containerLayout.height;
  }, [containerLayout]);

  const pickImage = async () => {
    if (isProcessing) return;
    setIsProcessing(true);
    
    try {
      // Request permission to access the media library
      const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();

      if (permissionResult.granted === false) {
        Alert.alert(
          "Permission Required", 
          "You need to grant camera roll permissions to use this feature",
          [
            { text: "Cancel" },
            { 
              text: "Try Again", 
              onPress: checkPermissions
            }
          ]
        );
        return;
      }

      // Launch the image picker
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        quality: 1,
        exif: true,
      });

      // Handle the selected image
      if (!result.canceled && result.assets && result.assets.length > 0) {
        const asset = result.assets[0];
        
        // Check file size if available
        if (asset.fileSize && asset.fileSize > MAX_IMAGE_SIZE) {
          // Compress the image if it's too large
          const compressedImage = await ImageManipulator.manipulateAsync(
            asset.uri,
            [{ resize: { width: 1200 } }], // Resize to reasonable dimensions
            { compress: 0.7, format: ImageManipulator.SaveFormat.JPEG }
          );
          
          setSelectedImage({
            uri: compressedImage.uri,
            width: compressedImage.width,
            height: compressedImage.height,
            fileSize: compressedImage.size
          });
        } else {
          setSelectedImage({
            uri: asset.uri,
            width: asset.width,
            height: asset.height,
            fileSize: asset.fileSize
          });
        }
        
        // Clean up old selected image if it exists
        if (selectedImage?.uri) {
          deleteTempFile(selectedImage.uri).catch(console.warn);
        }
      }
    } catch (error) {
      Alert.alert(
        "Error", 
        "Failed to pick image: " + (error instanceof Error ? error.message : String(error))
      );
    } finally {
      setIsProcessing(false);
    }
  };

  const handleAddSticker = () => {
    if (selectedImage) {
      setIsStickersModalVisible(true);
    } else {
      Alert.alert(
        "No Image Selected", 
        "Please select an image first before adding stickers."
      );
    }
  };

  // Request save permission with better handling
  const requestSavePermission = async (): Promise<boolean> => {
    const { status, canAskAgain } = await MediaLibrary.getPermissionsAsync();
    
    if (status === 'granted') {
      return true;
    }
    
    if (status !== 'granted' && canAskAgain) {
      const { status: newStatus } = await MediaLibrary.requestPermissionsAsync();
      
      if (newStatus !== 'granted') {
        Alert.alert(
          "Permission Required",
          "Please grant permission to save images to your camera roll.",
          [
            { text: "Cancel" },
            { 
              text: "Try Again", 
              onPress: checkPermissions
            }
          ]
        );
        return false;
      }
      
      return true;
    } else if (!canAskAgain) {
      Alert.alert(
        "Permission Required",
        "Permission to save images is required. Please enable it in your device settings.",
        [{ text: "OK" }]
      );
      return false;
    }
    
    return false;
  };

  // Save the image with better error handling and race condition prevention
  const saveImage = async () => {
    if (isProcessing) return;
    if (!imageContainerRef.current || !selectedImage) {
      Alert.alert("Error", "No image to save.");
      return;
    }

    setIsProcessing(true);
    let tempUri = '';
    
    try {
      // Capture the view as an image
      tempUri = await captureRef(imageContainerRef, {
        format: 'png',
        quality: 1,
      });

      // Check permission
      const hasPermission = await requestSavePermission();
      if (!hasPermission) {
        await deleteTempFile(tempUri);
        return;
      }

      // Save to camera roll
      const asset = await MediaLibrary.createAssetAsync(tempUri);
      
      Alert.alert(
        "Success!",
        "Your sticker creation has been saved to your camera roll."
      );
      
      // Clean up the temporary file
      await deleteTempFile(tempUri);
    } catch (error) {
      if (tempUri) {
        await deleteTempFile(tempUri).catch(console.warn);
      }
      Alert.alert(
        "Error", 
        "Failed to save image: " + (error instanceof Error ? error.message : String(error))
      );
    } finally {
      setIsProcessing(false);
    }
  };

  // Handle container layout changes
  const onLayoutChange = (event: LayoutChangeEvent) => {
    const { width, height } = event.nativeEvent.layout;
    setContainerLayout({ width, height });
  };

  const handleSelectSticker = (sticker: Sticker) => {
    // Create a new placed sticker in the center of the image container
    const newSticker: PlacedSticker = {
      id: `sticker-${currentStickerId}`,
      emoji: sticker.emoji,
      position: {
        x: containerLayout.width / 2 - 20, // Center horizontally
        y: containerLayout.height / 2 - 20, // Center vertically
      },
      scale: 1.0,
      rotation: 0,
      isSelected: true,
    };

    // Deselect all other stickers
    setPlacedStickers(prev => prev.map(s => ({ ...s, isSelected: false })).concat(newSticker));
    setCurrentStickerId(prev => prev + 1);
    setIsStickersModalVisible(false);
  };

  const handleDeleteSticker = (stickerId: string) => {
    setPlacedStickers(prev => prev.filter(sticker => sticker.id !== stickerId));
  };

  const handleSelectStickerForEdit = (stickerId: string) => {
    setPlacedStickers(prev =>
      prev.map(sticker => ({
        ...sticker,
        isSelected: sticker.id === stickerId,
      }))
    );
  };

  const handleMoveSticker = (stickerId: string, moveGesture: { dx: number, dy: number }) => {
    setPlacedStickers(prev =>
      prev.map(sticker => {
        if (sticker.id === stickerId) {
          // Calculate new position
          const newX = sticker.position.x + moveGesture.dx;
          const newY = sticker.position.y + moveGesture.dy;
          
          // Ensure sticker stays within bounds with some padding
          return {
            ...sticker,
            position: {
              x: Math.max(0, Math.min(containerLayout.width - 40, newX)),
              y: Math.max(0, Math.min(containerLayout.height - 40, newY)),
            },
          };
        }
        return sticker;
      })
    );
  };

  const getDistance = (touches: { pageX: number, pageY: number }[]) => {
    if (touches.length < 2) return 0;
    return Math.sqrt(
      Math.pow(touches[0].pageX - touches[1].pageX, 2) +
      Math.pow(touches[0].pageY - touches[1].pageY, 2)
    );
  };

  const getAngle = (touches: { pageX: number, pageY: number }[]) => {
    if (touches.length < 2) return 0;
    return Math.atan2(
      touches[1].pageY - touches[0].pageY,
      touches[1].pageX - touches[0].pageX
    ) * 180 / Math.PI;
  };

  const handlePinchSticker = (stickerId: string, touches: { pageX: number, pageY: number }[]) => {
    if (touches.length < 2) return;

    const currentDistance = getDistance(touches);
    const currentAngle = getAngle(touches);

    if (gestureState.initialDistance === null || gestureState.initialRotation === null || 
        gestureState.stickerId !== stickerId) {
      // Initialize gesture
      setGestureState({
        ...gestureState,
        stickerId,
        initialDistance: currentDistance,
        initialRotation: currentAngle,
        initialTouchAngle: currentAngle,
      });
      return;
    }

    // Calculate scale change - ensure it's within safe limits
    const scaleChange = Math.min(1.25, Math.max(0.8, currentDistance / gestureState.initialDistance));
    
    // Calculate rotation change
    const rotationChange = currentAngle - (gestureState.initialTouchAngle || 0);

    setPlacedStickers(prev =>
      prev.map(sticker => {
        if (sticker.id === stickerId) {
          return {
            ...sticker,
            scale: Math.max(0.5, Math.min(3.0, sticker.scale * scaleChange)), // Limit scale between 0.5 and 3
            rotation: sticker.rotation + rotationChange,
          };
        }
        return sticker;
      })
    );

    // Update gesture state for the next frame
    setGestureState({
      ...gestureState,
      initialDistance: currentDistance,
      initialTouchAngle: currentAngle,
    });
  };

  const resetGestureState = () => {
    setGestureState({
      stickerId: null,
      initialDistance: null,
      initialRotation: null,
      initialTouchAngle: null,
      lastPosition: null,
    });
  };

  return (
    <ErrorBoundary>
      <View style={styles.container}>
        <StatusBar style="light" />
        
        <View style={styles.imageContainer} onLayout={onLayoutChange}>
          {selectedImage ? (
            <View 
              style={styles.imageWithStickersContainer} 
              ref={imageContainerRef}
            >
              <Image 
                source={{ uri: selectedImage.uri }} 
                style={styles.image} 
                resizeMode="contain"
              />
              {/* Display all placed stickers */}
              {placedStickers.map((sticker) => {
                // Create a pan responder for each sticker with multi-touch support
                const panResponder = PanResponder.create({
                  onStartShouldSetPanResponder: () => true,
                  onMoveShouldSetPanResponderCapture: () => true,
                  
                  // Handle sticker selection
                  onPanResponderGrant: (evt) => {
                    handleSelectStickerForEdit(sticker.id);
                  },
                  
                  // Handle move, pinch, and rotate gestures
                  onPanResponderMove: (evt: GestureResponderEvent, moveGesture) => {
                    const touches = evt.nativeEvent.touches;
                    
                    if (touches.length === 1) {
                      // Single touch - move the sticker
                      handleMoveSticker(sticker.id, moveGesture);
                    } else if (touches.length === 2) {
                      // Two touches - handle pinch and rotation
                      handlePinchSticker(sticker.id, [
                        { pageX: touches[0].pageX, pageY: touches[0].pageY },
                        { pageX: touches[1].pageX, pageY: touches[1].pageY }
                      ]);
                    }
                  },
                  
                  // Reset gesture state on release
                  onPanResponderRelease: () => {
                    resetGestureState();
                  },
                });

                return (
                  <View key={sticker.id} style={styles.stickerContainer}>
                    <Animated.Text
                      {...panResponder.panHandlers}
                      style={[
                        styles.placedSticker,
                        {
                          fontSize: 40 * sticker.scale,
                          left: sticker.position.x,
                          top: sticker.position.y,
                          transform: [
                            { rotate: `${sticker.rotation}deg` },
                            { scale: sticker.scale }
                          ]
                        },
                      ]}
                    >
                      {sticker.emoji}
                    </Animated.Text>
                    
                    {/* Delete button for selected stickers */}
                    {sticker.isSelected && (
                      <TouchableOpacity
                        style={styles.deleteButton}
                        onPress={() => handleDeleteSticker(sticker.id)}
                      >
                        <Text style={styles.deleteButtonText}>✕</Text>
                      </TouchableOpacity>
                    )}
                  </View>
                );
              })}
            </View>
          ) : (
            <Text style={styles.placeholderText}>
              Your sticker creation will appear here!
            </Text>
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
              onPress={handleAddSticker}
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
                {isProcessing ? 'Processing...' : 'Save Creation'}
              </Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Stickers Modal */}
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
  imageWithStickersContainer: {
    position: 'relative',
    width: '100%',
    height: '100%',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  stickerContainer: {
    position: 'absolute',
    zIndex: 10,
    width: 'auto',
    height: 'auto',
  },
  placedSticker: {
    position: 'absolute',
    zIndex: 10,
    // This makes the text not interactive to taps except for the text itself
    backgroundColor: 'transparent',
  },
  deleteButton: {
    position: 'absolute',
    top: -15,
    right: -15,
    backgroundColor: '#FF4C4C',
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 20,
  },
  deleteButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign: 'center',
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