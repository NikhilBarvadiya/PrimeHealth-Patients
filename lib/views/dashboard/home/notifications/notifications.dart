import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/notification_model.dart';
import 'package:prime_health_patients/views/dashboard/home/notifications/notifications_ctrl.dart';

class Notifications extends StatelessWidget {
  Notifications({super.key});

  final NotificationsCtrl ctrl = Get.put(NotificationsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Obx(() => Text('${ctrl.unreadCount.value} unread messages', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
              ],
            ),
          ),
          Obx(() {
            if (ctrl.isLoading.value) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                ),
              );
            }
            return ctrl.notifications.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final notification = ctrl.notifications[index];
                        return _buildNotificationCard(notification);
                      }, childCount: ctrl.notifications.length),
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(_formatTime(notification.createdAt), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
          child: Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey[300]),
        ),
        const SizedBox(height: 24),
        Text(
          'No Notifications',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You\'re all caught up! Check back later for new updates.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => ctrl.fetchNotifications(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Refresh',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      case 'system':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'appointment':
        return Color(0xFF10B981);
      case 'payment':
        return Color(0xFFF59E0B);
      case 'reminder':
        return Color(0xFF2563EB);
      case 'system':
        return Color(0xFF8B5CF6);
      default:
        return Color(0xFF2563EB);
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
