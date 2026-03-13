import requests
from bs4 import BeautifulSoup
import time

# Base URL pattern for SARB MPC statements
BASE_URL = "https://www.resbank.co.za/en/home/publications/publication-detail-pages/statements/monetary-policy-statements"

# SARB holds MPC meetings roughly every 2 months - these are the months they typically publish
MONTHS = ["january", "march", "may", "july", "september", "november"]

def scrape_sarb(start_year=2000, end_year=2025):
    """
    Loops through years and months, fetches each MPC statement page,
    extracts the text, and returns a list of dictionaries.
    """
    results = []

    for year in range(start_year, end_year + 1):
        for month in MONTHS:
            url = f"{BASE_URL}/{year}/{month}"
            
            try:
                # Fetch the page - timeout=10 means give up after 10 seconds
                response = requests.get(url, timeout=10)
                
                # 200 means the page exists, anything else means skip
                if response.status_code != 200:
                    continue
                
                # Parse the HTML with BeautifulSoup
                soup = BeautifulSoup(response.text, "html.parser")
                
                # Extract the statement title
                title_tag = soup.find("h1")
                title = title_tag.get_text(strip=True) if title_tag else f"SARB MPC {month} {year}"
                
                # Extract the main body text - SARB puts content in div.container
                body = soup.find("div", class_="container")
                if not body:
                    continue
                
                # Get clean text - strip removes leading/trailing whitespace
                text = body.get_text(separator=" ", strip=True)
                
                results.append({
                    "country": "South Africa",
                    "central_bank": "SARB",
                    "date": f"{year}-{month}",
                    "title": title,
                    "text": text,
                    "url": url
                })
                
                print(f"✓ Scraped: {month} {year}")
                
                # Be polite - wait 1 second between requests so we don't hammer the server
                time.sleep(1)
                
            except Exception as e:
                print(f"✗ Failed: {month} {year} — {e}")
                continue

    return results