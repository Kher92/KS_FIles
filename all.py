import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# 1. DATEN VORBEREITEN
# Daten aus der Excel-Tabelle lesen (angenommen, du hast die Daten als CSV oder Excel)
# Für dieses Beispiel verwenden wir den bereitgestellten Datenausschnitt

# Zuerst erstellen wir einen DataFrame aus den bereitgestellten Daten
df_file = pd.read_excel('ICP_Ã„rzte.xlsx',engine='openpyxl')

data = []

# Header extrahieren
lines = df_file.plot('\n')
header = lines[0].split('|')[1:-1]  # Erste und letzte Spalte sind leer
header = [col.strip() for col in header]

# Datenzeilen extrahieren
for line in lines[1:]:
    if line.strip():
        columns = line.split('|')[1:-1]
        columns = [col.strip() for col in columns]
        data.append(columns)

# DataFrame erstellen
df = pd.DataFrame(data[1:], columns=header)  # data[1:] überspringt die Trennlinie

# Spaltennamen bereinigen
df.columns = [col.replace('<br>', ' ').replace('\n', ' ') for col in df.columns]

# Numerische Spalten konvertieren
numeric_cols = ['Gesamt-OBF kumuliert 2025 November', 
                'Gesamt-Rezept kumuliert 2025 November',
                'Gesamt-Rezept Anteil in % 2025 November',
                'Gesamt kumuliert 2025 November']

for col in numeric_cols:
    df[col] = pd.to_numeric(df[col].str.replace(',', '.'), errors='coerce')

# 2. DATENANALYSE

print("=" * 80)
print("DATENÜBERSICHT")
print("=" * 80)
print(f"Gesamte Anzahl an Einträgen: {len(df)}")
print(f"Anzahl verschiedener Fachrichtungen: {df['Fachrichtung'].nunique()}")
print(f"Anzahl verschiedener Gebiete: {df['Gebietsnummer'].nunique()}\n")

# 3. FÄLLIGKEITSANALYSE (DUPLIKATE)
print("=" * 80)
print("DUPLIKAT-ANALYSE")
print("=" * 80)

# Nach verschiedenen Kriterien auf Duplikate prüfen
duplicate_checks = {
    'ID-Nr': 'ID-Nummer',
    'Name': 'Praxisname',
    'E-Mail': 'E-Mail-Adresse',
    'Telefon': 'Telefonnummer'
}

for col, desc in duplicate_checks.items():
    if col in df.columns:
        duplicates = df[df.duplicated(subset=[col], keep=False)]
        if not duplicates.empty:
            print(f"\nPotenzielle Duplikate basierend auf {desc}:")
            print(f"Anzahl betroffener Einträge: {len(duplicates)}")
            print(f"Betroffene {desc}: {duplicates[col].unique()[:5]}")  # Nur erste 5 zeigen
            if len(duplicates[col].unique()) > 5:
                print(f"... und {len(duplicates[col].unique()) - 5} weitere")
        else:
            print(f"\nKeine Duplikate basierend auf {desc} gefunden.")

# 4. AUSREISSER-ANALYSE
print("\n" + "=" * 80)
print("AUSREISSER-ANALYSE")
print("=" * 80)

# Funktion zur Ausreißer-Erkennung
def detect_outliers(series, threshold=1.5):
    Q1 = series.quantile(0.25)
    Q3 = series.quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - threshold * IQR
    upper_bound = Q3 + threshold * IQR
    outliers = series[(series < lower_bound) | (series > upper_bound)]
    return outliers

# Ausreißer in verschiedenen Metriken finden
metrics = {
    'Gesamt-OBF kumuliert 2025 November': 'OBF-Umsatz',
    'Gesamt-Rezept kumuliert 2025 November': 'Rezept-Umsatz',
    'Gesamt kumuliert 2025 November': 'Gesamtumsatz'
}

for col, desc in metrics.items():
    if col in df.columns:
        outliers = detect_outliers(df[col].dropna())
        if not outliers.empty:
            print(f"\nAusreißer in {desc} ({len(outliers)} Einträge):")
            # Zeige die Top-5 Ausreißer
            top_outliers = df.loc[outliers.index].nlargest(5, col)
            for idx, row in top_outliers.iterrows():
                print(f"  - {row['Name']} ({row['Ort']}): {row[col]:.2f} EUR")
        else:
            print(f"\nKeine Ausreißer in {desc} gefunden.")

