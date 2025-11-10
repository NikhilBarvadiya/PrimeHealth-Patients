import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/call_log_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/decoration.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/calling_view.dart';
import 'call_history_ctrl.dart';

class CallHistory extends StatefulWidget {
  const CallHistory({super.key});

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  @override
  Widget build(BuildContext context) {
    final CallHistoryCtrl ctrl = Get.put(CallHistoryCtrl());
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll is ScrollEndNotification && scroll.metrics.pixels == scroll.metrics.maxScrollExtent) {
            ctrl.loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async => ctrl.refreshCalls(),
          child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [_buildAppBar(ctrl), _buildSearchFilter(ctrl), _buildCallList(ctrl)]),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(CallHistoryCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
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
            'Call History',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Obx(() => Text('${ctrl.filteredCalls.length} calls', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(CallHistoryCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ctrl.statusFilters.length,
                itemBuilder: (context, index) {
                  final filter = ctrl.statusFilters[index];
                  final isSelected = ctrl.selectedStatus.value == filter['key'];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter['label']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => ctrl.filterByStatus(filter['key']!)),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryTeal,
                      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary),
                      side: BorderSide(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ctrl.directionFilters.length,
                itemBuilder: (context, index) {
                  final filter = ctrl.directionFilters[index];
                  final isSelected = ctrl.selectedDirection.value == filter['key'];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter['label']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => ctrl.filterByDirection(filter['key']!)),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryTeal,
                      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary),
                      side: BorderSide(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallList(CallHistoryCtrl ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.calls.isEmpty) {
        return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }
      if (ctrl.filteredCalls.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState(ctrl));
      }
      return SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= ctrl.filteredCalls.length) {
              return _buildLoadMoreIndicator(ctrl);
            }
            final call = ctrl.filteredCalls[index];
            return _buildCallCard(call, ctrl).paddingOnly(bottom: 12);
          }, childCount: ctrl.filteredCalls.length + (ctrl.hasMore.value ? 1 : 0)),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator(CallHistoryCtrl ctrl) {
    return Obx(
      () => ctrl.isLoadingMore.value
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildCallCard(CallLogModel call, CallHistoryCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: ctrl.getDirectionColor(call.direction).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(ctrl.getDirectionIcon(call.direction), color: ctrl.getDirectionColor(call.direction), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                call.direction != 'outgoing' ? call.senderDetails.name : call.receiverDetails.name,
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (call.isVideoCall)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam_rounded, size: 12, color: AppTheme.primaryTeal),
                                    SizedBox(width: 4),
                                    Text(
                                      'Video',
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.primaryTeal),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: ctrl.getStatusColor(call.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                ctrl.getCallStatusText(call.status),
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: ctrl.getStatusColor(call.status)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                if (call.startTime != null) Text(DateFormat('MMM dd, yyyy • HH:mm').format(call.startTime!), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                if (call.endTime != null) Text(DateFormat('MMM dd, yyyy • HH:mm').format(call.endTime!), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (call.duration > 0)
                    Text(
                      ctrl.formatDuration(call.duration),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                spacing: 10.0,
                children: [
                  Expanded(
                    child: MaterialButton(
                      onPressed: () => _onCallAction(context, CallType.video, call),
                      color: Colors.green.shade300,
                      shape: RoundedRectangleBorder(borderRadius: decoration.allBorderRadius(10.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.phone_fill, color: AppTheme.textPrimary, size: 20),
                          Text("Video Call"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      onPressed: () => _onCallAction(context, CallType.voice, call),
                      color: Colors.blue.shade300,
                      shape: RoundedRectangleBorder(borderRadius: decoration.allBorderRadius(10.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_rounded, color: AppTheme.textPrimary, size: 24),
                          Text("Voice Call"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(CallHistoryCtrl ctrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.call_end_rounded, size: 120, color: AppTheme.textLight.withOpacity(0.5)),
        const SizedBox(height: 24),
        Text(
          'No Call History',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Your call history will appear here once you start making calls',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  _onCallAction(BuildContext context, CallType callType, CallLogModel call) async {
    if (call.fcmTokens.receiverFCM.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token is missing...!')));
      return;
    }
    final userData = await read(AppSession.userData);
    if (userData != null) {
      UserModel userModel = UserModel(id: userData["_id"] ?? '', fcm: userData["fcm"] ?? '', name: userData["name"] ?? 'Dr. John Smith', email: '', mobileNo: '', address: {});
      CallData callData = CallData(senderId: userModel.id, senderName: userModel.name, senderFCMToken: userModel.fcm, callType: callType, status: CallStatus.calling, channelName: call.channelName);
      if (context.mounted) {
        final receiver = AppointmentModel(id: call.receiverDetails.id.toString(), fcmToken: call.fcmTokens.receiverFCM.toString(), doctorName: call.receiverDetails.name.toString());
        CallingService().makeCall(receiver, callData);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CallingView(channelName: call.channelName, callType: callType, receiver: receiver, sender: userModel);
            },
          ),
        );
      }
    }
  }
}
