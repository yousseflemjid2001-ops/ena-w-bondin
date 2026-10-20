import subprocess

query = 'EVALUATE { SUMX(Fait_Ventes, IFERROR(1 * SUBSTITUTE(Fait_Ventes[Column8], ",", "."), 0)) }'
res = subprocess.run(['pbi', 'dax', 'execute', query], capture_output=True, text=True)
print("STDOUT:", res.stdout)
print("STDERR:", res.stderr)
