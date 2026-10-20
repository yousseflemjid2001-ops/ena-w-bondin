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

bondin_gifts = gifts[gifts['company_id'] == '2'].copy()
bondin_vouchers = vouchers[vouchers['gift_id'].isin(bondin_gifts['id'])].copy()
bondin_sp = sp[sp['company_id'] == '2'].copy()
bondin_purch = purchases[purchases['company_id'] == '2'].copy()

# Add points cost to voucher
bondin_gifts['cost_points_num'] = pd.to_numeric(bondin_gifts['cost_points'], errors='coerce').fillna(0)
bondin_vouchers = pd.merge(bondin_vouchers, bondin_gifts[['id', 'title', 'cost_points_num']], left_on='gift_id', right_on='id', how='left')

# Purchases aggregation by sell_point_id
purch_sp = bondin_purch.groupby('sell_point_id').agg(
    Scans=('id', 'count'),
    Total_Points=('points', lambda x: pd.to_numeric(x, errors='coerce').sum()),
    Total_Montant=('amount', lambda x: pd.to_numeric(x, errors='coerce').sum() / 1000.0)
).reset_index()

# Vouchers aggregation by sell_point_id
vouch_sp = bondin_vouchers.groupby('sell_point_id').agg(
    Cadeaux_Delivres=('id_x', 'count'),
    Points_Brule=('cost_points_num', 'sum')
).reset_index()

# Merge with sell_points
table_sp = pd.merge(bondin_sp, purch_sp, left_on='id', right_on='sell_point_id', how='left')
table_sp = pd.merge(table_sp, vouch_sp, left_on='id', right_on='sell_point_id', how='left')

table_sp['Scans'] = table_sp['Scans'].fillna(0).astype(int)
table_sp['Total_Montant'] = table_sp['Total_Montant'].fillna(0.0)
table_sp['Total_Points'] = table_sp['Total_Points'].fillna(0.0)
table_sp['Cadeaux_Delivres'] = table_sp['Cadeaux_Delivres'].fillna(0).astype(int)
table_sp['Points_Brule'] = table_sp['Points_Brule'].fillna(0.0)

# Taux de conversion: Cadeaux / Scans %
table_sp['Taux_Conversion_Pct'] = (table_sp['Cadeaux_Delivres'] / table_sp['Scans'].replace(0, 1)) * 100
# Taux de Burn / Earn %
table_sp['Taux_Burn_Earn_Pct'] = (table_sp['Points_Brule'] / table_sp['Total_Points'].replace(0, 1)) * 100

def get_type(name):
    n = str(name).lower()
    return 'Succursale' if 'succursale' in n else 'Cafétéria'

table_sp['Type'] = table_sp['name'].apply(get_type)

table_sp = table_sp.sort_values(by='Cadeaux_Delivres', ascending=False)

print("POINT DE VENTE PERFORMANCE : DISTRIBUTION CADEAUX & VENTES")
for _, r in table_sp.iterrows():
    print(f"ID {r['id']:2} | {r['name']:28} | Type: {r['Type']:10} | Scans: {r['Scans']:4} | CA: {r['Total_Montant']:8.2f} TND | Cadeaux: {r['Cadeaux_Delivres']:2} | Pts Brûlés: {r['Points_Brule']:6.0f} | Conv: {r['Taux_Conversion_Pct']:4.2f}%")
