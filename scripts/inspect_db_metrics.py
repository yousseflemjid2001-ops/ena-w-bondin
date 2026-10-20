import pg8000.native

con = pg8000.native.Connection(
    user='fidness',
    password='6a7ce156b7bc9445',
    host='57.131.30.69',
    port=5432,
    database='fidness'
)

print("--- PURCHASES BONDIN (company_id = 2) ---")
res = con.run("SELECT min(created_at), max(created_at), count(*) FROM public.purchase WHERE company_id = 2")
print("Min, Max, Count:", res)

res2 = con.run("""
    SELECT to_char(created_at, 'YYYY-MM') as m, count(*), sum(amount), count(distinct user_id) 
    FROM public.purchase 
    WHERE company_id = 2 
    GROUP BY m 
    ORDER BY m
""")
print("\nPar Mois (Achats Bondin) :")
for r in res2:
    amt = float(r[2]) / 1000.0 if float(r[2]) > 100000 else float(r[2])
    print(f"Mois: {r[0]} | Scans: {r[1]} | CA (TND): {amt:.2f} | Clients Actifs: {r[3]}")

print("\n--- UTILISATEURS TOTAUX PAR MOIS ---")
res3 = con.run("""
    SELECT to_char(created_at, 'YYYY-MM') as m, count(*) 
    FROM public."user" 
    GROUP BY m 
    ORDER BY m
""")
for r in res3:
    print(f"Mois Inscription: {r[0]} | Nouveaux Utilisateurs: {r[1]}")

print("\n--- UTILISATEURS AYANT FAIT UN ACHAT BONDIN (PAR PREMIER ACHAT BONDIN) ---")
res4 = con.run("""
    WITH first_purchase AS (
        SELECT user_id, min(created_at) as first_date
        FROM public.purchase
        WHERE company_id = 2
        GROUP BY user_id
    )
    SELECT to_char(first_date, 'YYYY-MM') as cohort_month, count(*)
    FROM first_purchase
    GROUP BY cohort_month
    ORDER BY cohort_month
""")
for r in res4:
    print(f"Première visite Bondin {r[0]} : {r[1]} clients")

con.close()
