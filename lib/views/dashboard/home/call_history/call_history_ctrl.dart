import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/call_log_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class CallHistoryCtrl extends GetxController {
  final isLoading = false.obs, isLoadingMore = false.obs, hasMore = true.obs;
  final calls = <CallLogModel>[].obs, filteredCalls = <CallLogModel>[].obs;
  final selectedStatus = 'all'.obs, selectedDirection = 'all'.obs;
  final currentPage = 1.obs;
  final limit = 10;

  AuthService get authService => Get.find<AuthService>();

  final statusFilters = [
    {'key': 'all', 'label': 'All Calls'},
    {'key': 'calling', 'label': 'Calling'},
    {'key': 'accepted', 'label': 'Accepted'},
    {'key': 'ended', 'label': 'Completed'},
    {'key': 'rejected', 'label': 'Rejected'},
  ];

  final directionFilters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'incoming', 'label': 'Incoming'},
    {'key': 'outgoing', 'label': 'Outgoing'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadCalls(initial: true);
  }

  Future<void> loadCalls({bool initial = false}) async {
    if (initial) {
      isLoading(true);
      currentPage.value = 1;
      hasMore.value = true;
    } else if (!hasMore.value || isLoadingMore.value) {
      return;
    } else {
      isLoadingMore(true);
    }

    try {
      final Map<String, dynamic> payload = {'page': currentPage.value, 'limit': limit, if (selectedStatus.value != 'all') 'status': selectedStatus.value};
      final response = await authService.getCalls(payload);
      if (response != null) {
        final List<dynamic> callList = response['docs'] ?? [];
        final int totalDocs = int.tryParse(response['totalDocs'].toString()) ?? 0;
        final newCalls = callList.map((e) => CallLogModel.fromJson(e)).toList();
        if (initial) {
          calls.assignAll(newCalls);
        } else {
          calls.addAll(newCalls);
        }
        _applyDirectionFilter();
        hasMore.value = calls.length < totalDocs;
        currentPage.value++;
      }
    } catch (e) {
      toaster.error('Failed to load call history: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void _applyDirectionFilter() {
    if (selectedDirection.value == 'all') {
      filteredCalls.assignAll(calls);
    } else {
      filteredCalls.assignAll(calls.where((call) => call.direction == selectedDirection.value).toList());
    }
    update();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _resetAndReload();
  }

  void filterByDirection(String direction) {
    selectedDirection.value = direction;
    _applyDirectionFilter();
  }

  void _resetAndReload() {
    currentPage.value = 1;
    calls.clear();
    filteredCalls.clear();
    loadCalls(initial: true);
  }

  void loadMore() {
    if (hasMore.value && !isLoadingMore.value) {
      loadCalls();
    }
  }

  void refreshCalls() {
    _resetAndReload();
  }

  String formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String getCallStatusText(String status) {
    switch (status) {
      case 'calling':
        return 'Calling';
      case 'accepted':
        return 'Accepted';
      case 'ended':
        return 'Completed';
      case 'missed':
        return 'Missed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'ended':
        return Color(0xFF10B981);
      case 'accepted':
        return Color(0xFF3B82F6);
      case 'missed':
        return Color(0xFFEF4444);
      case 'rejected':
        return Color(0xFF6B7280);
      case 'calling':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData getDirectionIcon(String direction) {
    return direction == 'outgoing' ? Icons.call_made_rounded : Icons.call_received_rounded;
  }

  Color getDirectionColor(String direction) {
    return direction == 'outgoing' ? Color(0xFF10B981) : Color(0xFF3B82F6);
  }
}
