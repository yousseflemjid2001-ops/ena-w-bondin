import pg8000.native

con = pg8000.native.Connection(
    user='fidness',
    password='6a7ce156b7bc9445',
    host='57.131.30.69',
    port=5432,
    database='fidness'
)

# Calcul exact des cohortes de rétention
query = """
WITH user_cohort AS (
    SELECT 
        id as user_id, 
        to_char(created_at, 'YYYY-MM') as cohort_month
    FROM public."user"
    WHERE created_at >= '2026-04-01'
),
user_activities AS (
    SELECT 
        user_id,
        to_char(created_at, 'YYYY-MM') as activity_month
    FROM public.purchase
    WHERE company_id = 2
    GROUP BY user_id, activity_month
)
SELECT 
    uc.cohort_month,
    count(DISTINCT uc.user_id) as total_users,
    ua.activity_month,
    count(DISTINCT ua.user_id) as active_users
FROM user_cohort uc
LEFT JOIN user_activities ua ON uc.user_id = ua.user_id
GROUP BY uc.cohort_month, ua.activity_month
ORDER BY uc.cohort_month, ua.activity_month;
"""

rows = con.run(query)
con.close()

data = {}
for r in rows:
    c_m, tot, a_m, act = r[0], r[1], r[2], r[3]
    if c_m not in data:
        data[c_m] = {"total": tot, "activities": {}}
    if a_m:
        data[c_m]["activities"][a_m] = act

months = ['2026-04', '2026-05', '2026-06', '2026-07', '2026-08', '2026-09', '2026-10']

print("COHORTES CALCULÉES :")
for c_m in months:
    if c_m in data:
        tot = data[c_m]["total"]
        acts = data[c_m]["activities"]
        rates = []
        c_idx = months.index(c_m)
        for i in range(c_idx, len(months)):
            target_m = months[i]
            active_cnt = acts.get(target_m, 0)
            pct = round(active_cnt / tot * 100, 1) if tot > 0 else 0
            rates.append((f"M+{i - c_idx}", pct, active_cnt))
        print(f"Cohorte {c_m} ({tot} inscrits) : {rates}")
