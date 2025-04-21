# StickerSmash-Ultima Design Document

## Overview

StickerSmash-Ultima is a significant upgrade to the existing StickerSmash app, introducing powerful features for advanced sticker creation and image editing. This design document outlines the architecture, features, and implementation details for this enhanced application.

## Core Enhancements

1. **Multi-layer Support**: Introduce a layer system for managing stickers and image components
2. **Advanced Transformations**: Enhanced controls for position, scale, rotation, opacity, and blend modes
3. **Image Editing**: Basic image adjustments, filters, and background removal
4. **Extended Sticker Library**: Categorized stickers with search functionality and custom uploads
5. **History Management**: Robust undo/redo system for all operations
6. **Enhanced Export Options**: Multiple formats, quality settings, and sharing capabilities

## Architecture

### Directory Structure

```
app/
  components/
    stickers/
      StickerPicker.tsx        // Enhanced sticker selection with categories
      StickerEditor.tsx        // Advanced sticker transformation controls
      CustomStickerUpload.tsx  // Custom sticker upload component
      LayerManager.tsx         // Sticker layer management
    image/
      ImageEditor.tsx          // Basic image editing controls
      FilterPanel.tsx          // Image and sticker filters
      BackgroundRemover.tsx    // Background removal tool
    ui/
      HistoryPanel.tsx         // Undo/Redo history
      Toolbar.tsx              // Quick action toolbar
      TransformControls.tsx    // Advanced transformation UI
    modals/
      CategoryModal.tsx        // Sticker category selection
      ExportModal.tsx          // Enhanced export options
    
  hooks/
    useHistory.ts             // Undo/Redo functionality
    useTransform.ts           // Advanced transformation logic
    useImageProcessing.ts     // Image processing features
    useGestures.ts            // Enhanced gesture handling
    
  utils/
    imageProcessing.ts        // Image manipulation utilities
    stickerManagement.ts      // Sticker handling utilities
    gestureCalculations.ts    // Advanced gesture calculations
    fileManagement.ts         // File handling utilities

  types/
    stickers.ts              // Enhanced sticker type definitions
    transforms.ts            // Transform type definitions
    history.ts               // History action types
    filters.ts               // Filter type definitions

  constants/
    categories.ts            // Sticker categories
    filters.ts               // Filter presets
    gestures.ts              // Gesture configurations
    styles.ts                // Shared styles
```

## Data Models

### Enhanced Sticker System

```typescript
// types/stickers.ts
export type StickerType = 'emoji' | 'custom' | 'preset';
export type BlendMode = 'normal' | 'multiply' | 'screen' | 'overlay' | 'darken' | 'lighten';

export interface StickerItem {
  id: string;
  type: StickerType;
  source: string;
  category: string;
  metadata?: {
    tags: string[];
    creator?: string;
    createdAt: Date;
  };
}

export interface StickerLayer {
  id: string;
  sticker: StickerItem;
  transform: Transform;
  filters: Filter[];
  visible: boolean;
  locked: boolean;
}

export interface ImageLayer {
  id: string;
  uri: string;
  transform: Transform;
  filters: Filter[];
  adjustments: ImageAdjustments;
  visible: boolean;
  locked: boolean;
}

export type Layer = StickerLayer | ImageLayer;
```

### Advanced Transformations

```typescript
// types/transforms.ts
export interface Transform {
  position: { x: number; y: number };
  scale: number;
  rotation: number;
  skew: { x: number; y: number };
  opacity: number;
  blendMode: BlendMode;
}

export interface Gesture {
  type: 'drag' | 'pinch' | 'rotate' | 'multi';
  touches: Touch[];
  delta: {
    x?: number;
    y?: number;
    scale?: number;
    rotation?: number;
  };
}
```

### Image Processing

```typescript
// types/filters.ts
export interface Filter {
  id: string;
  name: string;
  type: 'preset' | 'custom';
  parameters: Record<string, number>;
}

export interface ImageAdjustments {
  brightness: number;
  contrast: number;
  saturation: number;
  hue: number;
  temperature: number;
  sharpness: number;
}
```

### History Management

