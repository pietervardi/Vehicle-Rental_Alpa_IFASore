import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';

// Form Field for Login and Register
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintName;
  final IconData? icon;
  final bool isObscureText;
  final TextInputType inputType;

  const CustomTextFormField({
    this.controller,
    this.hintName,
    this.icon,
    this.isObscureText = false,
    this.inputType = TextInputType.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isObscureText,
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "${'form_field/please-enter'.i18n()} $hintName";
          }
          if (hintName == "Email" && !validateEmail(value)) {
            return 'form_field/valid-email'.i18n();
          }
          return null;
        },
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: brown),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          prefixIcon: Icon(icon),
          hintText: "${"form_field/enter".i18n()} $hintName",
          labelText: hintName,
          fillColor: inputField,
          filled: true,
        ),
      ),
    );
  }
}

// Form Field for Change Password
class PasswordFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final bool isObscureText;

  const PasswordFormField({
    this.controller,
    this.labelText,
    this.isObscureText = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "${'form_field/please-enter'.i18n()} $labelText";
        }
        return null;
      },
      decoration: InputDecoration(labelText: labelText),
    );
  }
}

// Form Field for Edit Profile
class ProfileFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintName;
  final IconData? icon;
  final TextInputType inputType;
  final int? line;

  const ProfileFormField({
    this.controller,
    this.hintName,
    this.icon,
    this.inputType = TextInputType.text,
    this.line,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: line,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "${'form_field/please-enter'.i18n()} $hintName";
          }
          if (hintName == "Email" && !validateEmail(value)) {
            return 'form_field/valid-email'.i18n();
          }
          return null;
        },
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          prefixIcon: line == 6
            ? Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 105),
                child: Icon(icon),
              )
            : Icon(icon),
          hintText: "${'form_field/enter'.i18n()} $hintName",
          labelText: hintName,
          filled: true,
        ),
      ),
    );
  }
}