import 'package:flutter/material.dart';
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
      title: const Text(
        'Success',
        style: TextStyle(
          fontWeight: FontWeight.w700
        ),
      ),
      subtitle: Text(
        'Anda Berhasil $type',
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
      title: const Text(
        'Success',
        style: TextStyle(
          fontWeight: FontWeight.w700
        ),
      ),
      subtitle: Text(
        'Anda Berhasil $type',
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
        title: Text('Confirm $title'),
        content: Text('Are you sure you want to $title?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
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