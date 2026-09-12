import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = "https://styclick-backend.onrender.com/api/v1/";
final String email = "blueparticlestudios@gmail.com";
final String password = "Astronomy#1";

void main() async {
  print('==============================================');
  print('TESTING LIVE USER AUTH & TRANSACTIONS');
  print('Target: $email');
  print('==============================================');

  String token = '';

  // 1. Try Login
  print('\n[1] Attempting Login...');
  try {
    final loginRes = await http.post(
      Uri.parse(baseUrl + "auth/login"),
      headers: {"Accept": "application/json", "Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    print('Status: ${loginRes.statusCode}');
    print('Body: ${loginRes.body}');

    if (loginRes.statusCode == 200 || loginRes.statusCode == 201) {
      final data = jsonDecode(loginRes.body);
      token = (data['token'] ?? data['data']?['token'] ?? '').toString();
      print('>>> LOGIN SUCCESS! Token: ${token.isNotEmpty ? "Acquired (${token.length} chars)" : "Empty"}');
    } else if (loginRes.statusCode == 401 && loginRes.body.contains("verify")) {
      print('>>> Account needs verification. Triggering signup/verify check.');
    }
  } catch (e) {
    print('Login Error: $e');
  }

  // If login failed because user not found, try signup
  if (token.isEmpty) {
    print('\n[1b] User may need registration or activation. Trying signup...');
    try {
      final signupRes = await http.post(
        Uri.parse(baseUrl + "auth/signup"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "firstname": "BlueParticle",
          "lastname": "Admin",
          "phone": "+2348012345678",
          "state": "Lagos",
          "address": "Victoria Island, Lagos",
          "origin": "mobile"
        }),
      );
      print('Signup Status: ${signupRes.statusCode}');
      print('Signup Body: ${signupRes.body}');
    } catch (e) {
      print('Signup error: $e');
    }
  }

  // 2. Fetch Public Products (Marketplace/Catalogue)
  print('\n[2] Fetching Public Products & Images...');
  try {
    final prodRes = await http.get(
      Uri.parse(baseUrl + "products"),
      headers: {"Accept": "application/json"},
    );
    print('Products Status: ${prodRes.statusCode}');
    if (prodRes.statusCode == 200) {
      final data = jsonDecode(prodRes.body);
      final list = (data is List) ? data : (data['data'] is List ? data['data'] : []);
      print('Total Products Found: ${list.length}');
      if (list.isNotEmpty) {
        print('Sample Product: ${list.first['name'] ?? list.first['title']} - Price: ${list.first['price']}');
      }
    } else {
      print('Products Body: ${prodRes.body}');
    }
  } catch (e) {
    print('Products Error: $e');
  }

  // 3. If token acquired, test protected endpoints: profile, wallet, vendor apply
  if (token.isNotEmpty) {
    final authHeaders = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    print('\n[3] Testing User Profile...');
    try {
      final profRes = await http.get(Uri.parse(baseUrl + "user/profile"), headers: authHeaders);
      print('Profile Status: ${profRes.statusCode}');
      print('Profile Body: ${profRes.body}');
    } catch (e) {
      print('Profile Error: $e');
    }

    print('\n[4] Testing Wallet Balance...');
    try {
      final walRes = await http.get(Uri.parse(baseUrl + "wallet/dashboard"), headers: authHeaders);
      print('Wallet Status: ${walRes.statusCode}');
      print('Wallet Body: ${walRes.body}');
    } catch (e) {
      print('Wallet Error: $e');
    }

    print('\n[5] Testing Wallet Funding (Paystack Init)...');
    try {
      final fundRes = await http.post(
        Uri.parse(baseUrl + "wallet/add-fund"),
        headers: authHeaders,
        body: jsonEncode({"amount": "5000", "payment_method": "card"}),
      );
      print('Fund Status: ${fundRes.statusCode}');
      print('Fund Body: ${fundRes.body}');
    } catch (e) {
      print('Fund Error: $e');
    }
  }

  print('\n==============================================');
  print('USER ACCOUNT LIVE VERIFICATION COMPLETE');
  print('==============================================');
}
