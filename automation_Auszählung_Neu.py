import pandas as pd
import urllib.parse
from sqlalchemy import create_engine ,exc,text
import os
import sys
import warnings
import datetime
import xlsxwriter

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

def run_complex_age_report(engine, ages, gender,alter,skript,filter_type):
    if filter_type =='synergie' :
        types = "AND synergie >=1"
    elif filter_type =='syn012':
        types ="AND syn012 >=1"
    elif filter_type =='old with synergie':
        types= "AND Synergie >=1 and old is null"
    elif filter_type =='old with syn012':
        types= "AND Synergie >=1 and old is null"
    elif filter_type =='kgm':
        types= ""
    elif filter_type =='old with kgm':
        types = "AND old is null"   
    select_parts = []         
    



    prefixes = ['mb012_p', 'mb012', 'mb024_p', 'mb024', 'mb024_p_rest', 'mb024_rest']
    if filter_type =='kgm' or filter_type == 'old with kgm':
        prefixes=['mb012_p', 'mb012', 'mb024_p', 'mb024']
    ages_sql  = ", ".join([f"'{a.strip()}'" for a in ages ])    


    quer_values = f"""select distinct ltrim(rtrim({alter})) as val from {skript} where {alter} is not null and {alter} in ({ages_sql})"""    
    #jprint("DEBUNG :\n",quer_values)
    df_raw = pd.read_sql(quer_values,engine)
    print(f"Hier ISt das Proble {df_raw}")
    ag = df_raw['val'].tolist()
    print(f"the ages are {ag}")
    if not ag :
        print(f"keine werte in {alter}")
        return pd.DataFrame()
    pivot_ages = ", ".join([f"[{a.strip()}]" for a in ag])
    select_parts = [f"{p}.[{a}]"for p in prefixes for a in ag]
    select_sql = ", ".join(select_parts)




    
    # for p in prefixes:
    #     for a in ages:
    #         select_parts.append(f"{p}.[{a.strip()}]")



    # df_raw = pd.read_sql(f"select distinct ealter from {skript}",engine)
    # print(f"the uniqe values are {df_raw}")



    #pivot_ages = ", ".join([f"[{a.strip()}]" for a in ages])
    print("pivot columns are: " , pivot_ages)
    query=None


    query = f"""
    SELECT
        mb012_p.seg_kgm,
        {select_sql}
    FROM
    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, {alter}, urngem FROM {skript}
        WHERE mb012_P = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) P) mb012_p,

    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, {alter}, urngem FROM {skript}
        WHERE mb012 = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) p) mb012,

    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, {alter}, urngem FROM {skript}
        WHERE mb024_p = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) P) mb024_p,

    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm,{alter}, urngem FROM {skript}
        WHERE mb024 = 1 {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) P) mb024,

    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, {alter}, urngem FROM {skript}
        WHERE mb024_p IS NULL {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) P) mb024_p_rest,

    (SELECT gendertypeid, seg_kgm, {pivot_ages} FROM (
        SELECT gendertypeid, seg_kgm, {alter}, urngem FROM {skript}
        WHERE mb024 IS NULL {types}
    ) b PIVOT(COUNT(urngem) FOR {alter} IN ({pivot_ages})) P) mb024_rest

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
        

        print(f"pivot columns: {ages}")
        print(df.head())
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

    datum_heute = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    excel_file = f"Report_{sql_eingabe}_{datum_heute}.xlsx"



    with pd.ExcelWriter(excel_file, engine='xlsxwriter') as writer:

        while True:
            print("\n--- Konfiguration für neues Tabellenblatt ---")
            sql_alter = f"select distinct alter_kl, ealter from {sql_eingabe} where alter_kl is not null and ealter is not null"
            with engine.connect() as conn:
                df_alter = pd.read_sql(text(sql_alter), conn)


            age_input = input(f"{df_alter} \n bitte das Alter eingeben  \n")
            if not age_input:
                print("Keine Altersklassen angegeben. Vorgang abgebrochen.")
                continue
            
            alter_colu = input("E for Echtalter, A for alter_kl ").lower().strip()   
       
            if alter_colu == 'E'.lower():
                alter_colu= 'ealter'
            else:
                alter_colu= 'alter_kl'
    
            ages = [a.strip() for a in age_input.split(",")]

            print("1 = Synergie (synergie >= 1)")
            print("2 = Syn012 (syn012 >= 1)")
            print("3 = Synergie with old (synergie >= 1 and old is null)")
            print("4 = Syn012 with old (syn012 >= 1 and old is null)")
            print("5 = KGM (Kein Filter)")
            
            wahl = input("Auswahl (1, 2,3,4 oder 5): ")
                   


            if wahl == "1":
                f_type = "synergie"
            elif wahl == "2":
                f_type = "syn012"
            elif wahl =="3":
                f_type="old with synergie"
            elif wahl == "4":
                f_type="old with syn012"
            elif wahl == "5":
                f_type="kgm"    
            else:
                f_type = "old with kgm"


            deine_Wahl = input("M fuer Männer oder F fuer Frauen pr B fuer Beide\n").lower()
            valid = True
            df = None
            
            if deine_Wahl =='m':
                df = run_complex_age_report(engine,ages,1,alter_colu,sql_eingabe,f_type)
                df =df.set_index('seg_kgm')
                df.columns=[f"Men_{c}" for c in df.columns]
            elif deine_Wahl == 'f':
                df = run_complex_age_report(engine,ages,2,alter_colu,sql_eingabe,f_type)
                df =df.set_index('seg_kgm')
                df.columns=[f"women_{c}" for c in df.columns]
            else:
                   df_men = run_complex_age_report(engine,ages,1,alter_colu,sql_eingabe,f_type)
                   df_women = run_complex_age_report(engine,ages,2,alter_colu,sql_eingabe,f_type)
                   df_men = df_men.set_index('seg_kgm')
                   df_women =df_women.set_index('seg_kgm')
                   df_men.columns=[f"Men_{c}" for c in df_men.columns]
                   df_women.columns=[f"women_{c}" for c in df_women.columns]
                   df= pd.concat([df_men,df_women],axis=1)
            if valid:
                print(f"VAAAAAAAALID {valid}")
               # df=df.apply(pd.to_numeric,errors='coerce')
                df.loc["SUM"]=df.drop("SUM",errors="ignore").sum()
                # df=df.loc[:,~df.columns.duplicated()]
                # df.loc["SUM"]=df.sum()
                print(f"df ist {df}")
                df.to_excel(writer,sheet_name=f_type,index=True)
                workbook  = writer.book
                worksheet = writer.sheets[f_type]
                header_format = workbook.add_format({'bold':True,'bg_color':"#0DC3EC",'font_color':'black'})
                for col,value in enumerate(df.columns.values):
                    worksheet.write(0,col+1,value,header_format)
            
            
            
            if df is None or df.empty:
                print("Keine Daten")
                valid=False







            # if valid:
            #     print(f"VAAAAAAAALID {valid}")
            #     df=df.apply(pd.to_numeric,errors='coerce')
            #     df.loc["SUM"]=df.sum() 
            #     print(f"df ist {df}")
            #     df.to_excel(writer,sheet_name=f_type,index=True)
            #     workbook  = writer.book
            #     worksheet = writer.sheets[f_type]
            #     header_format = workbook.add_format({'bold':True,'bg_color':"#CAEC0D",'font_color':'black'})
            #     for col,value in enumerate(df.columns.values):
            #         worksheet.write(0,col+1,value,header_format)








            
            # df_men.columns=[f"Men_{c}" for c in df_men.columns]
            # df_women.columns=[f"women_{c}" for c in df_women.columns]
            # df= pd.concat([df_men,df_women],axis=1)
            

          
          


            # for g in ['1','2']:
            #     print(f"Lade Daten für {f_type} - Gendertype {g}...\n")
            #     try:
            #         df_temp = run_complex_age_report(engine, ages, g, sql_eingabe, f_type)

            #         if not df_temp.empty:
            #             df_temp.insert(0, 'Geschlecht', 'Männer' if g == '1' else 'Frauen')
            #             frames.append(df_temp)
            #     except Exception as e:
            #         print(f" Fehler bei Gendertype {g}: {e}")

            # if frames:
            #     df_final = pd.concat(frames, ignore_index=True)
            #     df_final.to_excel(writer, sheet_name=f_type, index=False)
            #     print(f" Sheet '{f_type}' erfolgreich hinzugefügt.")
            # else:
            #     print(" Keine Daten für diese Auswahl gefunden. Sheet wurde nicht erstellt.")

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


