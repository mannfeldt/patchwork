import 'package:flutter/material.dart';

enum AnnouncementType { snackbar, dialog, simpleDialog }

class Announcement {
  String title;
  Widget content;
  AnnouncementType type;

  Announcement(String title, Widget content, AnnouncementType type) {
    this.title = title;
    this.content = content;
    this.type = type;
  }
}
