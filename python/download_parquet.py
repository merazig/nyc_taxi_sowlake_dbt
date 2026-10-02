"""Load taxi nyc."""

import os

import requests

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"
OUTPUT_DIR = "data"

START_MONTH = 1
END_MONTH = 12
YEAR = 2025


def download_file(month):
    """Telecharge les parquets."""
    filename = f"yellow_tripdata_{YEAR}-{month:02d}.parquet"
    url = f"{BASE_URL}/{filename}"
    output_path = os.path.join(OUTPUT_DIR, filename)

    if os.path.exists(output_path):
        print(f"[SKIP] {filename} already exists")
        return

    print(f"[DOWNLOAD] {filename}")

    response = requests.get(url, stream=True, timeout=60)
    response.raise_for_status()

    with open(output_path, "wb") as file:
        for chunk in response.iter_content(chunk_size=1024 * 1024):
            if chunk:
                file.write(chunk)

    print(f"[OK] {filename}")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for month in range(START_MONTH, END_MONTH + 1):
        try:
            download_file(month)
        except requests.RequestException as error:
            print(f"[ERROR] Month {month:02d}: {error}")


if __name__ == "__main__":
    main()
