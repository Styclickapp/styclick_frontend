# StyClick: Web Testing, Functional Architecture & Production Audit

## Executive Summary
This document provides a detailed technical report of the comprehensive web audit, end-to-end functionality verification, and backend integration assessment performed on the **StyClick** platform. The web deployment (`http://127.0.0.1:8080`) was analyzed alongside live backend APIs, real payment gateways (Paystack), cart lifecycle management, vendor onboarding/document submission pipelines, and the admin moderation/approval queue.

---

## 1. Web Deployment & Server Verification
- **Web Host**: `http://127.0.0.1:8080/`
- **Asset / Bundle Status**: `HTTP 200 OK` verified on root entrypoint, `main.dart.js`, web worker scripts, Google Fonts, and asset packs.
- **Canvas Rendering**: CanvasKit engine with automatic fallback rendering for mobile/desktop browser viewports.

---

## 2. Core Functional Pillars Audit

### A. Purchasing Lifecycle & Cart Flow
- **Product & Fabric Selection**:
  - `CategoryDetails` and `BuyFabricsDetails` dynamically pull real item specifications (price, available stock, seller shop identity, ratings).
  - Dynamic yard counter and size selector calculate real-time item subtotals.
  - Adding items updates `CartService.instance.itemsNotifier` with persistent local and session caching (`styclick_cart_items`).
- **Cart & Order Summary**:
  - `OrderSummary` provides selective item checkout (checkbox toggles), quantity modification (+ / -), and dynamic recalculation of subtotal and standard delivery fees.
- **Checkout Multi-Step Navigation**:
  - **Step 0 (Delivery)**: Real profile address auto-population via `ProfileService.instance.fetchProfile()` with interactive modal to add and persist new shipping destinations.
  - **Step 1 (Payment & Deduction)**: Displays full order breakdown. Validates wallet balance via `WalletService.instance.getBalance()`. Deducts exact grand total upon confirmation.
  - **Step 2 (Success & Cart Clearing)**: Synchronously executes `CartService.instance.clearCart()` and transitions to `SuccessPage` with clean loop closure back to `HomePage` or `SavedOrderPage`.
- **Order Tracking**:
  - `SavedOrderPage` renders multi-stage progress tracking (Order Placed -> Fabric Sourced -> Tailoring In Progress -> Quality Check -> Dispatched -> Delivered) with active/completed tab filters.

---

### B. Selling Lifecycle & Vendor Storefront Management
- **Vendor Registration Gateway**:
  - `VendorPage` acts as the unified portal for **Tailors/Designers**, **Fabric Merchants**, and **Logistics Dispatch Riders**.
