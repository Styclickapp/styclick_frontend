import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://styclick-backend.onrender.com/api/v1/";
final String email = "blueparticlestudios@gmail.com";
final String password = "Astronomy#1";

void main() async {
  print('==============================================');
  print('TESTING VENDOR PRODUCT POSTING & MARKETPLACE');
  print('Target: $email');
  print('==============================================');

  // 1. Authenticate
  print('\n[1] Logging in...');
  final loginRes = await http.post(
    Uri.parse(baseUrl + "auth/login"),
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );
  print('Login: ${loginRes.statusCode}');
  final loginData = jsonDecode(loginRes.body);
  final token = loginData['data']['token'];
  final user = loginData['data'];
  print('User Role: ${user['type']} - Vendor Type: ${user['vendor_type']}');

  final headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  // 2. Post new design/garment
  print('\n[2] Posting new luxury design to marketplace...');
  try {
    final postRes = await http.post(
      Uri.parse(baseUrl + "vendor/products"),
      headers: headers,
      body: jsonEncode({
        "name": "Astronomy Imperial Velvet Agbada",
        "title": "Astronomy Imperial Velvet Agbada",
        "description": "Mastercrafted bespoke royal velvet agbada with gold filigree hand-embroidery.",
        "price": 285000,
        "category": "Men Traditional",
        "stock": 10,
        "images": [
          "https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800",
          "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800"
        ]
      }),
    );
    print('Post Product Status: ${postRes.statusCode}');
    print('Post Product Body: ${postRes.body}');
  } catch (e) {
    print('Post product error: $e');
  }

  // 3. Fetch products to verify
  print('\n[3] Verifying public products catalogue...');
  final prodRes = await http.get(Uri.parse(baseUrl + "products"), headers: {"Accept": "application/json"});
  print('Catalog Status: ${prodRes.statusCode}');
  print('Catalog Body: ${prodRes.body}');

  print('\n==============================================');
  print('LIVE VENDOR TEST COMPLETE');
  print('==============================================');
}
