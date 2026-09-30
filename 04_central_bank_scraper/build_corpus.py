"""Rebuild the final corpus from saved extracts without contacting source websites."""
from pathlib import Path
import argparse
import pandas as pd

DATA = Path(__file__).resolve().parent / 'data'
COLUMNS = ['country', 'central_bank', 'date', 'title', 'text', 'url']


def build_corpus(data_dir=DATA):
    frames = [pd.read_csv(data_dir / name) for name in (
        'rbi_statements.csv', 'rbi_historical.csv', 'cbr_statements.csv',
        'sarb_statements.csv', 'pboc_statements.csv')]
    corpus = pd.concat([frame[COLUMNS] for frame in frames], ignore_index=True)
    # Keep first occurrence: RBI archive returned the same six URLs in many years.
    corpus = corpus.drop_duplicates(['central_bank', 'url'], keep='first')
    if corpus[COLUMNS].isna().any().any():
        raise ValueError('Missing required fields: inspect extracts before publishing.')
    if corpus['text'].str.strip().eq('').any():
        raise ValueError('Empty document text: inspect failed extraction.')
    if corpus.duplicated(['central_bank', 'text']).any():
        raise ValueError('Duplicate text under different URLs: manual review required.')
    return corpus.reset_index(drop=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=DATA / 'brics_mpc_statements_v2.csv')
    args = parser.parse_args()
    corpus = build_corpus()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    corpus.to_csv(args.output, index=False)
    print(corpus.groupby('central_bank').size().to_string())
    print(f'Saved {len(corpus)} communications to {args.output}')
