import fitz  # pymupdf
import pandas as pd
from pathlib import Path
import re

PDF_DIR = Path("data/rbi_pdfs")
OUTPUT_CSV = Path("data/rbi_historical.csv")

def extract_text_from_pdf(pdf_path):
    """Extract full text from a PDF file using pymupdf."""
    try:
        doc = fitz.open(pdf_path)
        text = ""
        for page in doc:
            text += page.get_text()
        doc.close()
        return text.strip()
    except Exception as e:
        print(f"  Error reading {pdf_path.name}: {e}")
        return None

def extract_title_from_text(text):
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    
    # Skip known noise patterns
    noise = [
        'PRESS RELEASE', 'RESERVE BANK', 'Website', 'email',
        'फोन', 'DEPARTMENT', 'संचार', 'वेबसाइट', 'www.rbi',
        'helpdoc', 'Mumbai', 'S.B.S', '___', '---',
        'Shahid', 'Fort,', 'Central Office'
    ]
    
    clean_lines = [l for l in lines if not any(n in l for n in noise)]
    
    # Look for explicit title patterns first
    for line in clean_lines[:30]:
        if any(keyword in line for keyword in [
            "Bi-monthly Monetary Policy Statement",
            "Governor's Statement",
            "Monetary Policy Statement",
            "Resolution of the Monetary Policy Committee"
        ]):
            # Clean up any trailing noise
            line = re.sub(r'\s+Resolution of.*$', '', line).strip()
            return line
    
    # Fallback — use date from filename context not available here,
    # so return first clean meaningful line
    for line in clean_lines:
        if len(line) > 15 and not line[0].isdigit():
            return line[:100]
    
    return "RBI Monetary Policy Statement"

def date_from_filename(filename):
    """Extract date string from YYYY-MM-DD.pdf filename."""
    stem = Path(filename).stem  # e.g. "2016-04-05"
    return stem  # Keep as string, parse later

def make_title_from_date(date_str):
    """Generate a clean title from YYYY-MM-DD date string."""
    from datetime import datetime
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    date_formatted = dt.strftime("%B %d, %Y").replace(" 0", " ")
    return f"Governor's Statement: {date_formatted}"

def scrape_pdfs():
    pdf_files = sorted(PDF_DIR.glob("*.pdf"))
    print(f"Found {len(pdf_files)} PDF files\n")
    
    results = []
    for pdf_path in pdf_files:
        print(f"Processing {pdf_path.name}...")
        text = extract_text_from_pdf(pdf_path)
        
        if not text:
            print(f"  Skipping — no text extracted")
            continue
        
        date_str = date_from_filename(pdf_path.name)
        title = make_title_from_date(date_str)
        
        results.append({
            "country": "India",
            "central_bank": "RBI",
            "date": date_str,
            "title": title,
            "text": text,
            "url": f"local_pdf:{pdf_path.name}"
        })
        print(f"  Done — {len(text)} chars")
    
    df = pd.DataFrame(results)
    df.to_csv(OUTPUT_CSV, index=False)
    print(f"\nSaved {len(df)} statements to {OUTPUT_CSV}")
    return df

if __name__ == "__main__":
    df = scrape_pdfs()
    print("\nSample output:")
    print(df[['date', 'title']].to_string())