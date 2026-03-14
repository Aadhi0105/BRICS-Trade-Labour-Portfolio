from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import time

BASE_URL = "https://www.resbank.co.za"
INDEX_URL = "https://www.resbank.co.za/en/home/publications/statements/mpc-statements"

def get_all_statement_urls(driver):
    """
    Navigates through all 5 pages of the SARB MPC statements index
    and collects unique statement URLs.
    """
    driver.get(INDEX_URL)
    time.sleep(3)

    all_urls = []

    for page in range(1, 6):
        print(f"  Collecting links from page {page}...")
        soup = BeautifulSoup(driver.page_source, "html.parser")

        links = soup.find_all("a", href=True)
        mpc_links = [l for l in links
                     if "monetary-policy-statements" in l.get("href", "")
                     and "Read More" not in l.get_text()]

        for l in mpc_links:
            url = BASE_URL + l["href"]
            if url not in all_urls:
                all_urls.append(url)

        if page < 5:
            try:
                from selenium.webdriver.common.by import By
                next_btn = driver.find_element(By.XPATH, f"//button[text()='{page + 1}']")
                next_btn.click()
                time.sleep(3)
            except Exception as e:
                print(f"  Could not click page {page + 1}: {e}")
                break

    return all_urls

def get_statement_text(driver, url):
    """
    Navigates to an individual SARB MPC statement page and extracts
    the full text by combining all cmp-text divs.
    """
    try:
        driver.set_page_load_timeout(30)
        driver.get(url)
        time.sleep(4)

        soup = BeautifulSoup(driver.page_source, "html.parser")

        # Extract title
        parts = url.rstrip("/").split("/")
        month = parts[-1].split("-")[0].title()  # handles cases like "March-2022"
        year = parts[-2] if parts[-2].isdigit() else parts[-1].split("-")[-1]
        title = f"Statement of the Monetary Policy Committee {month} {year}"

        # Extract date from URL - pattern is .../year/month
        parts = url.rstrip("/").split("/")
        month = parts[-1].replace("-", " ").title()
        year = parts[-2] if parts[-2].isdigit() else ""
        date = f"{month} {year}".strip()

        # Combine all cmp-text divs for full statement text
        all_cmp_text = soup.find_all("div", class_="cmp-text")
        text = " ".join([div.get_text(separator=" ", strip=True) 
                         for div in all_cmp_text])

        return title, date, text

    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        return None, None, None

def scrape_sarb():
    """
    Main function — opens Chrome via Selenium, collects all MPC statement
    URLs across 5 pages, then fetches and extracts text from each one.
    Returns a list of dictionaries in our standard schema.
    """
    print("Starting SARB scraper...")
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        # Step 1 - collect all URLs
        print("Collecting statement URLs...")
        urls = get_all_statement_urls(driver)
        print(f"Found {len(urls)} statements\n")

        results = []

        # Step 2 - fetch each statement
        for i, url in enumerate(urls):
            print(f"Scraping {i+1}/{len(urls)}: {url.split('/')[-1]}")
            title, date, text = get_statement_text(driver, url)

            if text and len(text) > 100:
                results.append({
                    "country": "South Africa",
                    "central_bank": "SARB",
                    "date": date,
                    "title": title,
                    "text": text,
                    "url": url
                })

        print(f"\nDone. Successfully scraped {len(results)} statements.")
        return results

    finally:
        # Always close the browser even if something goes wrong
        driver.quit()