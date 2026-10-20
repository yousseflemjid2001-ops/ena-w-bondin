import pandas as pd

df = pd.read_csv('data_dwh/Fait_Ventes_Fidelite.csv')
df['DateTime'] = pd.to_datetime(df['Date'] + ' ' + df['Heure'])
df['Day'] = df['DateTime'].dt.day_name()
df['Hour'] = df['DateTime'].dt.hour

def get_slot(h):
    if 7 <= h < 10: return '07h - 10h'
    if 10 <= h < 12: return '10h - 12h'
    if 12 <= h < 14: return '12h - 14h'
    if 14 <= h < 17: return '14h - 17h'
    if 17 <= h < 20: return '17h - 20h'
    return '20h - 23h'

df['Slot'] = df['Hour'].apply(get_slot)
slots = ['07h - 10h', '10h - 12h', '12h - 14h', '14h - 17h', '17h - 20h', '20h - 23h']
day_map = {
    'Monday': 'Lundi', 
    'Tuesday': 'Mardi', 
    'Wednesday': 'Mercredi', 
    'Thursday': 'Jeudi', 
    'Friday': 'Vendredi', 
    'Saturday': 'Samedi', 
    'Sunday': 'Dimanche'
}
days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

ct = pd.crosstab(df['Day'], df['Slot']).reindex(index=days_order, columns=slots, fill_value=0)
print("DAYS DATA HEATMAP:")
for d in days_order:
    vals = list(ct.loc[d])
    print(f"{{ day: \"{day_map[d]}\", values: {vals} }}, // Total: {sum(vals)}")
