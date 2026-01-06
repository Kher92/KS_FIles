import pandas as pd
import urllib.parse
from sqlalchemy import create_engine ,exc,text
import os
import sys
import warnings
import datetime
warnings.filterwarnings("ignore", category=exc.SAWarning, message=".*will not produce anything")

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
def build_sql_map(sql_folder):

    sql_map = {}

    for root, dirs, files in os.walk(sql_folder):
        for file in files:
            if file.lower().endswith(".sql"):
                name_only = os.path.splitext(file)[0].lower()
                full_path = os.path.join(root, file)
                sql_map[name_only] = full_path

    return sql_map
  
def run_complex_age_report(engine, ages, gender,skript,filter_type):
    if filter_type =='synergie' :
        types = "AND synergie >=1" 
    elif filter_type =='syn012':
        types ="AND syn012 >=1"  
    else:
        types = ""      

    prefixes = ['mb012_p', 'mb012', 'mb024_p', 'mb024', 'mb024_p_rest', 'mb024_rest']
    select_parts = []
    for p in prefixes:
        for a in ages:
            select_parts.append(f"{p}.[{a.strip()}]")
           
    
    select_sql = ", ".join(select_parts)
   
    

    pivot_ages = ", ".join([f"[{a.strip()}]" for a in ages])
  

    query = f"""
    SELECT 
        mb012_p.seg_kgm,
        {select_sql}
    FROM 
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb012_P = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb012_p,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb012 = 1 {types} 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) p) mb012,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb024_p = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024_p,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb024 = 1 {types} 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb024_p IS NULL {types} 
    ) b PIVOT(COUNT(urngem) FOR alter_kl IN ({pivot_ages})) P) mb024_p_rest,
    
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, alter_kl, urngem FROM {skript}
        WHERE mb024 IS NULL {types} 
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
    sql_map = build_sql_map(SQL_SKRIPT_ORDNER)
    
    if not sql_map:
        print("Keine Skripts im Ordner vorhanden.")
        return

    sql_eingabe = input("\nWelches Skript möchtest du ausführen? \n").lower()
    if sql_eingabe not in sql_map:
        print("Das Skript existiert nicht")
        return

    datum_heute = datetime.date.today().strftime("%Y-%m-%d")
    excel_file = f"Report_{sql_eingabe}_{datum_heute}.xlsx"



    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        
        while True:
            print("\n--- Konfiguration für neues Tabellenblatt ---")
            
            age_input = input("Alter_kl auswählen (z.B. 45-60,60-75, 75+): ")
            if not age_input:
                print("Keine Altersklassen angegeben. Vorgang abgebrochen.")
                continue
            ages = [a.strip() for a in age_input.split(",")]

            print("1 = Synergie (synergie >= 1)")
            print("2 = Syn012 (syn012 >= 1)")
            print("3 = KGM (Kein Filter)")
            wahl = input("Auswahl (1, 2 oder 3): ")

            if wahl == "1":
                f_type = "synergie"
            elif wahl == "2":
                f_type = "syn012"
            else:
                f_type = "kgm"

         

            frames = []
            # genders= input("Auswahl(1 Männer, 2 Frauen):")
            # while genders:
            # #g = [a.strip() for a in genders.split(',')]
            #     if genders == '1': 
            #        g = '1'
            #        continue
            #     elif genders == '2':
            #         g = '2'
            #         continue
            #     print("möchtest du auch für das andere Gender machen")


            for g in ['1','2']:
                print(f"Lade Daten für {f_type} - Gendertype {g}...")
                try:
                    df_temp = run_complex_age_report(engine, ages, g, sql_eingabe, f_type)
                    
                    if not df_temp.empty:
                        df_temp.insert(0, 'Geschlecht', 'Männer' if g == '1' else 'Frauen')
                        frames.append(df_temp)
                except Exception as e:
                    print(f" Fehler bei Gendertype {g}: {e}")

            if frames:
                df_final = pd.concat(frames, ignore_index=True)
                df_final.to_excel(writer, sheet_name=f_type, index=False)
                print(f" Sheet '{f_type}' erfolgreich hinzugefügt.")
            else:
                print(" Keine Daten für diese Auswahl gefunden. Sheet wurde nicht erstellt.")

            wiederholen_kate = input("\nMöchtest du syn012 oder kundengruppenmodell ausführen? (j/n): ").lower().strip()
            if wiederholen_kate != 'j':
                break

    print(f"\n :) Super gemacht . Datei gespeichert unter: {os.getcwd()}\\{excel_file}")
    print("="*50)
    input("\n programm beendet. Enter für schließen ")
    sys.exit(0)







if __name__ == "__main__":
    main()
    input("\n programm beendet. Enter für schließen ")
        
