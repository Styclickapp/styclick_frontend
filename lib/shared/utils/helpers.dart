import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

String formatDate(DateTime dateTime) {
  return DateFormat('dd MMM yyyy').format(dateTime);
}

String formatTime(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}

String formatDateApi(DateTime dateTime) {
  return DateFormat('yyyy-mm-dd').format(dateTime);
}

///design height(responsiveness)
double logicalHeight() {
  return WidgetsBinding.instance!.window.physicalSize.height /
      WidgetsBinding.instance!.window.devicePixelRatio;
}

///design width(responsiveness)
double logicalWidth() {
  return WidgetsBinding.instance!.window.physicalSize.width /
      WidgetsBinding.instance!.window.devicePixelRatio;
}

double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

String formatPrice(dynamic amount) {
  if (amount == null) return '0.00';
  final formatter = NumberFormat("#,##0.00", "en_US");
  if (amount is num) {
    return formatter.format(amount);
  }
  final parsed = double.tryParse(amount.toString());
  if (parsed != null) {
    return formatter.format(parsed);
  }
  return amount.toString();
}

String formatPriceNoDecimal(dynamic amount) {
  if (amount == null) return '0';
  final formatter = NumberFormat("#,##0", "en_US");
  if (amount is num) {
    return formatter.format(amount);
  }
  final parsed = double.tryParse(amount.toString());
  if (parsed != null) {
    return formatter.format(parsed);
  }
  return amount.toString();
}

