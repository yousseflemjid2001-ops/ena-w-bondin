import pg8000.native

con = pg8000.native.Connection(
    user='fidness',
    host='57.131.30.69',
    port=5432,
    database='fidness',
    password='6a7ce156b7bc9445'
)

# 1. Monthly Users registered in Bondin
q_users = """
SELECT 
    to_char(u.created_at, 'YYYY-MM') as month,
    count(DISTINCT u.id) as total_users
FROM public."user" u
WHERE u.app_name = 'bondin' 
   OR u.id IN (SELECT user_id FROM public.purchase WHERE company_id = 2)
GROUP BY month
ORDER BY month;
"""
res_u = con.run(q_users)
print("=== BONDIN USERS BY REGISTRATION MONTH ===")
for r in res_u:
    print(f"Mois: {r[0]} | Inscrits: {r[1]}")

# 2. Cohort Retention Matrix exact calculation
# For each cohort month (when user registered), how many distinct users scanned at Bondin (company_id=2)
# in month M+0, M+1, M+2, M+3, M+4, M+5, M+6
q_cohort = """
WITH user_cohort AS (
    SELECT 
        u.id as user_id,
        to_char(u.created_at, 'YYYY-MM') as cohort_month
    FROM public."user" u
    WHERE (u.app_name = 'bondin' OR u.id IN (SELECT user_id FROM public.purchase WHERE company_id = 2))
      AND u.created_at >= '2026-04-01'
),
activity AS (
    SELECT 
        p.user_id,
        to_char(p.created_at, 'YYYY-MM') as scan_month
    FROM public.purchase p
    WHERE p.company_id = 2
    GROUP BY p.user_id, scan_month
)
SELECT 
    uc.cohort_month,
    count(DISTINCT uc.user_id) as cohort_size,
    act.scan_month,
    count(DISTINCT act.user_id) as active_users
FROM user_cohort uc
LEFT JOIN activity act ON uc.user_id = act.user_id
GROUP BY uc.cohort_month, act.scan_month
ORDER BY uc.cohort_month, act.scan_month;
"""
res_c = con.run(q_cohort)
con.close()

data = {}
cohort_sizes = {}
for r in res_c:
    c_m = r[0]
    c_sz = r[1]
    s_m = r[2]
    act_cnt = r[3]
    cohort_sizes[c_m] = c_sz
    if c_m not in data:
        data[c_m] = {}
    if s_m:
        data[c_m][s_m] = act_cnt

months = ['2026-04', '2026-05', '2026-06', '2026-07', '2026-08', '2026-09', '2026-10']

print("\n=== MATRICE DE RÉTENTION CALCULÉE DEPUIS POSTGRESQL LIVE ===")
for c_idx, c_m in enumerate(months):
    sz = cohort_sizes.get(c_m, 0)
    acts = data.get(c_m, {})
    m_rates = []
    for step, s_m in enumerate(months[c_idx:]):
        cnt = acts.get(s_m, 0)
        # Note: In month M+0, how many of them scanned, or if M+0 is normalized to 100%
        # Standard cohort matrix displays M+0 as 100% (baseline) or actual initial active %
        # Let's see both raw active and percentage
        m_rates.append({
            "step": f"M+{step}",
            "month": s_m,
            "active": cnt,
            "pct_of_total": round(cnt / sz * 100, 1) if sz > 0 else 0
        })
    print(f"\nCohorte {c_m} ({sz} inscrits) :")
    for mr in m_rates:
        print(f"  {mr['step']} ({mr['month']}): {mr['active']} actifs -> {mr['pct_of_total']}%")
