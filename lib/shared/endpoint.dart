
const String baseUrl = "https://styclick-backend.onrender.com/api/v1/";

// ── Auth ──────────────────────────────────────────────────────────────────
const String register        = "auth/signup";
const String signIn          = "auth/login";
const String verifyUser      = "auth/verify";
const String resendOtp       = "auth/resend-otp";
const String resetRequest    = "auth/password-reset-request";
const String changePassword  = "auth/reset-password";
const String adminSignIn     = "auth/admin/login";

// ── Profile ───────────────────────────────────────────────────────────────
const String getProfile      = "user/profile";
const String updateProfile   = "user/update-profile";
const String deleteAccount   = "auth/delete-account";

// ── Wallet ────────────────────────────────────────────────────────────────
const String walletBalance   = "wallet/dashboard";
const String walletTransactions = "wallet/transactions";
const String walletFund      = "wallet/add-fund";
const String walletWithdraw  = "wallet/withdraw";

// ── Vendor / Seller / Rider ───────────────────────────────────────────────
const String becomeVendor       = "vendor/apply/designer";
const String becomeSeller       = "vendor/apply/fabric-seller";
const String becomeRider        = "vendor/apply/rider";

// ── Vendor Profile & Media ───────────────────────────────────────────────
const String vendorProfile      = "vendor/profile";
const String vendorUpload       = "vendor/upload";
const String vendorBusinessHours = "vendor/business-hours";
const String vendorPolicies    = "vendor/policies";

// ── Vendor Products ──────────────────────────────────────────────────────
const String vendorProducts     = "vendor/products";
const String vendorUploadImage  = "vendor/products/upload-image";

// ── Public Products / Catalogue ───────────────────────────────────────────
const String publicProducts        = "products";
const String publicVendorProfile   = "vendors";  // GET vendors/:id

// ── Chats / Messages ───────────────────────────────────────────────────────
const String chatInbox        = "chats";
const String chatMessages     = "chats/messages";
const String chatSendMessage  = "chats/message";

