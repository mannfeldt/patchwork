import 'package:flutter/material.dart';
import 'package:patchwork/models/announcement.dart';

enum DialogAction { yes, abort }

class Dialogs {
  static void snackbar(BuildContext context, Announcement announcement) {
    String text = announcement.title;
    int duration = 2 + (text.length / 15).round();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: duration),
    ));
  }

  static void simpleAnnouncement(
    BuildContext context,
    Announcement announcement,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SimpleDialog(
              title: announcement.content,
              titlePadding: EdgeInsets.all(30.0),
            ));
      },
    );
  }

  static void announcement(
      BuildContext context, Announcement announcement) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(announcement.title),
          content: announcement.content,
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<DialogAction> yesAbortDialog(
      BuildContext context, Announcement announcement) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(announcement.title),
          content: announcement.content,
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.abort),
              child: const Text('No'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.yes),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogAction.abort;
  }
}