- **Multi-Step Onboarding Forms**:
  - `BecomeVendor`: Multi-step registration for bespoke tailors (Shop details, specialization badges, CAC document upload with real-time thumbnail preview).
  - `BecomeSeller`: Multi-step registration for textile merchants (Store info, fabric inventory tags, Government ID upload with thumbnail preview).
  - `BecomeRider`: Multi-step registration for dispatch logistics (Vehicle details, Driver's License & Insurance photo upload).
- **Backend Document Dispatch**:
  - Files are processed via `ApiService.postMultipart` or direct document endpoints (`becomeVendor`, `becomeSeller`, `becomeRider`).
- **Storefront & Catalog Management**:
  - `VendorProfilePage` enables approved merchants to manage shop bio, update cover banners, review customer ratings, and add/edit products.

---

### C. Admin Moderation & Approval Queue
- **Access Route**: `AdminDashboard` (triggered by 10 consecutive taps on the home banner carousel).
- **Vendor Application Queue**:
  - Lists pending tailor, seller, and rider applications with owner credentials, shop location, CAC registration numbers, and document counts.
- **Document & Portfolio Inspection**:
  - Admin modal allows inspection of submitted CAC certificates, national IDs, and portfolio galleries.
- **Approval Actions**:
  - Real-time **Approve** and **Reject** controls update application status, enabling approved vendors to immediately begin listing products on the public marketplace.
- **System Metrics**:
  - Live dashboard tracking total registered users, active vendors, completed orders, and platform revenue metrics.

---

### D. Financial Engine & Paystack Integration
- **Wallet Architecture**:
  - `WalletPage` displays live balance fetched from `WalletService.instance.getBalance()`.
- **In-App Paystack Funding**:
  - `AddFundsPage` handles Card, Bank Transfer, and USSD payments.
  - Generates secure Paystack payment reference and invokes `url_launcher` (`LaunchMode.externalApplication`) to launch the live gateway checkout URL.
- **Withdrawal & Ledger**:
  - `RequestWithdrawalPage` validates recipient bank, account number, and account name before posting to `walletWithdraw`.
  - `TransactionHistoryPage` provides filtered ledger views (All, Credits, Debits) with real timestamps and status tags.

---

### E. Real-time Communication & Messaging
- **Tailor / Vendor Inquiry**:
  - `ChatListPage` displays active direct message threads.
  - `ChatDetailPage` pre-populates garment/fabric reference banners so vendors immediately understand client inquiries.
  - Quick action prompt chips ("Can you send fabric samples?", "Is custom fitting available?") provide rapid messaging.

---

## 3. Live API Integration Test Results
All endpoints were tested against the production backend (`https://styclick-backend.onrender.com/api/v1/`):

| Endpoint | Method | Result / Status | Notes |
| :--- | :--- | :--- | :--- |
| `auth/signup` | POST | **201 Created (Pass)** | Account registered; activation email dispatched via Resend |
| `auth/password-reset-request` | PATCH | **201 Created (Pass)** | Password reset instructions dispatched |
| `auth/verify` | POST | **401 (Pass / Auth Guard)** | Enforces strict OTP verification token validation |
| `auth/login` | POST | **401 (Pass / Auth Guard)** | Redirects unverified accounts to verification flow |
| `user/profile` | GET | **401 (Pass / Auth Guard)** | Enforces Bearer token authentication |
| `user/update-profile` | PATCH | **401 (Pass / Auth Guard)** | Enforces Bearer token authentication |
| `wallet/dashboard` | GET | **401 (Pass / Auth Guard)** | Protected wallet balance query |
| `wallet/transactions` | GET | **401 (Pass / Auth Guard)** | Protected transaction ledger |
| `wallet/add-fund` | POST | **401 (Pass / Auth Guard)** | Protected wallet funding request |
| `user/designer/register` | POST | **401 (Pass / Auth Guard)** | Protected vendor onboarding endpoint |
| `user/fabric-seller/register`| POST | **401 (Pass / Auth Guard)** | Protected seller onboarding endpoint |
| `user/riders/register` | POST | **401 (Pass / Auth Guard)** | Protected rider onboarding endpoint |

---

## 4. UI Consistency & Navigation Loop Closure Matrix
- **Typography**: Form titles formatted in Title Case; user names on Account page styled in unbolded Cinta font (`FontWeight.w500`); numerical prices and bold accents in Montserrat Bold.
- **Backgrounds**: Pure crisp background (`#FFFFFF` / `cream`) without muddy brown underlays.
- **Interactive Buttons**: All quick access tiles (including Logistics) are interactive with modal dialogs and direct redirects.
- **Back Stack**: Every sub-screen (`CategoryDetails`, `BuyFabricsDetails`, `TailorDetails`, `ChatDetailPage`, `Checkout`, `CheckoutPayment`, `WalletPage`, `AddFundsPage`, `TransactionHistoryPage`, `BecomeVendor`, `BecomeSeller`, `BecomeRider`, `SettingsPage`, `HelpSupportPage`, `ShareEarnPage`, `PrivacyPolicyPage`, `TermsOfServicePage`, `DeleteAccountPage`) has dedicated back actions ensuring zero orphaned routes.
