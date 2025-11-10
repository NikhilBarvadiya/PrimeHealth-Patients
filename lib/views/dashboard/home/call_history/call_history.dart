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
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/calling_view.dart';
import 'call_history_ctrl.dart';
import 'package:shimmer/shimmer.dart';

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
      body: RefreshIndicator(
        onRefresh: () async => ctrl.refreshCalls(),
        child: CustomScrollView(
          controller: ctrl.scrollController,
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [_buildAppBar(ctrl), _buildSearchFilter(ctrl), _buildCallList(ctrl)],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(CallHistoryCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
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
      title: Text(
        'Call History',
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildSearchFilter(CallHistoryCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Status',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            Text(
              'Filter by Direction',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
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
        return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildCallShimmerCard(), childCount: 6));
      }
      if (ctrl.filteredCalls.isEmpty && !ctrl.isLoading.value) {
        return SliverFillRemaining(child: _buildEmptyState(ctrl));
      }
      return SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (ctrl.shouldShowLoadMore(index)) {
              return _buildLoadMoreIndicator(ctrl);
            }
            if (ctrl.shouldShowEndOfList(index)) {
              return _buildEndOfList();
            }
            final call = ctrl.filteredCalls[index];
            return _buildCallCard(call, ctrl).paddingOnly(bottom: 12);
          }, childCount: ctrl.filteredCalls.length + (ctrl.hasMore.value ? 1 : 0)),
        ),
      );
    });
  }

  Widget _buildCallShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 20,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 100,
                              height: 12,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
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

  Widget _buildLoadMoreIndicator(CallHistoryCtrl ctrl) {
    return Obx(
      () => ctrl.isLoadingMore.value
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEndOfList() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('No more calls', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }

  Widget _buildCallCard(CallLogModel call, CallHistoryCtrl ctrl) {
    final isOutgoing = call.direction == 'outgoing';
    final contactName = isOutgoing ? call.receiverDetails.name : call.senderDetails.name;
    final statusColor = ctrl.getStatusColor(call.status);
    final directionColor = ctrl.getDirectionColor(call.direction);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: directionColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(ctrl.getDirectionIcon(call.direction), color: directionColor, size: 18),
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
                                contactName,
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (call.isVideoCall)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam_rounded, size: 12, color: AppTheme.primaryTeal),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Video',
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.primaryTeal),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                ctrl.getCallStatusText(call.status),
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: statusColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.circle, size: 4, color: AppTheme.textLight),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM dd, yyyy').format(call.startTime ?? DateTime.now()), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (call.duration > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ctrl.formatDuration(call.duration),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text('Duration', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeDetail('Started', call.startTime != null ? DateFormat('HH:mm').format(call.startTime!) : '--:--', Icons.access_time_rounded),
                    _buildTimeDetail('Ended', call.endTime != null ? DateFormat('HH:mm').format(call.endTime!) : '--:--', Icons.timer_off_rounded),
                    _buildTimeDetail('Type', call.isVideoCall ? 'Video' : 'Voice', call.isVideoCall ? Icons.videocam_rounded : Icons.phone_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _onCallAction(context, CallType.voice, call),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.blue.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: const Icon(CupertinoIcons.phone_fill, size: 18),
                      label: Text("Voice Call", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _onCallAction(context, CallType.video, call),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.green.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: Text("Video Call", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
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

  Widget _buildTimeDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
      String channelName = "${userModel.id}_${call.receiverDetails.id}_${DateTime.now().millisecondsSinceEpoch}";
      CallData callData = CallData(senderId: userModel.id, senderName: userModel.name, senderFCMToken: userModel.fcm, callType: callType, status: CallStatus.calling, channelName: channelName);
      if (context.mounted) {
        final receiver = AppointmentModel(id: call.receiverDetails.id.toString(), fcmToken: call.fcmTokens.receiverFCM.toString(), doctorName: call.receiverDetails.name.toString());
        CallingService().makeCall(receiver, callData);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CallingView(channelName: channelName, callType: callType, receiver: receiver, sender: userModel);
            },
          ),
        );
      }
    }
  }
}
