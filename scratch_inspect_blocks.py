with open('index.html', 'r', encoding='utf-8') as f:
    c = f.read()

s_cockpit_start = c.find('id="tab-cockpit"')
s2_header = c.find('SECTION 2 : R', s_cockpit_start)
# find start of comment before s2
s2_block_start = c.rfind('<!--', 0, s2_header)

s3_header = c.find('SECTION 3 : DYNAMIQUE', s_cockpit_start)
s3_block_start = c.rfind('<!--', 0, s3_header)

s4_header = c.find('SECTION 4 : D', s_cockpit_start)
s4_block_start = c.rfind('<!--', 0, s4_header)

s_decomp = c.find('<!-- Module IA CDC : Arbre de D', s_cockpit_start)
s_whatif = c.find('<!-- Simulateur DAX What-If -->', s_cockpit_start)
s_cockpit_end = c.find('</section>', s_whatif)

print('s2_block_start:', s2_block_start)
print('s3_block_start:', s3_block_start)
print('s4_block_start:', s4_block_start)
print('s_decomp:', s_decomp)
print('s_whatif:', s_whatif)
print('s_cockpit_end:', s_cockpit_end)

print('\n--- S2 snippet ---')
print(c[s2_block_start:s2_block_start+150])

print('\n--- S3 snippet ---')
print(c[s3_block_start:s3_block_start+150])

print('\n--- S4 snippet ---')
print(c[s4_block_start:s4_block_start+150])
