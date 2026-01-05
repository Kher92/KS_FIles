import pandas as pd
import urllib.parse
from sqlalchemy import create_engine
import os
import sys
from sqlalchemy import text
import warnings
from sqlalchemy import exc

# Warnungen unterdrücken
warnings.filterwarnings("ignore", category=exc.SAWarning, message=".*will not produce anything")

# Konfiguration
DB_SERVER = 'gemini-sql2'
DATABASE = 'GEMINI_PSEUDO'
SQL_SKRIPT_ORDNER = r"E:\GEMINI_PSEUDO\Auszählungen" 

def get_connection():
    print("Verbindungsaufbau zur Datenbank...")
    try:
        conn_string = f"Driver={{ODBC Driver 17 for SQL Server}};Server={DB_SERVER};Database={DATABASE};Trusted_Connection=yes;"
        quoted_conn_string = urllib.parse.quote_plus(conn_string)
        engine = create_engine(f"mssql+pyodbc:///?odbc_connect={quoted_conn_string}")
        print("✅ Verbindung hergestellt.")
        return engine
    except Exception as e:
        print(f"❌ FEHLER beim Verbindungsaufbau: {e}")
        sys.exit(1)

def run_complex_age_report(engine, ages, gender):
    """
    Baut das komplexe SQL-Skript mit 6 Joins dynamisch auf Basis der Nutzerwahl.
    """
    # 1. SELECT-Teil dynamisch generieren (z.B. mb012_p.[60-75])
    prefixes = ['mb012_p', 'mb012', 'mb024_p', 'mb024', 'mb024_p_rest', 'mb024_rest']
    select_parts = []
    for p in prefixes:
        for a in ages:
            select_parts.append(f"{p}.[{a.strip()}]")
    
    select_sql = ", ".join(select_parts)
    
    # 2. PIVOT-Teil (die Altersklassen-Liste)
    pivot_ages = ", ".join([f"[{a.strip()}]" for a in ages])

    # 3. Das große SQL-Template
    query = f"""
    SELECT 
        mb012_p.seg_kgm,
        {select_sql}
    FROM 
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb012_P = 1 AND synergie >= 1
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb012_p,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb012 = 1 AND synergie >= 1 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) p) mb012,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb024_p = 1 AND synergie >= 1
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024_p,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb024 = 1 AND synergie >= 1 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb024_p IS NULL AND synergie >= 1 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024_p_rest,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM [2025-10-14-108_Nutrisana]
        WHERE mb024 IS NULL AND synergie >= 1 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024_rest
    
    WHERE 
        mb012_p.GENDERTYPEID=mb012.GENDERTYPEID AND mb012.GENDERTYPEID=mb024_p.GENDERTYPEID 
        AND mb024_p.GENDERTYPEID=mb024.GENDERTYPEID AND mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
        AND mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
        AND mb012_p.seg_kgm=mb012.seg_kgm AND mb012.seg_kgm=mb024_p.seg_kgm 
        AND mb024_p.seg_kgm=mb024.seg_kgm AND mb024.seg_kgm=mb024_p_rest.seg_kgm 
        AND mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
        AND mb012_p.gendertypeid = {gender}
    ORDER BY mb012_p.seg_kgm
    """
    
    with engine.connect() as conn:
        df = pd.read_sql(text(query), conn)
    return df

def main():
    engine = get_connection()

    print("\n--- Parameter für den Nutrisana-Report ---")
    
    # 1. Geschlecht abfragen
    gender = input("Gendertype wählen (1 = Männer, 2 = Frauen): ").strip()
    if gender not in ["1", "2"]:
        print("Ungültige Wahl. Abbruch.")
        return

    # 2. Altersklassen abfragen
    print("Bitte Altersklassen eingeben, getrennt durch Komma (z.B. 60-75, 75+, 90-95)")
    age_input = input("Eingabe: ")
    if not age_input:
        print("Keine Altersklassen angegeben. Abbruch.")
        return
        
    ages = [a.strip() for a in age_input.split(",")]

    # 3. SQL ausführen
    try:
        print("\nAbfrage wird ausgeführt... Bitte warten.")
        df_result = run_complex_age_report(engine, ages, gender)
        
        if df_result.empty:
            print("Keine Daten für diese Auswahl gefunden.")
        else:
            print(f"\n✅ Erfolg! {len(df_result)} Zeilen geladen.")
            
            # 4. Speichern als CSV
            gender_name = "Maenner" if gender == "1" else "Frauen"
            date_str = "2026-01-05" # Statisch oder via datetime.now()
            filename = f"Nutrisana_Report_{gender_name}_{date_str}.csv"
            
            df_result.to_csv(filename, index=False, sep=";", encoding="utf-8-sig")
            print(f"Datei wurde gespeichert: {os.getcwd()}\\{filename}")
            
            # Kurze Vorschau
            print("\nVorschau der ersten Zeilen:")
            print(df_result.head())

    except Exception as e:
        print(f"\n❌ Fehler während der SQL-Ausführung: {e}")

if __name__ == "__main__":
    main()