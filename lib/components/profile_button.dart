import 'package:flutter/material.dart';
import 'package:vehicle_rental/utils/colors.dart';

class ProfileButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const ProfileButton({
    required this.icon,
    required this.title,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 25,
                  color: isHovered ? primaryButton : gray,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isHovered ? primaryButton : null,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_right_outlined,
              color: isHovered ? primaryButton : gray,
            ),
          ],
        ),
      ),
    );
  }
}