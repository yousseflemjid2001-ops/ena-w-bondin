import time
import pg8000.native
import pandas as pd

t0 = time.time()
con = pg8000.native.Connection(
    user='fidness',
    host='57.131.30.69',
    port=5432,
    database='fidness',
    password='6a7ce156b7bc9445'
)
print(f"Connected in {time.time() - t0:.2f}s")

t1 = time.time()
purchases = con.run("""
    SELECT 
        id as "ID_Transaction",
        user_id,
        sell_point_id as "ID_Magasin",
        to_char(created_at, 'YYYY-MM-DD') as "Date",
        to_char(created_at, 'HH24:MI:SS') as "Heure",
        ticket as "ID_Ticket",
        purchase_type as "Type_Achat",
        round((amount / 1000.0)::numeric, 3) as "Montant_TND",
        coalesce(points, 0) as "Points_Gagnes",
        created_at
    FROM public.purchase
    WHERE company_id = 2
    ORDER BY created_at ASC;
""")
print(f"Fetched {len(purchases)} purchases in {time.time() - t1:.2f}s")
con.close()
