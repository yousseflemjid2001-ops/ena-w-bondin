import os
import re
import csv
import pandas as pd

DUMP_PATH = r"c:\ena w bonda\dump-fidness-202608121035 (1).sql"

def parse_dump_to_dfs():
    print("Reading SQL dump line by line...")
    tables_data = {}
    current_table = None
    current_cols = []
    current_rows = []
    
    copy_re = re.compile(r'^COPY public\.("?\w+"?)\s*\((.*?)\)\s*FROM stdin;', re.IGNORECASE)
    
    with open(DUMP_PATH, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line_str = line.rstrip('\r\n')
            
            if current_table is not None:
                if line_str == r'\.':
                    # End of current table data
                    print(f"Parsed {current_table}: {len(current_rows)} records")
                    df = pd.DataFrame(current_rows, columns=current_cols)
                    # Replace \N with None/NaN
                    df = df.replace(r'\N', None)
                    tables_data[current_table] = df
                    current_table = None
                    current_cols = []
                    current_rows = []
                else:
                    # Line is tab-separated values
                    # Split on tab
                    parts = line_str.split('\t')
                    current_rows.append(parts)
            else:
                m = copy_re.match(line_str)
                if m:
                    tname = m.group(1).replace('"', '')
                    cols = [c.strip().replace('"', '') for c in m.group(2).split(',')]
                    current_table = tname
                    current_cols = cols
                    current_rows = []
                    
    return tables_data

def summarize(tables_data):
    print("\n" + "="*60)
    print("RESUME DES TABLES DE DONNEES DU PROJET ENA W BONDIN")
    print("="*60)
    for name, df in sorted(tables_data.items()):
        print(f"\n📦 Table: {name} (Total lignes: {len(df)})")
        print(f"   Colonnes ({len(df.columns)}): {list(df.columns)}")
        if not df.empty:
            print("   Exemple (1ère ligne):")
            sample = {k: v for k, v in df.iloc[0].to_dict().items() if v is not None}
            print(f"   {sample}")

if __name__ == "__main__":
    data = parse_dump_to_dfs()
    summarize(data)
