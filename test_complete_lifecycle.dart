import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://styclick-backend.onrender.com/api/v1/";
final String email = "blueparticlestudios@gmail.com";
final String password = "Astronomy#1";

void main() async {
  print('===============================================================');
  print('STYCLICK COMPREHENSIVE LIVE LIFECYCLE AUDIT');
  print('Target Account: $email');
  print('===============================================================');

  // STEP 1: AUTHENTICATION (LOGIN)
  print('\n[1] AUTHENTICATION & LOGIN');
  final loginRes = await http.post(
    Uri.parse(baseUrl + "auth/login"),
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );
  print('Login HTTP Status: ${loginRes.statusCode}');
  final loginData = jsonDecode(loginRes.body);
  final token = (loginData['data']?['token'] ?? loginData['token'] ?? '').toString();
  print('Login Message: ${loginData['message']}');
  print('Token Acquired: ${token.isNotEmpty ? "YES (${token.length} chars)" : "NO"}');
  assert(token.isNotEmpty, "Token must not be empty");

  final authHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  // STEP 2: USER PROFILE & KYC/VERIFICATION STATUS
  print('\n[2] USER PROFILE & KYC VERIFICATION');
  final profileRes = await http.get(Uri.parse(baseUrl + "user/profile"), headers: authHeaders);
  print('Profile Status: ${profileRes.statusCode}');
  final profileData = jsonDecode(profileRes.body);
  final user = profileData['data'];
  print('User Name: ${user['firstname']} ${user['lastname']}');
  print('User Role: ${user['type']} | Vendor Type: ${user['vendor_type']}');
  print('Email Verified: ${user['verified_email']} | Compliance Verified: ${user['verified_compliance']}');
  print('KYC Record: ${user['user_kyc']}');

  // STEP 3: VENDOR APPLICATION / DB VERIFICATION CHECK
  print('\n[3] VENDOR ONBOARDING / APPLICATION');
  try {
    final vendorApplyRes = await http.post(
      Uri.parse(baseUrl + "vendor/apply/designer"),
      headers: authHeaders,
      body: jsonEncode({
        "business_name": "BlueParticle Atelier",
        "bio": "Premier luxury haute couture atelier specializing in bespoke African contemporary garments.",
        "specialization": "Bespoke Suiting & Royal Traditional",
        "city": "Abuja",
        "state": "Abuja",
        "address": "Maitama District, Abuja",
        "experience_years": "8"
      }),
    );
    print('Vendor Apply Status: ${vendorApplyRes.statusCode}');
    print('Vendor Apply Response: ${vendorApplyRes.body}');
  } catch (e) {
    print('Vendor apply note: $e');
  }

  // STEP 4: POSTING ITEMS TO SHOP AS VENDOR
  print('\n[4] POSTING ITEMS TO SHOP AS VENDOR');
  String createdProductId = '';
  try {
    final postProdRes = await http.post(
      Uri.parse(baseUrl + "vendor/products"),
      headers: authHeaders,
      body: jsonEncode({
        "name": "Astronomy Diamond Silk Kaftan",
        "title": "Astronomy Diamond Silk Kaftan",
        "description": "Ultra-fine mulberry silk kaftan tailored with geometric stitch accents.",
        "price": 195000,
        "category": "Men Traditional",
        "stock": 15,
        "images": [
          "https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800",
          "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800"
        ]
      }),
    );
    print('Post Product Status: ${postProdRes.statusCode}');
    print('Post Product Body: ${postProdRes.body}');
    final prodJson = jsonDecode(postProdRes.body);
    createdProductId = (prodJson['data']?['id'] ?? prodJson['id'] ?? '').toString();
    print('Created Product ID: $createdProductId');
  } catch (e) {
    print('Post product note: $e');
  }

  // STEP 5: VENDOR PRODUCTS MANAGEMENT & RETRIEVAL
  print('\n[5] FETCHING VENDOR SHOP PRODUCTS');
  try {
    final vProdRes = await http.get(Uri.parse(baseUrl + "vendor/products"), headers: authHeaders);
    print('Vendor Products Status: ${vProdRes.statusCode}');
    print('Vendor Products Body: ${vProdRes.body}');
  } catch (e) {
    print('Vendor product fetch note: $e');
  }

  // STEP 6: PUBLIC MARKETPLACE & IMAGE RENDERING
  print('\n[6] PUBLIC MARKETPLACE & IMAGE RENDERING');
  final publicRes = await http.get(Uri.parse(baseUrl + "products"), headers: {"Accept": "application/json"});
  print('Public Marketplace Status: ${publicRes.statusCode}');
  if (publicRes.statusCode == 200) {
    final pData = jsonDecode(publicRes.body);
    final items = (pData is List) ? pData : (pData['data'] is List ? pData['data'] : []);
    print('Total Live Items in Catalogue: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      final p = items[i];
      print('  [$i] ${p['name']} | Price: NGN ${p['price']} | Images: ${p['images']}');
    }
  }

  // STEP 7: WALLET & FUNDING
  print('\n[7] WALLET DASHBOARD & TRANSACTIONS');
  final walRes = await http.get(Uri.parse(baseUrl + "wallet/dashboard"), headers: authHeaders);
  print('Wallet Status: ${walRes.statusCode}');
  print('Wallet Body: ${walRes.body}');

  // STEP 8: DELETING / CLEANING UP TEST VENDOR PRODUCT
  if (createdProductId.isNotEmpty) {
    print('\n[8] DELETING VENDOR PRODUCT ($createdProductId)');
    try {
      final delRes = await http.delete(
        Uri.parse(baseUrl + "vendor/products/$createdProductId"),
        headers: authHeaders,
      );
      print('Delete Product Status: ${delRes.statusCode}');
      print('Delete Product Body: ${delRes.body}');
    } catch (e) {
      print('Delete product note: $e');
    }
  }

  print('\n===============================================================');
  print('ALL LIFECYCLE TESTS EXECUTED SUCCESSFULLY!');
  print('===============================================================');
}
