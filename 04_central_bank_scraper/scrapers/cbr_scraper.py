import requests
from bs4 import BeautifulSoup
import time

BASE_URL = "https://www.cbr.ru"
CALENDAR_URL = "https://www.cbr.ru/eng/dkp/cal_mp/"

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

def get_press_release_links(soup):
    """
    From the CBR calendar page, extract all key rate press release links.
    Skips governor statements and other non-press-release links.
    """
    links = soup.find_all("a", href=True)
    pr_links = []
    for l in links:
        href = l.get("href", "")
        if "/eng/press/pr/" in href:
            full_url = BASE_URL + href
            pr_links.append(full_url)
    return pr_links

def get_statement_text(url):
    """
    Fetches an individual CBR press release page and extracts
    the full text from the landing-text div.
    """
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code != 200:
            return None, None
        soup = BeautifulSoup(response.text, "html.parser")

        # Extract text from landing-text div
        content = soup.find("div", class_="landing-text")
        if not content:
            return None, None
        text = content.get_text(separator=" ", strip=True)

        # Extract date from news-info-line_date div
        date_div = soup.find("div", class_="news-info-line_date")
        date = date_div.get_text(strip=True) if date_div else ""

        # Extract title from page
        title_tag = soup.find("h1")
        title = title_tag.get_text(strip=True).replace("\xa0", " ") if title_tag else ""

        return text, date, title

    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        return None, None, None

def scrape_cbr():
    """
    Main function — fetches the CBR calendar page, collects all
    key rate press release links, then fetches text from each one.
    Returns a list of dictionaries in our standard schema.
    """
    print("Fetching CBR calendar page...")
    response = requests.get(CALENDAR_URL, headers=headers, timeout=10)

    if response.status_code != 200:
        print(f"Failed to fetch calendar: {response.status_code}")
        return []

    soup = BeautifulSoup(response.text, "html.parser")
    urls = get_press_release_links(soup)
    print(f"Found {len(urls)} press release links")

    results = []

    for i, url in enumerate(urls):
        print(f"Scraping {i+1}/{len(urls)}: {url}")
        result = get_statement_text(url)

        # get_statement_text returns 3 values
        if result and result[0]:
            text, date, title = result
            results.append({
                "country": "Russia",
                "central_bank": "CBR",
                "date": date,
                "title": title,
                "text": text,
                "url": url
            })

        time.sleep(1)

    print(f"\nDone. Successfully scraped {len(results)} statements.")
    return results