import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';

void showCustomModalBottomSheet(BuildContext context, bool isDarkMode, String currentUserId, String reviewUserId, String reviewId, Function(String) onDeleteReview) {
  showModalBottomSheet(
    enableDrag: true,
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: Icon(
              Icons.sentiment_dissatisfied,
              color: isDarkMode ? whiteText : black,
            ),
            title: Text(
              'bottom_sheet/title'.i18n(),
              style: TextStyle(
                color: isDarkMode ? whiteText : black,
                fontSize: 18
              ),
            ),
            onTap: () {

            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.flag_outlined,
              color: isDarkMode ? whiteText : black,
            ),
            title: Text(
              'bottom_sheet/report-review'.i18n(),
              style: TextStyle(
                color: isDarkMode ? whiteText : black,
                fontSize: 18
              ),
            ),
            onTap: () {

            },
          ),
          if (currentUserId == reviewUserId)
            Column(
              children: [
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: isDarkMode ? whiteText : black,
                  ),
                  title: Text(
                    'bottom_sheet/delete-review'.i18n(),
                    style: TextStyle(
                      color: isDarkMode ? whiteText : black,
                      fontSize: 18
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showConfirmationDialog(context, 'bottom_sheet/delete-review'.i18n(), () => onDeleteReview(reviewId));
                  },
                ),
              ],
            )
        ],
      );
    },
  );
}