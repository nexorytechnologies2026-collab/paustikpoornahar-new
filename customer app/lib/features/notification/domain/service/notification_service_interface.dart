import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/features/notification/domain/models/notification_model.dart';

abstract class NotificationServiceInterface {
  Future<List<NotificationModel>?> getList({DataSourceEnum? source});
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
}