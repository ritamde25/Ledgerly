from flask import Flask, request, jsonify
from ultralytics import YOLO
import numpy as np
from PIL import Image
import io
import os
from pathlib import Path
import shutil
import urllib.request

app = Flask(__name__)

BASE_DIR = Path(__file__).resolve().parent
ENV_PATH = BASE_DIR / ".env"
ENV_FILE_EXISTS = ENV_PATH.exists()


def load_dotenv(env_path: Path) -> None:
    if not env_path.exists():
        return

    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def is_production() -> bool:
    env = (
        os.getenv("APP_ENV") or ""
    )
    return env.lower() != "development"


def download_model(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(url)

    with urllib.request.urlopen(request) as response, destination.open("wb") as out_file:
        shutil.copyfileobj(response, out_file)


def resolve_model_path() -> Path:
    # If .env is missing, default to Hugging Face mode.
    use_huggingface = (not ENV_FILE_EXISTS) or is_production()
    local_model_path = BASE_DIR / os.getenv("MODEL_PATH", "best.pt")
    if not use_huggingface:
        return local_model_path

    hf_model_url = os.getenv("HF_MODEL_URL", "").strip()
    hf_model_filename = os.getenv("HF_MODEL_FILENAME", "best.pt").strip() or "best.pt"
    hf_cache_dir = BASE_DIR / os.getenv("HF_MODEL_CACHE_DIR", ".model_cache")
    cached_model_path = hf_cache_dir / hf_model_filename

    if not hf_model_url:
        raise RuntimeError("HF_MODEL_URL is required when using Hugging Face model")

    if not cached_model_path.exists():
        download_model(hf_model_url, cached_model_path)

    return cached_model_path


load_dotenv(ENV_PATH)
MODEL_PATH = resolve_model_path()
model = YOLO(str(MODEL_PATH))

@app.route("/")
def home():
    return "YOLO Flask API Running"

@app.route("/predict", methods=["POST"])
def predict():
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image provided"}), 400

        file = request.files["image"]

        # Convert image to OpenCV format
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_np = np.array(image)

        # Run YOLO inference
        results = model(image_np)

        detections = []

        for r in results:
            boxes = r.boxes
            for box in boxes:
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                conf = float(box.conf[0])
                cls = int(box.cls[0])
                label = model.names[cls]

                detections.append({
                    "label": label,
                    "confidence": conf,
                    "bbox": [x1, y1, x2, y2]
                })

        return jsonify({
            "count": len(detections),
            "detections": detections
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=not is_production())



# {
#   "count": 2,
#   "detections": [
#     {
#       "label": "apple",
#       "confidence": 0.92,
#       "bbox": [34.2, 45.1, 120.5, 200.3]
#     },
#     {
#       "label": "banana",
#       "confidence": 0.88,
#       "bbox": [150.0, 60.0, 300.0, 220.0]
#     }
#   ]
# }