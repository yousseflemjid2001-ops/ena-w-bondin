import pg8000.native

def inspect_all():
    con = pg8000.native.Connection(
        database="fidness",
        host="57.131.30.69",
        port=5432,
        user="fidness",
        password="6a7ce156b7bc9445",
        timeout=15
    )
    
    # 1. sell_points
    sp_cols = [r[0] for r in con.run("SELECT column_name FROM information_schema.columns WHERE table_name = 'sell_points'")]
    print("Columns in 'sell_points':", sp_cols)
    try:
        sp_rows = con.run("SELECT * FROM public.sell_points LIMIT 5")
        for r in sp_rows:
            print("  sell_point:", dict(zip(sp_cols, r)))
    except Exception as e:
        print("Error sell_points:", e)

    # 2. user
    u_cols = [r[0] for r in con.run("SELECT column_name FROM information_schema.columns WHERE table_name = 'user'")]
    print("\nColumns in 'user':", u_cols)
    
    # 3. purchase sample
    p_cols = [r[0] for r in con.run("SELECT column_name FROM information_schema.columns WHERE table_name = 'purchase'")]
    print("\nColumns in 'purchase':", p_cols)
    p_rows = con.run("SELECT * FROM public.purchase WHERE company_id = 2 ORDER BY created_at DESC LIMIT 3")
    for r in p_rows:
        print("  recent purchase:", dict(zip(p_cols, r)))

    # 4. total CA and points in live DB for Bondin
    stats = con.run("""
        SELECT 
            count(*) as total_scans,
            sum(amount) as total_ca,
            avg(amount) as avg_basket,
            sum(points) as total_points,
            count(distinct user_id) as unique_users,
            min(created_at) as first_scan,
            max(created_at) as last_scan
        FROM public.purchase 
        WHERE company_id = 2
    """)
    s = stats[0]
    print("\n=== BONDIN LIVE STATS (from PostgreSQL 57.131.30.69) ===")
    print(f"  Total scans: {s[0]:,}")
    print(f"  Total CA (TND): {float(s[1] or 0):,.2f}")
    print(f"  Panier moyen (AOV): {float(s[2] or 0):,.2f}")
    print(f"  Total points émis: {int(s[3] or 0):,}")
    print(f"  Clients uniques actifs: {s[4]:,}")
    print(f"  Période: {s[5]} à {s[6]}")

    con.close()

if __name__ == "__main__":
    inspect_all()
