import { useCallback, useEffect } from 'react';
import { Alert } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';

export function usePhotoPermissions() {
  const checkPermissions = useCallback(async () => {
    const [library, media] = await Promise.all([
      ImagePicker.getMediaLibraryPermissionsAsync(),
      MediaLibrary.getPermissionsAsync(),
    ]);

    if (library.status === 'denied' || media.status === 'denied') {
      Alert.alert(
        'Permissions Required',
        'This app needs access to your media library to function properly.',
      );
    }
  }, []);

  useEffect(() => {
    void checkPermissions();
  }, [checkPermissions]);

  const requestSavePermission = useCallback(async (): Promise<boolean> => {
    const current = await MediaLibrary.getPermissionsAsync();
    if (current.status === 'granted') return true;

    if (current.canAskAgain) {
      const next = await MediaLibrary.requestPermissionsAsync();
      if (next.status === 'granted') return true;
    }

    Alert.alert(
      'Permission Required',
      'Please grant permission to save images to your camera roll.',
    );
    return false;
  }, []);

  return { requestSavePermission };
}
