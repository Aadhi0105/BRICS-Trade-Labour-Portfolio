import requests
from bs4 import BeautifulSoup
import time

BASE_URL = "https://www.rbi.org.in"
ARCHIVE_URL = "https://www.rbi.org.in/Scripts/Annualpolicy.aspx"

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

def get_statement_links(soup):
    """
    From the archive page, extract links to Governor's Statements only.
    We skip Minutes and Press Conference transcripts — we want policy decisions only.
    """
    links = soup.find_all("a", href=True)
    statements = []
    
    for link in links:
        text = link.get_text(strip=True)
        href = link["href"]
        if "Governor\u2019s Statement" in text and "prid=" in href:
            full_url = href if href.startswith("http") else BASE_URL + "/" + href
            statements.append({"title": text, "url": full_url})
    
    return statements

def get_statement_text(url):
    """
    Fetches an individual statement page and extracts the full text from the text1 div.
    """
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code != 200:
            return None
        soup = BeautifulSoup(response.text, "html.parser")
        content = soup.find("div", class_="text1")
        if not content:
            return None
        return content.get_text(separator=" ", strip=True)
    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        return None

def extract_date(title):
    """
    Extracts date from title like "Governor's Statement: February 06, 2026"
    """
    if ":" in title:
        return title.split(":", 1)[1].strip()
    return title

def scrape_rbi(start_year=2016, end_year=2026):
    """
    Loops through all years, collects Governor's Statement links,
    fetches and extracts text from each one.
    Returns a list of dictionaries in our standard schema.
    """
    all_statements = []

    # Collect all links across all years first
    for year in range(start_year, end_year + 1):
        url = f"{ARCHIVE_URL}?Year={year}"
        print(f"Fetching archive for {year}...")
        
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code != 200:
                print(f"  Skipping {year} — status {response.status_code}")
                continue
            soup = BeautifulSoup(response.text, "html.parser")
            links = get_statement_links(soup)
            print(f"  Found {len(links)} statements")
            all_statements.extend(links)
        except Exception as e:
            print(f"  Error for {year}: {e}")
        
        time.sleep(1)

    print(f"\nTotal statements to scrape: {len(all_statements)}")
    print("Now fetching full text for each...\n")

    results = []

    for i, stmt in enumerate(all_statements):
        print(f"Scraping {i+1}/{len(all_statements)}: {stmt['title']}")
        text = get_statement_text(stmt["url"])
        
        if text:
            results.append({
                "country": "India",
                "central_bank": "RBI",
                "date": extract_date(stmt["title"]),
                "title": stmt["title"],
                "text": text,
                "url": stmt["url"]
            })
        
        time.sleep(1)

    print(f"\nDone. Successfully scraped {len(results)} statements.")
    return results