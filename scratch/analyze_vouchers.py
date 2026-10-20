import pgdumplib, re
import pandas as pd

dump = pgdumplib.load(r"c:\ena w bonda\dump-fidness-202608121035 (1).sql")

def get_df(tag):
    for e in dump.entries:
        if e.desc == 'TABLE DATA' and e.tag == tag:
            m = re.search(r'\((.*?)\)', e.copy_stmt)
            cols = [c.strip().strip('"') for c in m.group(1).split(',')] if m else []
            rows = list(dump.table_data('public', tag))
            return pd.DataFrame(rows, columns=cols)
    return pd.DataFrame()

vouchers = get_df('voucher')
gifts = get_df('gift')
sp = get_df('sell_points')
purchases = get_df('purchase')

bondin_gifts = gifts[gifts['company_id'] == '2']
bondin_vouchers = vouchers[vouchers['gift_id'].isin(bondin_gifts['id'])].copy()
bondin_sp = sp[sp['company_id'] == '2'].copy()
bondin_purch = purchases[purchases['company_id'] == '2'].copy()

print(f"Total Bondin Gifts in catalog: {len(bondin_gifts)}")
print(f"Total Bondin Vouchers: {len(bondin_vouchers)}")
print(f"Total Bondin Sell Points: {len(bondin_sp)}")
print(f"Total Bondin Purchases: {len(bondin_purch)}")

print("\nVoucher sell_point_id distribution:")
print(bondin_vouchers['sell_point_id'].value_counts(dropna=False))

# Merge vouchers with sell_points
merged_v = pd.merge(bondin_vouchers, bondin_sp[['id', 'name', 'code', 'pos_location']], left_on='sell_point_id', right_on='id', how='left')
print("\nVouchers per Point de Vente:")
print(merged_v['name'].value_counts(dropna=False))

# Also check user_id who claimed gifts and where they made purchases!
# If sell_point_id in voucher is null, we can check where the user scans/shops!
null_v = bondin_vouchers[bondin_vouchers['sell_point_id'].isna() | (bondin_vouchers['sell_point_id'] == '') | (bondin_vouchers['sell_point_id'] == 'None')]
print(f"Vouchers with NULL sell_point_id: {len(null_v)}")

# Purchases per sell_point
purch_sp = bondin_purch.groupby('sell_point_id').agg(
    Scans=('id', 'count'),
    Total_Points=('points', lambda x: pd.to_numeric(x, errors='coerce').sum()),
    Total_Montant=('amount', lambda x: pd.to_numeric(x, errors='coerce').sum() / 1000.0)
).reset_index()

purch_sp = pd.merge(purch_sp, bondin_sp[['id', 'name', 'code']], left_on='sell_point_id', right_on='id', how='left')
purch_sp = purch_sp.sort_values(by='Total_Montant', ascending=False)
print("\nPoints de vente summary (Purchases / Earn):")
print(purch_sp[['id_x', 'name', 'Scans', 'Total_Montant', 'Total_Points']].to_string())
