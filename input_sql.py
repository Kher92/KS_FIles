import pandas as pd
import urllib.parse
from sqlalchemy import create_engine
import os
import sys
from sqlalchemy import text
import pickle
import warnings
from sqlalchemy import exc



warnings.filterwarnings("ignore",category=exc.SAWarning, message=".will not produce anything")
DB_SERVER = 'gemini-sql2'
DATABASE = 'GEMINI_PSEUDO'
SQL_FILE = "sssss.sql"
SQL_SKRIPT = r"E:\GEMINI_PSEUDO\Auszählungen"
SQL_Eingabe = None


def get_connection():
    print("Verbindungsaufbau zur Datenbank...")
    try:
        conn_string = f"Driver={{ODBC Driver 17 for SQL Server}};Server={DB_SERVER};Database={DATABASE};Trusted_Connection=yes;"
        quoted_conn_string = urllib.parse.quote_plus(conn_string)
        engine = create_engine(
            f"mssql+pyodbc:///?odbc_connect={quoted_conn_string}")
        print("Verbindung hergestellt.")
        return engine
    except Exception as e:
        print(f"FEHLER beim Verbindungsaufbau: {e}")
        print("Stellen Sie sicher, dass Sie mit dem Unternehmensnetzwerk verbunden sind und ODBC Driver 17 installiert ist.")
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


def read_sql(engine, sql_file_path):

    with open(sql_file_path, "r", encoding="latin1") as f:
        query = f.read()
        
    batches = [b.strip() for b in query.split(';') if b.strip()]
    all_row = []
    columns = None

    with engine.connect() as conn:
        
        for batch in batches:

            stmt = text(batch)
            result = conn.execute(stmt)
            if result.returns_rows:
                rows = result.fetchall()
                columns = list(result.keys())
                all_row.extend(rows)

    if all_row and columns:
        df = pd.DataFrame(all_row,columns=columns)
        return df 

    else :
        return pd.DataFrame()    

def run_age(engine, ages):
    age = ",".join([f"[{a}]" for a in ages]) 
    query = f""" 
            select seg_kgm ,{age} from (select seg_kgm,alter_kl,urngem from nutribiona where gendertypeid = 1)src pivot (
            count (urngem) from alter_kl in ({ages})
            )p order by seg_kgm 
            """
    with engine.connect() as conn :
        df = pd.read_sql(text(query),conn)

    return df
               


def main():
    engine = get_connection()

    sql_map = build_sql_map(SQL_SKRIPT)

    if not sql_map:
        print("Keine Skripts sind vorhanden")
        return None



    sql_eingabe = input("welches Skript möchtest du ausführen? \n").lower()

                
    sql_file_path = sql_map.get(sql_eingabe)

    if not sql_file_path:
        print("Das Skript gibt es nicht")
        return
    read_sql(engine,sql_file_path)
    age_input = input("75-60,60-45\n")
    ages = [a.strip() for a in age_input.split(",")]
    df = run_age(engine,ages)
    print(df)
    df.to_csv("Kher.csv",index=False)
 

    # try:
    #     df =read_sql(engine,sql_file_path)
    #     print("✅ Result:")
        
    #     df.to_csv('f.csv',index=False)
    
    # except Exception as e:
    #     print("❌ SQL Error:")
    #     print(e)


if __name__ == "__main__":
    main()

'''
SQL_TEMPLATE = """
select 
mb012_p.['60-75'],		mb012_p.['45-60'],		
mb012.['60-75'],			mb012.['45-60'],		
mb024_p.['60-75'],		mb024_p.['45-60'],		
mb024.['60-75'],			mb024.['45-60'],		
mb024_p_rest.['60-75'],	mb024_p_rest.['45-60'],	
mb024_rest.['60-75'],		mb024_rest.['45-60']
from 
(select gendertypeid, seg_kgm,['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb012_P = 1
) b pivot(count(urngem) for ealter in (['60-75'],['45-60'])) P) mb012_p
,
(select gendertypeid, seg_kgm, ['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb012 = 1 
) b pivot(count(urngem) for ealter in (['60-75'],['45-60'])) p) mb012
,
(select gendertypeid, seg_kgm, ['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb024_p = 1
) b pivot(count(urngem) for ealter in (['60-75'],['45-60']))P) mb024_p
,
(select gendertypeid, seg_kgm, ['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb024 = 1 
) b pivot(count(urngem) for ealter in (['60-75'],['45-60']))P) mb024
,
(select gendertypeid, seg_kgm, ['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb024_p is null 
) b pivot(count(urngem) for ealter in (['60-75'],['45-60']))P)mb024_p_rest
,
(select gendertypeid, seg_kgm, ['60-75'],['45-60'] from (
select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
where mb024 is null 
) b pivot(count(urngem) for ealter in (['60-75'],['45-60']))P) mb024_rest
where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=1
order by mb012_p.seg_kgm  

'''