# 5. FACHGEBIETSANALYSE
print("\n" + "=" * 80)
print("FACHGEBIETSANALYSE - WELCHE FACHGEBIETE KAUFEN AM BESTEN?")
print("=" * 80)

# Gruppieren nach Fachrichtung
if 'Fachrichtung' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
    specialty_analysis = df.groupby('Fachrichtung').agg({
        'Gesamt kumuliert 2025 November': ['count', 'sum', 'mean', 'median', 'std']
    }).round(2)
    
    specialty_analysis.columns = ['Anzahl Praxen', 'Gesamtumsatz', 'Durchschnitt', 'Median', 'Standardabweichung']
    
    # Sortieren nach Gesamtumsatz
    specialty_analysis = specialty_analysis.sort_values('Gesamtumsatz', ascending=False)
    
    print("\nFachgebiete nach Gesamtumsatz (kumuliert 2025 November):")
    print("-" * 80)
    for specialty, row in specialty_analysis.iterrows():
        print(f"{specialty}:")
        print(f"  Anzahl Praxen: {row['Anzahl Praxen']}")
        print(f"  Gesamtumsatz: {row['Gesamtumsatz']:,.2f} EUR")
        print(f"  Durchschnitt pro Praxis: {row['Durchschnitt']:,.2f} EUR")
        print(f"  Median: {row['Median']:,.2f} EUR")
        print()

# 6. TOP-PRAXEN PRO FACHGEBIET
print("\n" + "=" * 80)
print("TOP-PRAXEN NACH FACHGEBIET")
print("=" * 80)

if 'Fachrichtung' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
    for specialty in df['Fachrichtung'].unique():
        specialty_df = df[df['Fachrichtung'] == specialty]
        top_praxen = specialty_df.nlargest(3, 'Gesamt kumuliert 2025 November')
        
        print(f"\n{specialty} - Top 3 Praxen:")
        print("-" * 40)
        for idx, row in top_praxen.iterrows():
            print(f"1. {row['Name']} ({row['Ort']}): {row['Gesamt kumuliert 2025 November']:,.2f} EUR")
        print(f"Gesamt Praxen in {specialty}: {len(specialty_df)}")
        print(f"Durchschnittsumsatz: {specialty_df['Gesamt kumuliert 2025 November'].mean():,.2f} EUR")

# 7. GEBITETSANALYSE
print("\n" + "=" * 80)
print("GEBIETSANALYSE")
print("=" * 80)

if 'Gebietsnummer' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
    region_analysis = df.groupby('Gebietsnummer').agg({
        'Gesamt kumuliert 2025 November': ['count', 'sum', 'mean']
    }).round(2)
    
    region_analysis.columns = ['Anzahl Praxen', 'Gesamtumsatz', 'Durchschnitt pro Praxis']
    region_analysis = region_analysis.sort_values('Gesamtumsatz', ascending=False)
    
    print("\nTop 10 Gebiete nach Gesamtumsatz:")
    print("-" * 60)
    for idx, row in region_analysis.head(10).iterrows():
        print(f"Gebiet {idx}: {row['Anzahl Praxen']} Praxen, {row['Gesamtumsatz']:,.2f} EUR")
        print(f"  Durchschnitt pro Praxis: {row['Durchschnitt pro Praxis']:,.2f} EUR")

