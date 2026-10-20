import pg8000.native
import json

con = pg8000.native.Connection(
    user='fidness',
    password='6a7ce156b7bc9445',
    host='57.131.30.69',
    port=5432,
    database='fidness'
)

# 1. Monthly revenue split by store type (Succursale vs Cafeteria)
q_monthly = """
SELECT 
    to_char(p.created_at, 'YYYY-MM') as month,
    case 
        when lower(s.name) like '%caf%' then 'Cafétéria'
        when lower(s.name) like '%succ%' then 'Succursale'
        else 'Autre'
    end as store_type,
    count(*) as nb_scans,
    sum(p.amount) as total_amount,
    count(distinct p.user_id) as unique_users
FROM public.purchase p
LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
WHERE p.company_id = 2
GROUP BY month, store_type
ORDER BY month, store_type;
"""
res_monthly = con.run(q_monthly)
print("=== MONTHLY SALES BY STORE TYPE ===")
for r in res_monthly:
    amt = float(r[3]) / 1000.0 if float(r[3]) > 100000 else float(r[3])
    print(f"Mois: {r[0]} | Type: {r[1]} | Scans: {r[2]} | CA: {amt:.2f} TND | Clients: {r[4]}")

# 2. Overall Monthly Summary
q_monthly_tot = """
SELECT 
    to_char(p.created_at, 'YYYY-MM') as month,
    count(*) as nb_scans,
    sum(p.amount) as total_amount,
    count(distinct p.user_id) as unique_users
FROM public.purchase p
WHERE p.company_id = 2
GROUP BY month
ORDER BY month;
"""
res_tot = con.run(q_monthly_tot)
print("\n=== MONTHLY TOTALS ===")
for r in res_tot:
    amt = float(r[2]) / 1000.0 if float(r[2]) > 100000 else float(r[2])
    print(f"Mois: {r[0]} | Scans: {r[1]} | CA: {amt:.2f} TND | Clients: {r[3]}")

# 3. Top Stores All-Time (company_id = 2)
q_stores = """
SELECT 
    coalesce(s.name, 'Point de Vente inconnu') as name,
    case 
        when lower(s.name) like '%caf%' then 'Cafétéria'
        else 'Succursale'
    end as store_type,
    count(*) as scans,
    sum(p.amount) as ca
FROM public.purchase p
LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
WHERE p.company_id = 2
GROUP BY s.name
ORDER BY ca DESC
LIMIT 15;
"""
res_stores = con.run(q_stores)
print("\n=== TOP STORES ===")
for r in res_stores:
    amt = float(r[3]) / 1000.0 if float(r[3]) > 100000 else float(r[3])
    print(f"Store: {r[0]} ({r[1]}) | Scans: {r[2]} | CA: {amt:.2f} TND")

con.close()
