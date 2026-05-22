import {
  Dimensions,
  FlatList,
  Modal,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { STICKERS, type Sticker } from '@/constants/stickers';

type StickersModalProps = {
  isVisible: boolean;
  onClose: () => void;
  onSelectSticker: (sticker: Sticker) => void;
};

const COLUMNS = 4;
const EMOJI_SIZE = Dimensions.get('window').width / COLUMNS - 20;

export default function StickersModal({
  isVisible,
  onClose,
  onSelectSticker,
}: StickersModalProps) {
  return (
    <Modal
      animationType="slide"
      transparent
      visible={isVisible}
      onRequestClose={onClose}
    >
      <View style={styles.centeredView}>
        <View style={styles.modalView}>
          <View style={styles.headerContainer}>
            <Text style={styles.headerText}>Choose a Sticker</Text>
            <TouchableOpacity style={styles.closeButton} onPress={onClose}>
              <Text style={styles.closeButtonText}>✕</Text>
            </TouchableOpacity>
          </View>

          <FlatList
            data={STICKERS}
            renderItem={({ item }) => (
              <TouchableOpacity
                style={styles.stickerItem}
                onPress={() => onSelectSticker(item)}
              >
                <Text style={styles.emojiText}>{item.emoji}</Text>
              </TouchableOpacity>
            )}
            keyExtractor={(item) => item.id}
            numColumns={COLUMNS}
            contentContainerStyle={styles.stickerList}
          />
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalView: {
    backgroundColor: '#2c3038',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    paddingBottom: Platform.OS === 'ios' ? 40 : 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
    maxHeight: '70%',
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  headerText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  closeButton: { padding: 8 },
  closeButtonText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold' },
  stickerList: { paddingBottom: 20 },
  stickerItem: {
    width: EMOJI_SIZE,
    height: EMOJI_SIZE,
    margin: 8,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#3d4148',
    borderRadius: 12,
  },
  emojiText: { fontSize: 32 },
});
