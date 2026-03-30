# Ledgerly (Flutter app)

Ledgerly is a mobile app for digitizing the traditional **Udhaar/Khata** workflow — customer ledger, billing, inventory, and transaction history.

The app is **offline-first** (SQLite via Drift), supports **Supabase Auth + sync**, and can optionally use a local **Flask + YOLO** backend for camera-assisted billing.

---

## Requirements

- Flutter SDK (Dart 3.5+)
- Android Studio / Xcode (for emulators/simulators)
- A Supabase project (URL + anon key)

---

## Setup

### 1) Install dependencies

```bash
cd app
flutter pub get
```

### 2) Configure environment variables

This app reads configuration from `.env` (loaded via `flutter_dotenv`).

1. Copy `.env.example` → `.env`
2. Fill in:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Optional: only needed for Smart Billing Scan (camera)
FLASK_API_URL=http://10.0.2.2:5000
```

Notes:
- `.env` is included as a Flutter asset (see `pubspec.yaml`), so it must exist for the app to start.
- Keep real values out of git. `.env` is gitignored.

### 3) Run

```bash
flutter run
```

---

## Smart Billing Scan (camera + YOLO)

Ledgerly includes an optional camera flow that:
1. Captures one or more photos of items.
2. Uploads each image to the backend `POST /predict` endpoint.
3. Reads detected `label`s and maps them to inventory items by `yoloLabel` (or name fallback).

To use it:
- Start the backend from `../backend` (see [../backend/README.md](../backend/README.md)).
- Set `FLASK_API_URL` in `.env`.

Emulator URL reminders:
- Android emulator: `http://10.0.2.2:5000`
- iOS simulator: `http://localhost:5000`
- Physical device: use your dev machine LAN IP

---

## Data model (local)

The app uses Drift tables:
- **Customers** (UUID text id, `totalDue`, `phone`)
- **BaseInventoryItems** (global catalog, includes `yoloLabel` + `updatedAt`)
- **InventoryItems** (user-scoped inventory + overrides; can reference a base item)
- **Transactions** (UUID text id, `itemsJson`, `totalAmount`, `timestamp`, `createdAt`)

Local rows track sync state with an `isSynced` flag.

---

## Sync behavior (Supabase)

Sync runs on app start and after login.

High level strategy:
- Base inventory is pulled incrementally using `updated_at`.
- Customers are **pushed first** (unsynced local rows upserted), then pulled.
- Inventory is pulled, then unsynced local rows are upserted.
- Transactions are **pushed first**, then pulled incrementally using `created_at`.
- Pulls avoid overwriting pending local changes:
	- Customers: skip rows that are locally `isSynced = false`
	- Transactions: pull uses `insertOrIgnore`

---

## CSV import/export

CSV actions are exposed via the overflow menu on these screens:
- Customers: import/export customers
- Inventory: import/export inventory
- Bills/History: import/export transactions

Export uses the platform share sheet; import uses the platform file picker.

---

## SMS reminders

From customers, you can open an SMS draft reminder:
- Individual reminder from a customer detail screen
- Bulk reminder draft addressed to all due customers

This uses `url_launcher` to open the native SMS composer (it does not silently send messages).

---

## Development

### Code generation (Drift / JSON)

If you change Drift tables or JSON models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lint & tests

```bash
flutter analyze
flutter test
```

---

## Project structure

- `lib/core/` — config (`EnvConfig`), auth providers, DB (Drift), utilities
- `lib/services/` — sync service, camera billing service
- `lib/screens/` — UI screens (home, billing, camera billing, customers, inventory, history)
- `lib/widgets/` — reusable UI components
