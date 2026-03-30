# Ledgerly YOLO Backend (Flask)

This folder contains a small **Flask** API that runs **Ultralytics YOLO** inference.

It is used by the Ledgerly Flutter app’s **Smart Billing Scan** flow to detect items from camera captures and return a list of labels.

---

## API

### `GET /`

Health check.

**Response**: plain text

### `POST /predict`

Runs YOLO inference on an uploaded image.

**Request**
- `Content-Type: multipart/form-data`
- Form field: `image` (required)

**Response**

```json
{
	"count": 2,
	"detections": [
		{
			"label": "apple",
			"confidence": 0.92,
			"bbox": [34.2, 45.1, 120.5, 200.3]
		}
	]
}
```

Where `bbox = [x1, y1, x2, y2]` in pixel coordinates.

---

## Run locally

### Prerequisites

- Python 3.10+

### Setup

```bash
cd backend
python -m venv .venv
```

Activate:

- Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

- macOS/Linux:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Start the server:

```bash
python app.py
```

By default it listens on `0.0.0.0:5000`.

---

## Model configuration

Create a local env file (gitignored):

- Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

- macOS/Linux:

```bash
cp .env.example .env
```

The backend looks for a `backend/.env` file and loads these variables:

- `APP_ENV` — set to `development` to use local weights
- `PORT` — server port (default `5000`)
- `MODEL_PATH` — local weights path (default `best.pt`)

Hugging Face download mode:
- `HF_MODEL_URL` — direct URL to the `.pt` file (required in HF mode)
- `HF_MODEL_FILENAME` — cached filename (default `best.pt`)
- `HF_MODEL_CACHE_DIR` — cache folder (default `.model_cache`)

### Important behavior

- If `backend/.env` is missing **or** `APP_ENV` is not `development`, the backend switches to **Hugging Face mode** and requires `HF_MODEL_URL`.
- In HF mode, weights are downloaded once and cached under `HF_MODEL_CACHE_DIR`.

### About `best.pt`

The weights file `backend/best.pt` is intentionally **gitignored**. For local inference you can:

1. Place your weights at `backend/best.pt`
2. Ensure `APP_ENV=development` in `backend/.env`

---

## Test the endpoint

From macOS/Linux:

```bash
curl -X POST http://127.0.0.1:5000/predict \
	-F "image=@./path/to/image.jpg"
```

From Windows PowerShell (use `curl.exe`):

```powershell
curl.exe -X POST http://127.0.0.1:5000/predict -F "image=@C:\\path\\to\\image.jpg"
```

---

## Connect it to the Flutter app

Set `FLASK_API_URL` in `app/.env`.

Common values:
- Android emulator: `http://10.0.2.2:5000`
- iOS simulator: `http://localhost:5000`
- Physical device: `http://<your-lan-ip>:5000`

---

## Notes

- This service has no auth/rate limiting and is intended for local development. If you deploy it, put it behind an API gateway and add authentication.
- The first request may be slower due to model loading.
