# Implementation Plan - Main User Purchase Flow Integration (Reviewed)

This plan outlines the changes required to establish a continuous end-to-end user purchase flow in the StyClick mobile application. We will connect the disconnected screens/actions to ensure a seamless checkout journey.

## Goal Description
Currently, several transition points in the user checkout journey have empty `onTap` handlers or disconnected navigation actions. We will link:
1. The **Add to Cart** bottom sheet to the **Order Summary (Cart)** screen.
2. The **Checkout Page** to the **Payment Page**.
3. The **Payment Page** to the **Order Success Page**.

As the product scope is focused on bespoke garments and fabrics rather than physical shoes, the user flow will model buying **2 custom garments/fabric items** (e.g., 2 Lace Asoebi gowns or 2 yards of Ankara/Swiss Lace).

## User Review & Decisions Incorporated
- **Onboarding/Login**: Real OTP signup and verification are now active (SendGrid is working). No dev bypass PIN will be used for sign up; testing will be validated using actual verification emails.
- **Cart Redirection**: The `addedToCartSheet` will offer two paths:
  1. A primary button: **"View Cart / Checkout"** to navigate directly to the `OrderSummary` screen.
  2. A secondary button: **"Continue Shopping"** to dismiss the sheet and return the user to the browsing details view.
- **Payment & Wallet Check**:
  - The payment flow will verify the user's wallet balance using `WalletService`.
  - If the user's wallet balance is insufficient for the purchase (NGN 67,500), the app will display a notification message asking them to add funds.
  - If the balance is sufficient, the transaction completes mock-deduction and redirects to the `SuccessPage`.
- **UI Bugfix**: The total displayed on `checkout_payment.dart` will be corrected from `NGN 5000` to `NGN 67500` to properly show the sum of subtotal (NGN 62,500) and delivery fee (NGN 5,000).

---

## Proposed Changes

### Checkout & Cart Integration

#### [MODIFY] [details.dart](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/details.dart)
- Inside [addedToCartSheet](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/details.dart#L470), wire the primary button (which currently says "Add to Cart") to close the sheet and navigate to [OrderSummary](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/order_summary.dart). Rename the button text to **"View Cart / Checkout"**.
- Add a secondary button/action **"Continue Shopping"** that calls `Navigator.pop(context)` to dismiss the sheet.

#### [MODIFY] [checkout.dart](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/checkout.dart)
- Wire the **Proceed to payment** button at [checkout.dart:L41](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/checkout.dart#L41) to launch [CheckoutPaymentPage](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/checkout_payment.dart) (passing `isPayment: true`).

#### [MODIFY] [checkout_payment.dart](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/checkout_payment.dart)
- Update imports to include `WalletService`, `SuccessPage`, and `snack_bar.dart` (`showMessage`).
- Update the total cost layout at [checkout_payment.dart:L167](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/order/checkout_payment.dart#L167) to display the correct total `NGN 67500`.
- Implement a stateful loading mechanism on the **Proceed to summary** (payment confirmation) button.
- Tap handler will fetch the wallet balance from the backend API:
  - **Edge Case - Insufficient Balance**: Show a snackbar message: *"Insufficient wallet balance. Please add funds to your wallet."*
  - **Edge Case - API Error/Unavailable**: Show a snackbar error message.
  - **Success**: Redirect to [SuccessPage](file:///c:/Code/Paid%20Projects/StyClick/lib/modules/success_page.dart) with the confirmation message: *"Your order for the custom garments has been successfully placed! NGN 67,500 has been deducted from your wallet."*

---

## Verification Plan

### Manual Verification
1. **Onboarding / Signup**: Register a new user, wait for the SendGrid email OTP, verify, and confirm entry to dashboard.
2. **Item Discovery**: Navigate to **Catalogue** or **Fabrics** and select a product.
3. **Cart Addition & Choice**: Select quantity **2**, tap "Add to Cart":
   - Verify that tapping "Continue Shopping" dismisses the sheet.
   - Verify that tapping "View Cart / Checkout" redirects you to the Cart page.
4. **Order Summary**: Verify cart details and tap "Checkout".
5. **Delivery**: Verify address and tap "Proceed to payment".
6. **Payment & Wallet Check**:
   - Verify that if the account wallet balance is less than NGN 67,500, tapping "Proceed to summary" shows an insufficient funds error.
   - Fund the wallet (or verify with a funded account) and ensure that on successful check, it navigates to the **SuccessPage** displaying the confirmation.
