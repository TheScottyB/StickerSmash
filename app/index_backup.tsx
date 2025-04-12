import React, { useState, useRef } from 'react';
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
  LayoutChangeEvent
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import * as ImageManipulator from 'expo-image-manipulator';
import { captureRef } from 'react-native-view-shot';
import StickersModal, { Sticker } from '../components/StickersModal';

type ImageResult = {
  uri: string;
  width: number;
  height: number;
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

export default function App() {
  const [selectedImage, setSelectedImage] = useState<ImageResult | null>(null);
  const [isStickersModalVisible, setIsStickersModalVisible] = useState(false);
  const [placedStickers, setPlacedStickers] = useState<PlacedSticker[]>([]);
  const [currentStickerId, setCurrentStickerId] = useState(0);
  
  // Ref for the image container to capture for sharing
  const imageContainerRef = useRef<View>(null);
  const [containerLayout, setContainerLayout] = useState({ width: 0, height: 0 });
  
  // Gesture handling state
  const [gestureState, setGestureState] = useState<GestureState>({
    stickerId: null,
    initialDistance: null,
    initialRotation: null,
    initialTouchAngle: null,
    lastPosition: null,
  });

  const pickImage = async () => {
    // Request permission to access the media library
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();

    if (permissionResult.granted === false) {
      Alert.alert(
        "Permission Required", 
        "You need to grant camera roll permissions to use this feature"
      );
      return;
    }

    // Launch the image picker
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 1,
    });

    // Handle the selected image
    if (!result.canceled && result.assets && result.assets.length > 0) {
      const asset = result.assets[0];
      setSelectedImage({
        uri: asset.uri,
        width: asset.width,
        height: asset.height,
      });
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
  // Request save permission
  const requestSavePermission = async (): Promise<boolean> => {
    const { status } = await MediaLibrary.requestPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert(
        "Permission Required",
        "Please grant permission to save images to your camera roll."
      );
      return false;
    }
    return true;
  };

  // Save the image
  const saveImage = async () => {
    if (!imageContainerRef.current || !selectedImage) {
      Alert.alert("Error", "No image to save.");
      return;
    }

    try {
      // Capture the view as an image
      const uri = await captureRef(imageContainerRef, {
        format: 'png',
        quality: 1,
      });

      // Check permission
      const hasPermission = await requestSavePermission();
      if (!hasPermission) return;

      // Save to camera roll
      const asset = await MediaLibrary.createAssetAsync(uri);
      
      Alert.alert(
        "Success!",
        "Your sticker creation has been saved to your camera roll."
      );
    } catch (error) {
      Alert.alert("Error", "Failed to save image: " + (error instanceof Error ? error.message : String(error)));
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
    setPlacedStickers(placedStickers.map(s => ({ ...s, isSelected: false })).concat(newSticker));
    setCurrentStickerId(currentStickerId + 1);
    setIsStickersModalVisible(false);
  };

  const handleDeleteSticker = (stickerId: string) => {
    setPlacedStickers(placedStickers.filter(sticker => sticker.id !== stickerId));
  };

  const handleSelectStickerForEdit = (stickerId: string) => {
    setPlacedStickers(
      placedStickers.map(sticker => ({
        ...sticker,
        isSelected: sticker.id === stickerId,
      }))
    );
  };

  const handleMoveSticker = (stickerId: string, moveGesture: { dx: number, dy: number }) => {
    setPlacedStickers(
      placedStickers.map(sticker => {
        if (sticker.id === stickerId) {
          return {
            ...sticker,
            position: {
              x: sticker.position.x + moveGesture.dx,
              y: sticker.position.y + moveGesture.dy,
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

    // Calculate scale change
    const scaleChange = currentDistance / gestureState.initialDistance;
    
    // Calculate rotation change
    const rotationChange = currentAngle - (gestureState.initialTouchAngle || 0);

    setPlacedStickers(
      placedStickers.map(sticker => {
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
        <TouchableOpacity style={styles.button} onPress={pickImage}>
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
            style={[styles.button, styles.saveButton]} 
            onPress={saveImage}
          >
            <Text style={styles.buttonText}>Save Creation</Text>
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
});
