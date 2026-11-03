with open('index.html', 'r', encoding='utf-8') as f:
    c = f.read()

s_decomp = c.find('<!-- Module IA CDC : Arbre de D')
s_next_tab = c.find('id="tab-segmentation"')
s_tab_cockpit_close = c.rfind('</section>', 0, s_next_tab)

print('s_decomp:', s_decomp)
print('s_tab_cockpit_close:', s_tab_cockpit_close)
print('\nContent around s_tab_cockpit_close:')
print(c[s_tab_cockpit_close-200:s_tab_cockpit_close+50])
