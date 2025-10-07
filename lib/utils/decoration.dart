import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Decoration decoration = Decoration();

class Decoration {
  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;

  BorderRadius allBorderRadius(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  BorderRadius singleBorderRadius(List selectedSide, double radius) {
    List top = [1], right = [2], left = [3], bottom = [4];
    List topLR = [1, 2], topLBottomR = [1, 3], bottomLR = [3, 4], topRBottomR = [2, 4];
    List ignoreTopL = [2, 3, 4], ignoreTopR = [1, 3, 4];
    if (listEquals(selectedSide, top)) {
      selectedSide = [1, null, null, null];
    } else if (listEquals(selectedSide, right)) {
      selectedSide = [null, 2, null, null];
    } else if (listEquals(selectedSide, left)) {
      selectedSide = [null, null, 3, null];
    } else if (listEquals(selectedSide, bottom)) {
      selectedSide = [null, null, null, 4];
    } else if (listEquals(selectedSide, topLR)) {
      selectedSide = [1, 2, null, null];
    } else if (listEquals(selectedSide, bottomLR)) {
      selectedSide = [null, null, 3, 4];
    } else if (listEquals(selectedSide, topLBottomR)) {
      selectedSide = [1, null, 3, null];
    } else if (listEquals(selectedSide, topRBottomR)) {
      selectedSide = [null, 2, null, 4];
    } else if (listEquals(selectedSide, ignoreTopL)) {
      selectedSide = [null, 2, 3, 4];
    } else if (listEquals(selectedSide, ignoreTopR)) {
      selectedSide = [1, null, 3, 4];
    }
    return BorderRadius.only(
      topLeft: Radius.circular(selectedSide[0] != null ? radius : 0),
      topRight: Radius.circular(selectedSide[1] != null ? radius : 0),
      bottomLeft: Radius.circular(selectedSide[2] != null ? radius : 0),
      bottomRight: Radius.circular(selectedSide[3] != null ? radius : 0),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date not available';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inSeconds < 60) {
        return 'Now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}
