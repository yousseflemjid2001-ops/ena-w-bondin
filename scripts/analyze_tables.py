import re
import pandas as pd
import io

DUMP_PATH = r"c:\ena w bonda\dump-fidness-202608121035 (1).sql"

def parse_copy_data(content, table_name):
    pattern = rf'COPY public\.("?{table_name}"?)\s*\((.*?)\)\s*FROM stdin;\n(.*?)\n\\\.'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        print(f"Table {table_name}: No COPY data found")
        return None
    cols = [c.strip().strip('"') for c in match.group(2).split(',')]
    data_text = match.group(3)
    if not data_text.strip():
        print(f"Table {table_name}: 0 rows")
        return pd.DataFrame(columns=cols)
    
    # Read tab-delimited postgres dump
    df = pd.read_csv(io.StringIO(data_text), sep='\t', names=cols, na_values=['\\N'], low_memory=False)
    print(f"Table {table_name}: {len(df)} rows, columns: {cols}")
    return df

def main():
    print("Reading dump...")
    with open(DUMP_PATH, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    target_tables = [
        '"user"',
        'purchase',
        'store_purchase',
        'store_order',
        'store_product',
        'store_category',
        'gift',
        'voucher',
        'user_card',
        'history',
        'sponsorship',
        'sell_points'
    ]
    
    dfs = {}
    for t in target_tables:
        clean_name = t.strip('"')
        df = parse_copy_data(content, clean_name)
        if df is not None:
            dfs[clean_name] = df
            print(f"\nSample from {clean_name}:")
            print(df.head(2).to_dict(orient='records'))
            print("-" * 50)

if __name__ == "__main__":
    main()
