import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';

bool isLocalImage(String path) {
  return path.startsWith('/') || path.startsWith('file://');
}

Image getImage(String path) {
  return isLocalImage(path) ?
    Image.file(
      File(path),
      fit: BoxFit.fitWidth,
    ) :
    Image.network(
      path,
      fit: BoxFit.fitWidth,
    );
}


Image getImageFromBytes(Uint8List bytes) {
  return Image.memory(
    bytes,
    fit: BoxFit.fitWidth,
  );
}

String date(DateTime dateTime) {
  // replace with today or yesterday, and then the day of the week if it is less than 7 days
  // return DateFormat.yMMMMd().format(dateTime);
  final now = DateTime.now();
  if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
    return 'Today';
  } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
    return 'Yesterday';
  } else if (now.difference(dateTime).inDays > 0 && now.difference(dateTime).inDays < 7) {
    return DateFormat.EEEE().format(dateTime);
  } else {
    return DateFormat.yMMMMd().format(dateTime);
  }
}

String time(DateTime dateTime) {
  return DateFormat('jm').format(dateTime);
}
