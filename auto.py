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

def run_complex_age_report(engine, ages, gender):

    prefixes = ['mb012_p', 'mb012', 'mb024_p', 'mb024', 'mb024_p_rest', 'mb024_rest']
    select_parts = []
    for p in prefixes:
        for a in ages:
            select_parts.append(f"{p}.[{a.strip()}]")
    print(f"Select_Liste ist:{select_parts}")        
    
    select_sql = ", ".join(select_parts)
    print(f"select_sql_von_parts is {select_sql}")
    

    pivot_ages = ", ".join([f"[{a.strip()}]" for a in ages])
    print (f"pivot ist {pivot_ages}")

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
    while True:

        print("\n--- Parameter für den Nutrisana-Report ---")
        

        gender = input("Gendertype wählen (1 = Männer, 2 = Frauen): ").strip()
        print("Bitte Altersklassen eingeben, getrennt durch Komma (z.B. 60-75, 75+, 90-95)")
        age_input = input("Eingabe: ")
        if not age_input:
            print("Keine Altersklassen angegeben. Abbruch.")
            continue
            
        ages = [a.strip() for a in age_input.split(",")]

        if gender not in ["1", "2"]:
            print("Ungültige Wahl. Abbruch.")
            continue
        frames =[]
        for g in ['1','2']:
            try:
                  df_temp = run_complex_age_report(engine,ages,g)
                  if not df_temp.empty:
                       df_temp.insert(0,'Geschlecht','Männer' if g=='1' else 'Frauen')
                       frames.append(df_temp)
            except Exception as e : 
                 print(f"Fehler ist  {e}")
        if frames:
             df_final= pd.concat(frames,ignore_index=True)
             file_name = "Nutribosana.csv " 
             df_final.to_csv(file_name,index=False,sep=";"  , encoding="utf-8-sig")
             print(f"Datei wurde gespeichert: {os.getcwd()}\\{file_name}")               
                      


      
        # 3. SQL ausführen
        # try:
        #     print("\nAbfrage wird ausgeführt... Bitte warten.")
        #     df_result = run_complex_age_report(engine, ages, gender)
        #     if not df_result.empty():
        #         gender_name = "Maenner" if gender == "1" else "Frauen"
        #         frames.append(gender_name)
        #     else:
        #         print("Keine Daten vorhanden")    
        # except Exception as e : 
        #         print(f"Feheler {e}")
        # print(frames)        
        print("Möchteset du für die andere machen")
        wiederholen = input("j or n").lower().strip()
        if wiederholen =='n':
            break 
        elif wiederholen == 'j':
                # if frames:
                #     date_str = datetime.date.today()
                #     filename = f"Nutrisana_Report_{gender_name}_{date_str}.csv"
                #     df_final = pd.concat(frames,ignore_index=True)
                #     df_final.to_csv(filename, index=False, sep=";", encoding="utf-8-sig")
                #     print(f"Datei wurde gespeichert: {os.getcwd()}\\{filename}")
                    
                continue
        else:
                break                  
        
    #     # if df_result.empty:
    #     #     print("Keine Daten für diese Auswahl gefunden.")
    #     # else:
    #     #     print(f"\n✅ Erfolg! {len(df_result)} Zeilen geladen.")
            
    #     #     # 4. Speichern als CSV
    #     #     gender_name = "Maenner" if gender == "1" else "Frauen"
    #     #     date_str = datetime.date.today()
    #     #     filename = f"Nutrisana_Report_{gender_name}_{date_str}.csv"
            
    #     #     df_result.to_csv(filename, index=False, sep=";", encoding="utf-8-sig")
    #     #     print(f"Datei wurde gespeichert: {os.getcwd()}\\{filename}")
            
    #         # Kurze Vorschau
    #         print("\nVorschau der ersten Zeilen:")
    #         print(df_result.head())

    # except Exception as e:
    #     print(f"\n❌ Fehler während der SQL-Ausführung: {e}")

if __name__ == "__main__":
    main()