# 8. VISUALISIERUNG (falls matplotlib verfügbar ist)
try:
    print("\n" + "=" * 80)
    print("VISUALISIERUNG")
    print("=" * 80)
    
    # Setze Style für bessere Visualisierungen
    plt.style.use('seaborn-v0_8')
    
    # Erstelle Figure mit Subplots
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # 1. Fachgebiete nach Gesamtumsatz
    if 'Fachrichtung' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
        specialty_sums = df.groupby('Fachrichtung')['Gesamt kumuliert 2025 November'].sum().sort_values(ascending=False)
        axes[0, 0].barh(range(len(specialty_sums)), specialty_sums.values)
        axes[0, 0].set_yticks(range(len(specialty_sums)))
        axes[0, 0].set_yticklabels(specialty_sums.index)
        axes[0, 0].set_xlabel('Gesamtumsatz (EUR)')
        axes[0, 0].set_title('Fachgebiete nach Gesamtumsatz')
        axes[0, 0].invert_yaxis()
    
    # 2. Verteilung der Praxisumsätze
    if 'Gesamt kumuliert 2025 November' in df.columns:
        axes[0, 1].hist(df['Gesamt kumuliert 2025 November'].dropna(), bins=30, edgecolor='black', alpha=0.7)
        axes[0, 1].set_xlabel('Gesamtumsatz (EUR)')
        axes[0, 1].set_ylabel('Anzahl Praxen')
        axes[0, 1].set_title('Verteilung der Praxisumsätze')
        axes[0, 1].axvline(df['Gesamt kumuliert 2025 November'].mean(), color='red', linestyle='--', label='Durchschnitt')
        axes[0, 1].legend()
    
    # 3. Top 10 Praxen
    if 'Name' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
        top_10 = df.nlargest(10, 'Gesamt kumuliert 2025 November')
        axes[1, 0].barh(range(len(top_10)), top_10['Gesamt kumuliert 2025 November'].values)
        axes[1, 0].set_yticks(range(len(top_10)))
        # Kürze Namen für bessere Lesbarkeit
        short_names = [name[:30] + '...' if len(name) > 30 else name for name in top_10['Name']]
        axes[1, 0].set_yticklabels(short_names)
        axes[1, 0].set_xlabel('Gesamtumsatz (EUR)')
        axes[1, 0].set_title('Top 10 Praxen nach Umsatz')
        axes[1, 0].invert_yaxis()
    
    # 4. Boxplot nach Fachgebiet
    if 'Fachrichtung' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
        # Nur Fachgebiete mit mindestens 5 Praxen für bessere Vergleichbarkeit
        specialty_counts = df['Fachrichtung'].value_counts()
        common_specialties = specialty_counts[specialty_counts >= 3].index
        filtered_df = df[df['Fachrichtung'].isin(common_specialties)]
        
        data_to_plot = [filtered_df[filtered_df['Fachrichtung'] == spec]['Gesamt kumuliert 2025 November'].dropna() 
                       for spec in common_specialties]
        
        axes[1, 1].boxplot(data_to_plot, labels=common_specialties)
        axes[1, 1].set_xticklabels(common_specialties, rotation=45, ha='right')
        axes[1, 1].set_ylabel('Gesamtumsatz (EUR)')
        axes[1, 1].set_title('Umsatzverteilung nach Fachgebiet')
    
    plt.tight_layout()
    plt.savefig('arzt_praxis_analyse.png', dpi=300, bbox_inches='tight')
    print("Visualisierung gespeichert als 'arzt_praxis_analyse.png'")
    plt.show()
    
except ImportError as e:
    print(f"Visualisierung nicht verfügbar: {e}")

# 9. ZUSAMMENFASSUNG
print("\n" + "=" * 80)
print("ZUSAMMENFASSUNG DER ERGEBNISSE")
print("=" * 80)

if 'Fachrichtung' in df.columns and 'Gesamt kumuliert 2025 November' in df.columns:
    # Bestes Fachgebiet nach Gesamtumsatz
    best_specialty_total = df.groupby('Fachrichtung')['Gesamt kumuliert 2025 November'].sum().idxmax()
    best_specialty_avg = df.groupby('Fachrichtung')['Gesamt kumuliert 2025 November'].mean().idxmax()
    
    # Beste Praxis
    best_practice = df.loc[df['Gesamt kumuliert 2025 November'].idxmax()]
    
    print(f"1. Bestes Fachgebiet nach Gesamtumsatz: {best_specialty_total}")
    print(f"2. Bestes Fachgebiet nach Durchschnittsumsatz pro Praxis: {best_specialty_avg}")
    print(f"3. Beste Praxis: {best_practice['Name']} in {best_practice['Ort']}")
    print(f"   - Umsatz: {best_practice['Gesamt kumuliert 2025 November']:,.2f} EUR")
    print(f"   - Fachrichtung: {best_practice['Fachrichtung']}")
    
    # Empfehlungen basierend auf den Daten
    print("\nEMPFEHLUNGEN:")
    print("1. Konzentrieren Sie sich auf Fachgebiete mit hohem Durchschnittsumsatz")
    print("2. Identifizieren Sie Top-Performer in jedem Gebiet für gezielte Ansprache")
    print("3. Überprüfen Sie potenzielle Duplikate in der Datenbank")
    print("4. Analysieren Sie Ausreißer für spezielle Erfolgsfaktoren")