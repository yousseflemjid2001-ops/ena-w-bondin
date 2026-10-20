import pgdumplib
import pandas as pd

DUMP_PATH = r"c:\ena w bonda\dump-fidness-202608121035 (1).sql"

def get_table_df(dump, table_name):
    # Find entry to get column names from copy_stmt
    entry = None
    for e in dump.entries:
        if e.desc == 'TABLE DATA' and e.tag == table_name:
            entry = e
            break
    if not entry:
        return pd.DataFrame()
    
    # Extract columns from copy_stmt: COPY public.tbl (col1, col2, ...) FROM stdin;
    import re
    m = re.search(r'\((.*?)\)', entry.copy_stmt)
    cols = [c.strip().strip('"') for c in m.group(1).split(',')] if m else []
    
    rows = list(dump.table_data('public', table_name))
    df = pd.DataFrame(rows, columns=cols if cols else None)
    return df

def audit_bondin():
    print("Loading dump...")
    dump = pgdumplib.load(DUMP_PATH)
    
    # 1. Company
    df_comp = get_table_df(dump, 'company')
    print("Companies:\n", df_comp[['id', 'name', 'app_id']])
    
    # 2. Purchase
    df_purch = get_table_df(dump, 'purchase')
    print(f"\nTotal Purchases: {len(df_purch)}")
    print("Purchases per company:\n", df_purch['company_id'].value_counts())
    
    # Bondin purchases
    df_purch_bondin = df_purch[df_purch['company_id'] == '2']
    print(f"\nBondin Purchases: {len(df_purch_bondin)}")
    if not df_purch_bondin.empty:
        print("Bondin Purchase columns:", list(df_purch_bondin.columns))
        print("Bondin Purchase sample:")
        print(df_purch_bondin.head(3).to_dict(orient='records'))
        
        # Amount stats
        df_purch_bondin['amount_num'] = pd.to_numeric(df_purch_bondin['amount'], errors='coerce')
        df_purch_bondin['points_num'] = pd.to_numeric(df_purch_bondin['points'], errors='coerce')
        print(f"Total CA Bondin: {df_purch_bondin['amount_num'].sum():,.2f} TND")
        print(f"Panier Moyen Bondin: {df_purch_bondin['amount_num'].mean():.2f} TND")
        print(f"Total Points attribués: {df_purch_bondin['points_num'].sum():,.0f} pts")
        print(f"Date min: {df_purch_bondin['created_at'].min()} | Date max: {df_purch_bondin['created_at'].max()}")

    # 3. Users
    df_user = get_table_df(dump, 'user')
    print(f"\nTotal Users: {len(df_user)}")
    if 'app_name' in df_user.columns:
        print("Users per app_name:\n", df_user['app_name'].value_counts(dropna=False))
        
    # Bondin users (via app_name == 'bondin' or via purchases)
    bondin_user_ids = set(df_purch_bondin['user_id'].dropna().unique())
    print(f"Distinct users with purchases in Bondin: {len(bondin_user_ids)}")

    # 4. Outlets / Products
    df_outlet = get_table_df(dump, 'outlet')
    print(f"\nTotal Outlets/Articles: {len(df_outlet)}")
    print("Outlets per company:\n", df_outlet['company_id'].value_counts())
    df_outlet_bondin = df_outlet[df_outlet['company_id'] == '2']
    print(f"Bondin Outlets: {len(df_outlet_bondin)}")
    if not df_outlet_bondin.empty:
        print("Sample Bondin Products:\n", df_outlet_bondin[['id', 'reference', 'points']].head(5))

    # 5. Sell points
    df_sp = get_table_df(dump, 'sell_points')
    print(f"\nTotal Sell Points: {len(df_sp)}")
    print("Sell points per company:\n", df_sp['company_id'].value_counts())
    df_sp_bondin = df_sp[df_sp['company_id'] == '2']
    print(f"Bondin Sell points: {len(df_sp_bondin)}")
    if not df_sp_bondin.empty:
        print("Bondin Magasins/POS:\n", df_sp_bondin[['id', 'name', 'code', 'address']])

    # 6. Gifts
    df_gift = get_table_df(dump, 'gift')
    print(f"\nTotal Gifts: {len(df_gift)}")
    print("Gifts per company:\n", df_gift['company_id'].value_counts())
    df_gift_bondin = df_gift[df_gift['company_id'] == '2']
    print(f"Bondin Gifts: {len(df_gift_bondin)}")
    if not df_gift_bondin.empty:
        print("Bondin Gifts:\n", df_gift_bondin[['id', 'title', 'cost_points']])

    # 7. Vouchers (Cadeaux consommés)
    df_vouch = get_table_df(dump, 'voucher')
    print(f"\nTotal Vouchers réclamés: {len(df_vouch)}")
    # Join with gift to see bondin vouchers
    if not df_gift_bondin.empty and not df_vouch.empty:
        df_vouch_bondin = df_vouch[df_vouch['gift_id'].isin(df_gift_bondin['id'])]
        print(f"Bondin Vouchers consommés: {len(df_vouch_bondin)}")
        print("Voucher sample:\n", df_vouch_bondin[['id', 'user_id', 'gift_id', 'claimed', 'created_at']].head(3))

if __name__ == "__main__":
    audit_bondin()
