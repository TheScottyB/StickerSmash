import { memo } from 'react';
import { StyleSheet, Text, TouchableOpacity } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  runOnJS,
  useAnimatedStyle,
  useSharedValue,
} from 'react-native-reanimated';

const BASE_SIZE = 40;
const MIN_SCALE = 0.5;
const MAX_SCALE = 3;

type DraggableStickerProps = {
  id: string;
  emoji: string;
  initialX: number;
  initialY: number;
  isSelected: boolean;
  onSelect: (id: string) => void;
  onDelete: (id: string) => void;
};

function DraggableStickerInner({
  id,
  emoji,
  initialX,
  initialY,
  isSelected,
  onSelect,
  onDelete,
}: DraggableStickerProps) {
  const translateX = useSharedValue(initialX);
  const translateY = useSharedValue(initialY);
  const scale = useSharedValue(1);
  const rotation = useSharedValue(0);

  const savedTranslateX = useSharedValue(initialX);
  const savedTranslateY = useSharedValue(initialY);
  const savedScale = useSharedValue(1);
  const savedRotation = useSharedValue(0);

  const select = () => onSelect(id);

  const pan = Gesture.Pan()
    .onStart(() => {
      runOnJS(select)();
    })
    .onUpdate((event) => {
      translateX.value = savedTranslateX.value + event.translationX;
      translateY.value = savedTranslateY.value + event.translationY;
    })
    .onEnd(() => {
      savedTranslateX.value = translateX.value;
      savedTranslateY.value = translateY.value;
    });

  const pinch = Gesture.Pinch()
    .onStart(() => {
      runOnJS(select)();
    })
    .onUpdate((event) => {
      const next = savedScale.value * event.scale;
      scale.value = Math.min(MAX_SCALE, Math.max(MIN_SCALE, next));
    })
    .onEnd(() => {
      savedScale.value = scale.value;
    });

  const rotate = Gesture.Rotation()
    .onStart(() => {
      runOnJS(select)();
    })
    .onUpdate((event) => {
      rotation.value = savedRotation.value + event.rotation;
    })
    .onEnd(() => {
      savedRotation.value = rotation.value;
    });

  const composed = Gesture.Simultaneous(pan, pinch, rotate);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { scale: scale.value },
      { rotate: `${rotation.value}rad` },
    ],
  }));

  return (
    <GestureDetector gesture={composed}>
      <Animated.View style={[styles.container, animatedStyle]}>
        <Text style={styles.emoji}>{emoji}</Text>
        {isSelected && (
          <TouchableOpacity
            style={styles.deleteButton}
            onPress={() => onDelete(id)}
            hitSlop={8}
          >
            <Text style={styles.deleteButtonText}>✕</Text>
          </TouchableOpacity>
        )}
      </Animated.View>
    </GestureDetector>
  );
}

export const DraggableSticker = memo(DraggableStickerInner);

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    width: BASE_SIZE,
    height: BASE_SIZE,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emoji: {
    fontSize: BASE_SIZE,
    textAlign: 'center',
    lineHeight: BASE_SIZE,
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
  },
  deleteButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
