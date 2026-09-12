# Memory & Rules Log

This file tracks the core constraints, decisions, and development guidelines for StyClick to ensure consistency and prevent UI/functional regressions.

## Retained Flutter UX & Implementation Rules

1. **Debounce Interactive Actions**
   - *Implementation*: Always block or disable primary buttons (`onTap: isLoading ? null : ...`) during active async operations.
   - *Example*: The "Confirm & Pay" button disables tap events while querying the wallet service to prevent double-charging or multiple order submission events.

2. **Prevent Infinite Loading States**
   - *Implementation*: Apply fallback connection timeouts on all asynchronous network calls.
   - *Example*: Set a global 15-second timeout (`.timeout(const Duration(seconds: 15))`) inside `ApiService` HTTP wrappers.

3. **Provide Exit Paths**
   - *Implementation*: Every sheet and view must have an explicit exit pattern (e.g., closing icons, cancel options, or gesture-poppable navigation).
   - *Example*: Bottom sheets and checkout screens include clear close widgets that execute `Navigator.pop`.

4. **Correct Price Spacing & Commas**
   - *Implementation*: Format cost layout items cleanly with comma separators using typography consistent with the rest of the application layout system.

5. **Enforce Strict Static Types & Non-null Safety**
   - *Implementation*: Always bind nullable model properties to local variables when performing conditional operations (to allow Dart compiler promotion), avoid using deprecated platform/window properties (like `WidgetsBinding.instance!.window`), ensure essential package imports (`dart:io`, `package:cached_network_image/cached_network_image.dart`) are explicitly declared, and use `context` instead of undefined shorthands like `ctx`. Run `flutter analyze --no-pub` before verifying runs.

---

## Workspace Decisions Log

- **Email Client**: Changed from SendGrid to **Resend**. The registration bypass dialog was removed, and standard errors are caught and shown directly to the user since the backend mail service integration is live.
- **Mock Payment Deductions**: Wallet-based check verifies if balance is $\ge$ `NGN 67,500` (computed from item subtotal `NGN 62,500` + delivery `NGN 5,000`). If valid, mock-deducts the balance and transitions to `SuccessPage`.
- **Clean Minimalist Headers**: Redesigned all screen headers to use a flat white (`cream`) background, zinc-900 (`ink`) icons, and a compact visual height (vertical padding of `12.h` or standard `PreferredSize` of `56.h` for AppBars). Hided redundant screen title text on primary navigation tabs (Catalogue, Home, Account) while secondary screens keep a clean, smaller dark text (`18.sp` `ink`) instead of large `brandGradient` boxes.
- **Text & Layout Optimization**: Standardized and optimized text container bounds, list scrolling, row wrapping, and price formatting across `checkout.dart`, `order_summary.dart`, `checkout_payment.dart`, `wallet.dart`, `transaction_history.dart`, `request_withdrawal.dart`, and `add_funds.dart` to prevent text overflow/clipping and ensure proper accessibility/font scaling support. Centralized pricing and currency rendering with standard commas via helper functions in `helpers.dart`.
- **Centralized Navigation Drawer**: Refactored 9 duplicated implementations of the side menu drawer across the application into a single shared widget `AppDrawer` in `app_drawer.dart`. Moved "Become a Vendor" to its own segregated top section above "Home" separated by a divider.
- **Account Layout Update**: Removed "Become a Vendor" from the bottom menu list on the account screen. Instead, rendered it as a full-width long button card matching the style of the "Help", "Wallet", and "Activity" buttons, positioned directly below them.
- **Logistics Disabling**: Instead of removing dispatch rider/logistics, visibly and obviously disabled them (transparent border, grayed out icon/text/arrows) in `vendor/index.dart` and the home screen quick access row. Clicking them displays a "Coming soon" toast.
- **Universal Tailors Rename**: Universal rename of the "Fashion Designer" role to "Tailors" (or "Tailor") across walkthrough descriptions, registration headers, and success popups.
- **Vendor Option Explanations**: Updated descriptions on the become a vendor option page to clearly convey role limits (Tailors sell fabrics/ready-made/clothes, Fabrics Sellers sell fabrics only, and Dispatch Riders perform dispatches only).
- **Change Vendor Role in Settings**: Integrated a "Change Vendor Role" setting action under the ACCOUNT section in `settings.dart` that routes users back to the vendor onboarding card page to select a different role.
- **Standardized Form Fields**: Standardized registration (Tailor, Fabrics Seller, Dispatch Rider) and profile forms to use `CustomTextField` with uppercase Montserrat labels positioned on top of the text fields and no prefix icons, ensuring a uniform visual theme matching login/signup inputs.




