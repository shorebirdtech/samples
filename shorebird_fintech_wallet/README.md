# Shorebird Safe-Guard: Fintech Wallet Demo

[![Watch the Demo](thumbnail.png)](https://youtu.be/vRzG3dWfyuc)

This project demonstrates a professional, enterprise-grade Flutter architecture designed for **Logic-Level Hotfixes** using [Shorebird](https://shorebird.dev).

## 🏗️ Architecture: The "Reactive Store + BLoC" Hybrid

To ensure stability and patchability, the app uses a decoupled architecture:

### 1. **Reactive Store (Global Logic Layer)**
Located in `lib/store/`, this layer acts as the single source of truth. It manages:
*   Reactive balance updates.
*   Transaction history.
*   Business logic rules (like fee calculations).

### 2. **BLoC (Presentation Layer)**
Located in `lib/presentation/features/*/bloc/`, these BLoCs act as bridges. They:
*   Subscribe to the Global Reactive Store.
*   Emit UI-specific states (`Loading`, `Success`, `Preview`).
*   **Crucially:** They do not contain business logic; they only orchestrate calls to the logic layer.

### 3. **UI (Material 3 Dark Mode)**
A reactive, premium Fintech UI built with Google Fonts and custom animations.

---

## 🎯 The Shorebird Patch Target

The core of this demo is a **critical business logic bug** located in:
`lib/store/wallet_store/transaction_logic.dart`

### **The Scenario**
Management required internal transfers (between friends) to be **free ($0)** and standard transfers to have a **1% fee**.

### **The Bug (Current Implementation)**
The current logic accidentally applies a flat **5% fee** to every transaction, ignoring the internal flags.

```dart
// BUGGY LOGIC
double calculateFee(double amount, bool isInternal) {
  return amount * 0.05; // Fixed 5% fee for everyone
}
```

### **The Fix (Shorebird Patch)**
Because this logic is decoupled from the UI and state management, a Shorebird patch can swap the `calculateFee` implementation instantly without requiring a full app store release or losing the user's current session state.

```dart
// FIXED LOGIC (To be patched)
double calculateFee(double amount, bool isInternal) {
  if (isInternal) return 0.0;
  return amount * 0.01;
}
```

## 🛠️ Tech Stack
*   **Dependency Injection:** `get_it` + `injectable`
*   **Networking:** `dio`
*   **State Management:** Global Reactive Store + BLoC (Presentation)
*   **Stlying:** Vanilla CSS/Material 3 Dark + Google Fonts (Outfit)
