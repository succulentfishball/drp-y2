import 'package:flutter/material.dart';
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

String date(DateTime dateTime) {
  return DateFormat.yMMMMd().format(dateTime);
}

String time(DateTime dateTime) {
  return DateFormat('jm').format(dateTime);
}
