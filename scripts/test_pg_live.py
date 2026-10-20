import pg8000.native

def inspect_db():
    con = pg8000.native.Connection(
        database="fidness",
        host="57.131.30.69",
        port=5432,
        user="fidness",
        password="6a7ce156b7bc9445",
        timeout=15
    )
    tables = [r[0] for r in con.run("SELECT table_name FROM information_schema.tables WHERE table_schema='public'")]
    print(f"=== DATABASE FIDNESS (57.131.30.69) : {len(tables)} TABLES ===")
    for t in sorted(tables):
        try:
            cnt = con.run(f'SELECT count(*) FROM public."{t}"')[0][0]
            print(f"  {t:32s} : {cnt:>8} rows")
        except Exception as e:
            print(f"  {t:32s} : ERROR {e}")
            
    # Check companies
    try:
        companies = con.run('SELECT id, name FROM public.company LIMIT 10')
        print("\n=== COMPANIES ===")
        for c in companies:
            print(f"  ID: {c[0]}, Name: {c[1]}")
    except Exception as e:
        print("Company query error:", e)

    # Check recent purchases
    try:
        recent = con.run('SELECT max(created_at), min(created_at) FROM public.purchase')
        print(f"\n=== PURCHASES (SCANS) DATE RANGE ===")
        print(f"  Min date: {recent[0][1]} | Max date (most recent): {recent[0][0]}")
    except Exception as e:
        print("Purchase date range error:", e)

    con.close()

if __name__ == "__main__":
    inspect_db()
