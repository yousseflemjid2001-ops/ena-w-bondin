import re
import os

DUMP_PATH = r"c:\ena w bonda\dump-fidness-202608121035 (1).sql"

def inspect_dump():
    print(f"Reading {DUMP_PATH}...")
    with open(DUMP_PATH, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # Find CREATE TABLE public.xxx
    table_pattern = re.compile(r'CREATE TABLE public\.(\w+)\s*\((.*?)\);', re.DOTALL)
    tables = {}
    for match in table_pattern.finditer(content):
        tname = match.group(1)
        body = match.group(2)
        # Extract column definitions
        cols = []
        for line in body.split('\n'):
            line = line.strip().rstrip(',')
            if line and not line.startswith('CONSTRAINT') and not line.startswith('PRIMARY KEY'):
                col_name = line.split()[0]
                cols.append(line)
        tables[tname] = cols

    print(f"Found {len(tables)} tables:")
    for tname, cols in sorted(tables.items()):
        print(f"\n--- TABLE: {tname} ({len(cols)} columns) ---")
        for col in cols[:8]:
            print(f"  {col}")
        if len(cols) > 8:
            print(f"  ... (+ {len(cols) - 8} more columns)")

    # Find COPY public.xxx or INSERT INTO
    copy_pattern = re.compile(r'COPY public\.(\w+)\s*\((.*?)\)\s*FROM stdin;', re.DOTALL)
    copy_matches = list(copy_pattern.finditer(content))
    print(f"\nFound {len(copy_matches)} COPY data sections:")
    for m in copy_matches:
        tname = m.group(1)
        cols = m.group(2).replace('\n', ' ').strip()
        # Find start of data
        start_idx = m.end()
        end_idx = content.find('\\.', start_idx)
        if end_idx != -1:
            data_chunk = content[start_idx:end_idx].strip()
            row_count = len(data_chunk.split('\n')) if data_chunk else 0
            print(f"  - {tname}: {row_count} rows. Cols: {cols}")
        else:
            print(f"  - {tname}: (data block end not found)")

if __name__ == "__main__":
    inspect_dump()
