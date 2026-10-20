import pg8000.native

con = pg8000.native.Connection(
    user='fidness',
    password='6a7ce156b7bc9445',
    host='57.131.30.69',
    port=5432,
    database='fidness'
)

print('--- MOIS D INSCRIPTION UTILISATEURS ---')
sql_users = 'SELECT to_char(created_at, \'YYYY-MM\') as m, count(*) FROM public."user" GROUP BY m ORDER BY m'
for r in con.run(sql_users):
    print(r)

print('\n--- MOIS DES ACHATS BONDIN (PURCHASE) ---')
sql_purch = 'SELECT to_char(created_at, \'YYYY-MM\') as m, count(*), round(sum(amount)::numeric, 2) FROM public.purchase WHERE company_id = 2 GROUP BY m ORDER BY m'
for r in con.run(sql_purch):
    print(r)

con.close()
