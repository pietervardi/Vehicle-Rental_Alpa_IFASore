import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:vehicle_rental/utils/colors.dart';

SnackBar buildSnackBarSuccess(String type) {
  return SnackBar(
    elevation: 0,
    backgroundColor: lightGreen,
    content: ListTile(
      leading: const CircleAvatar(
        backgroundColor: green,
        child: Icon(
          Icons.sentiment_satisfied_outlined,
          color: whiteText,
          size: 30,
        ),
      ),
      title: Text(
        'message/success'.i18n(),
        style: const TextStyle(
          fontWeight: FontWeight.w700
        ),
      ),
      subtitle: Text(
        "${'message/you-succeeded'.i18n()} $type",
        style: const TextStyle(
          fontWeight: FontWeight.w600
        ),
      ),
    ),
  );
}

SnackBar buildSnackBarDanger(String type) {
  return SnackBar(
    elevation: 0,
    backgroundColor: lightRed,
    content: ListTile(
      leading: const CircleAvatar(
        backgroundColor: red,
        child: Icon(
          Icons.sentiment_dissatisfied_outlined,
          color: whiteText,
          size: 30,
        ),
      ),
      title: Text(
        'message/success'.i18n(),
        style: const TextStyle(
          fontWeight: FontWeight.w700
        ),
      ),
      subtitle: Text(
        "${'message/you-succeeded'.i18n()} $type",
        style: const TextStyle(
          fontWeight: FontWeight.w600
        ),
      ),
    ),
  );
}

void showConfirmationDialog(BuildContext context, String title, Function() onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("${'message/confirm'.i18n()} $title"),
        content: Text("${'message/are-you-sure'.i18n()} $title?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('global/cancel'.i18n()),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger(title));
            },
            child: Text(
              title,
              style: const TextStyle(
                color: red
              ),
            ),
          ),
        ],
      );
    },
  );
}