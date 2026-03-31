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

You do **not** need to provide your own model to run this backend.
By default, it automatically downloads and uses the project's Hugging Face model.

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

- `PORT` — server port (default `5000`)
- `MODEL_PATH` — optional local weights path override (default `best.pt`)

No Hugging Face env setup is required.

### Important behavior

1. The backend checks `MODEL_PATH` first.
2. If that file exists, it is used directly.
3. If not, it downloads and uses the built-in Hugging Face model URL.
4. Downloaded weights are cached in `backend/.model_cache/best.pt` and reused.

### About `best.pt`

The weights file `backend/best.pt` is intentionally **gitignored**. For local inference you can:

1. Place your weights at `backend/best.pt`
2. Or set `MODEL_PATH` in `backend/.env` to another local file path
3. Start the server normally (`python app.py`)

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