```typescript
// types/history.ts
export type ActionType = 
  | 'ADD_LAYER'
  | 'REMOVE_LAYER'
  | 'TRANSFORM_LAYER'
  | 'APPLY_FILTER'
  | 'ADJUST_IMAGE'
  | 'REORDER_LAYERS'
  | 'TOGGLE_VISIBILITY'
  | 'TOGGLE_LOCK';

export interface HistoryAction {
  type: ActionType;
  layerId?: string;
  payload: any;
  timestamp: number;
}

export interface AppState {
  layers: Layer[];
  activeLayerId: string | null;
  imageAdjustments: ImageAdjustments;
}
```

## Key Features Implementation

### History Management

```typescript
// hooks/useHistory.ts
export const useHistory = <T>(initialState: T) => {
  const [current, setCurrent] = useState<T>(initialState);
  const [history, setHistory] = useState<T[]>([initialState]);
  const [pointer, setPointer] = useState(0);

  const undo = useCallback(() => {
    if (pointer > 0) {
      setPointer(p => p - 1);
      setCurrent(history[pointer - 1]);
    }
  }, [pointer, history]);

  const redo = useCallback(() => {
    if (pointer < history.length - 1) {
      setPointer(p => p + 1);
      setCurrent(history[pointer + 1]);
    }
  }, [pointer, history]);

  const pushState = useCallback((newState: T) => {
    // Remove any future states that would be lost by a new action
    const newHistory = [...history.slice(0, pointer + 1), newState];
    setHistory(newHistory);
    setPointer(newHistory.length - 1);
    setCurrent(newState);
  }, [history, pointer]);

  return { current, setCurrent, undo, redo, pushState, canUndo: pointer > 0, canRedo: pointer < history.length - 1 };
};
```

### Advanced Transform Control

```typescript
// hooks/useTransform.ts
export const useTransform = (initialTransform: Transform) => {
  const [transform, setTransform] = useState<Transform>(initialTransform);
  
  const handleMultiTouch = useCallback((touches: Touch[]) => {
    if (touches.length < 2) return;
    
    // Calculate distance between touches for scaling
    const currentDistance = getDistance(touches);
    const initialDistance = useRef(currentDistance).current;
    const scale = currentDistance / initialDistance;
    
    // Calculate angle between touches for rotation
    const currentAngle = getAngle(touches);
    const initialAngle = useRef(currentAngle).current;
    const rotation = currentAngle - initialAngle;
    
    // Update transform with new values
    setTransform(prev => ({
      ...prev,
      scale: prev.scale * scale,
      rotation: prev.rotation + rotation,
    }));
  }, []);

  const updatePosition = useCallback((dx: number, dy: number) => {
    setTransform(prev => ({
      ...prev,
      position: {
        x: prev.position.x + dx,
        y: prev.position.y + dy,
      },
    }));
  }, []);
  
  const updateOpacity = useCallback((value: number) => {
    setTransform(prev => ({
      ...prev,
      opacity: Math.max(0, Math.min(1, value)),
    }));
  }, []);
  
  const updateBlendMode = useCallback((mode: BlendMode) => {
    setTransform(prev => ({
      ...prev,
      blendMode: mode,
    }));
  }, []);

  return { 
    transform, 
    setTransform, 
    handleMultiTouch, 
    updatePosition, 
    updateOpacity,
    updateBlendMode
  };
};
```

### Image Processing

```typescript
// utils/imageProcessing.ts
export const ImageProcessor = {
  // Apply adjustments to image
  adjustImage: async (uri: string, adjustments: ImageAdjustments): Promise<string> => {
    try {
      const manipulateActions = [];
      
      if (adjustments.brightness !== 0) {
        manipulateActions.push({ brightness: adjustments.brightness });
      }
      
      if (adjustments.contrast !== 0) {
        manipulateActions.push({ contrast: adjustments.contrast });
      }
      
      if (adjustments.saturation !== 0) {
        manipulateActions.push({ saturation: adjustments.saturation });
      }
      
      if (manipulateActions.length === 0) {
        return uri;
      }
      
      const result = await ImageManipulator.manipulateAsync(
        uri,
        [],
        { format: ImageManipulator.SaveFormat.PNG, compress: 1, ...manipulateActions }
      );
      
      return result.uri;
    } catch (error) {
      console.error('Error adjusting image:', error);
      return uri;
    }
  },
  
  // Apply filter to image
  applyFilter: async (uri: string, filter: Filter): Promise<string> => {
    // Implementation would use different approaches based on filter type
    // For simple filters, we could use ImageManipulator
    // For more complex filters, we might need a custom solution or third-party library
    return uri; // Placeholder for actual implementation
  },
  
  // Remove background from image (would require integration with a background removal API)
  removeBackground: async (uri: string): Promise<string> => {
    try {
      // This would typically call an external API service or use a local ML model
      // For a complete implementation, consider services like Remove.bg, Cloudinary, etc.
      
      // Placeholder implementation
      return uri;
    } catch (error) {
      console.error('Error removing background:', error);
      return uri;
    }
  }
};
```

