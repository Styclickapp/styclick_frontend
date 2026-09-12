# StyClick Task Tracker

This document tracks completed UI/flow adjustments and outlines outstanding integration work to be completed once backend API access/deployment is finalized.

## Completed Tasks

### Onboarding & Login Screen Revamp
- [x] **Biometric Sign-In Removal**: Removed the "Sign In with Biometrics" button and the "OR" divider from the login flow.
- [x] **Scrolling Mitigation**: Adjusted vertical layouts (compacted logo container size, shrunk text sizes, reduced spacer heights) to ensure the login screen and walkthrough screen fit entirely inside the display boundary without needing to scroll.
- [x] **Automatic Email Verification Redirect**: Updated the login response handler to automatically detect unverified account errors (`401` with message `"Please verify your email address..."`) and redirect the user directly to the OTP verification screen.
- [x] **OTP Verification Screen Adjustments**: Moved the countdown text and the **Resend** button onto separate lines within a clean vertical column layout.
- [x] **Verification API Connection**: Removed temporary mock bypasses; the app now makes production API verification calls.
- [x] **Signup Error Handling**: Removed SendGrid/email error bypass; the sign-up flow now handles standard error alerts directly, since Resend email service integration is fully functional.

---

## Pending Tasks (Once Backend Access is Granted)

### 1. Restore Production Verification API Call
- [x] Revert the temporary bypass in [verify_user.dart](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/auth/verify_user.dart#L80) to call the real backend validation service:
  ```dart
  final res = await AuthService.instance.verify(
    email: widget.email ?? '',
    token: otp,
  );
  ```

### 2. Implement & Deploy Resend OTP Endpoint
- [ ] Work with the backend developer to deploy a working `resend-otp` route on the backend server (`https://styclick-backend.onrender.com/api/v1/`).
  - Currently, `POST auth/resend-otp` returns a `404 Not Found` response.
- [ ] Ensure the route accepts a POST request with the user's email:
  ```json
  {
    "email": "user@email.com"
  }
  ```
- [ ] Once the endpoint is verified, update/confirm `resendOtp` in [endpoint.dart](file:///c:/Code/Paid%20Projects/StyClick/lib/shared/endpoint.dart) and re-enable testing in [test_endpoints.dart](file:///c:/Code/Paid%20Projects/StyClick/test_endpoints.dart).
