import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationStorageService {
  static const _key = 'fcm_notifications';
  static const _maxCount = 50;

  final _box = Get.find<GetStorage>();

  List<Map<String, dynamic>> getAll() {
    final raw = _box.read<List>(_key);
    if (raw == null) return [];
    return raw.cast<Map<String, dynamic>>();
  }

  void save(Map<String, dynamic> notif) {
    final list = getAll();
    list.insert(0, notif);
    if (list.length > _maxCount) list.removeLast();
    _box.write(_key, list);
  }

  void markRead(String id) {
    final list = getAll();
    final i = list.indexWhere((n) => n['id'] == id);
    if (i != -1) {
      list[i] = {...list[i], 'read': true};
      _box.write(_key, list);
    }
  }

  void markAllRead() {
    final list = getAll().map((n) => {...n, 'read': true}).toList();
    _box.write(_key, list);
  }

  void delete(String id) {
    final list = getAll()..removeWhere((n) => n['id'] == id);
    _box.write(_key, list);
  }

  void clearAll() => _box.remove(_key);

  int get unreadCount => getAll().where((n) => n['read'] != true).length;
}
