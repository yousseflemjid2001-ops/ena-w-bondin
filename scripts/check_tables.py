import pg8000.native

con = pg8000.native.Connection(
    user='fidness',
    host='57.131.30.69',
    port=5432,
    database='fidness',
    password='6a7ce156b7bc9445'
)
tables = ['user', 'purchase', 'sell_points', 'outlet', 'gift', 'voucher', 'history', 'sponsorship']
for t in tables:
    try:
        cnt = con.run(f'SELECT count(*) FROM public."{t}"')[0][0]
        cnt_bondin = None
        try:
            cnt_bondin = con.run(f'SELECT count(*) FROM public."{t}" WHERE company_id = 2')[0][0]
        except:
            pass
        print(f"Table {t}: total={cnt}, bondin={cnt_bondin}")
    except Exception as e:
        print(f"Table {t}: error {e}")
con.close()