### Layer Management

```typescript
// components/stickers/LayerManager.tsx
export const LayerManager: React.FC<{
  layers: Layer[];
  activeLayerId: string | null;
  onLayerSelect: (id: string) => void;
  onLayerToggleVisibility: (id: string) => void;
  onLayerToggleLock: (id: string) => void;
  onLayerDelete: (id: string) => void;
  onLayerReorder: (orderedIds: string[]) => void;
}> = ({
  layers,
  activeLayerId,
  onLayerSelect,
  onLayerToggleVisibility,
  onLayerToggleLock,
  onLayerDelete,
  onLayerReorder
}) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Layers</Text>
      <FlatList
        data={layers}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[
              styles.layerItem,
              activeLayerId === item.id && styles.activeLayer
            ]}
            onPress={() => onLayerSelect(item.id)}
          >
            <TouchableOpacity
              onPress={() => onLayerToggleVisibility(item.id)}
            >
              <Text>{item.visible ? '👁️' : '👁️‍🗨️'}</Text>
            </TouchableOpacity>
            
            <Text style={styles.layerName}>
              {isImageLayer(item) ? 'Image' : (item as StickerLayer).sticker.type}
            </Text>
            
            <TouchableOpacity
              onPress={() => onLayerToggleLock(item.id)}
            >
              <Text>{item.locked ? '🔒' : '🔓'}</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              onPress={() => onLayerDelete(item.id)}
            >
              <Text>🗑️</Text>
            </TouchableOpacity>
          </TouchableOpacity>
        )}
      />
    </View>
  );
};
```

### Main App Component

```typescript
// app/index.tsx
export default function StickerSmashUltima() {
  // State and history management
  const [appState, setAppState] = useState<AppState>({
    layers: [],
    activeLayerId: null,
    imageAdjustments: {
      brightness: 0,
      contrast: 0,
      saturation: 0,
      hue: 0,
      temperature: 0,
      sharpness: 0
    }
  });
  
  const { current, undo, redo, pushState, canUndo, canRedo } = useHistory<AppState>(appState);
  const [mode, setMode] = useState<'transform' | 'filter' | 'adjust' | 'background'>('transform');
  const [isStickersModalVisible, setIsStickersModalVisible] = useState(false);
  const [isExportModalVisible, setIsExportModalVisible] = useState(false);
  
  // Effect to sync history state with app state
  useEffect(() => {
    setAppState(current);
  }, [current]);

  // Handle toolbar actions
  const handleToolbarAction = (action: string) => {
    switch (action) {
      case 'undo':
        undo();
        break;
      case 'redo':
        redo();
        break;
      case 'layers':
        // Toggle layers panel
        break;
      case 'stickers':
        setIsStickersModalVisible(true);
        break;
      case 'filters':
        setMode('filter');
        break;
      case 'adjust':
        setMode('adjust');
        break;
      case 'background':
        setMode('background');
        break;
      case 'export':
        setIsExportModalVisible(true);
        break;
    }
  };

  // Add new sticker
  const handleAddSticker = (sticker: StickerItem) => {
    const newLayer: StickerLayer = {
      id: `sticker-${Date.now()}`,
      sticker,
      transform: {
        position: { x: 100, y: 100 },
        scale: 1,
        rotation: 0,
        skew: { x: 0, y: 0 },
        opacity: 1,
        blendMode: 'normal'
      },
      filters: [],
      visible: true,
      locked: false
    };
    
    const newState = {
      ...appState,
      layers: [...appState.layers, newLayer],
      activeLayerId: newLayer.id
    };
    
    pushState(newState);

