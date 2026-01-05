import pandas as pd
import urllib.parse
from sqlalchemy import create_engine
import os
import sys
from sqlalchemy import text
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


def read_sql_file_as_list(engine,sql_files_input):
    sql_files= {}
    for root,dirs,files in os.walk(SQL_SKRIPT):
        for file in files: 
            if file.lower().endswith('.sql'):
                name_only = os.path.splitext(file)[0]
                # sql_files.append(os.path.join(root,file))
                sql_files[name_only.lower()] = os.path.join(root,file)
              

    if not sql_files:
        print ( f"fehler die Skripts sind keine Sql {SQL_SKRIPT}")
        sys.exit(1)
    print(f"die Größe ist {len(sql_files)}")    
    print("Welches SKRIPT Möchtest du ausführen? ")
    SQL_Eingabe = str(input()).lower()
    for pfad in sql_files:
        if os.path.basename(pfad)==SQL_Eingabe:
            print(f"gefunden", pfad)
    query = f"select * from {SQL_Eingabe}" 
    with open (sql_files_input,'r',encoding='latin1')  as f : 
        query = f.read()

      
    with engine.connect() as conn: 
        result = conn.execute(text(query))
        return result.fetchall()
        
          
    # if not SQL_Eingabe in sql_files:
    #     print("nicht gefunden")
    #     with open (SQL_Eingabe,'r',encoding='latin1') as f :
    #         sql_sq = f.read()

    # for f in sql_files:
    #     print(len(f))
    # with open(SQL_SKRIPT, 'r', encoding='latin1') as f:
    #     sql_read = f.read()
    # queire = [w.strip() for w in sql_read.split('\n') if w.strip()]
    # if not queire:
    #     print(
    #         f"FEHLER: Keine gültigen SQL-Abfragen in '{SQL_SKRIPT}' gefunden.")
    #     sys.exit(1)

    # print(f"{len(queire)} Abfragen erfolgreich geparst.")
    # return queire
    # if not os.path.exists(SQL_FILE):
    #     print(f"FEHLER: SQL-Datei '{SQL_FILE}' nicht gefunden.")
    #     sys.exit(1)

    # print(f"Lese und parse SQL-Datei '{SQL_FILE}'...")
    # with open(SQL_FILE, 'r', encoding='latin1') as f:
    #     sql_script = f.read()

    # queries = [q.strip() for q in sql_script.split(';') if q.strip()]

    # if not queries:
    #     print(f"FEHLER: Keine gültigen SQL-Abfragen in '{SQL_FILE}' gefunden.")
    #     sys.exit(1)

    # print(f"{len(queries)} Abfragen erfolgreich geparst.")
    # return queries


def main():
    engine = get_connection()
    print(f"\nEs wurde mit {DB_SERVER}/{DATABASE} verbunden.")

    sql_queries_list = read_sql_file_as_list(engine,)
    # all_results = {}

    # print("\n" + "="*40)
    # print("Starte Ausführung der SQL-Abfragen...")
    # print("="*40)

    # for i, query in enumerate(sql_queries_list):
    #     df_name = f'Result_Query_{i+1}'
    #     print(
    #         f"\n--> Führe Abfrage {i+1}/{len(sql_queries_list)} ('{df_name}') aus...")

    #     try:
    #         df = pd.read_sql(query, engine)
    #         all_results[df_name] = df
    #         print(f"    [OK] Abfrage {i+1} fertig gelesen. Zeilen: {len(df)}")

    #     except Exception as e:
    #         print(
    #             f"    [FEHLER] Bei Abfrage {i+1} ist ein Datenbankfehler aufgetreten: {e}")
    #         print("    Diese Abfrage wird übersprungen.")

    # print("\n" + "="*40)
    # print("Verarbeitung abgeschlossen. Speichere Ergebnisse in CSV-Dateien...")
    # print("="*40 + "\n")

    # for name, df in all_results.items():
    #     if not df.empty:
    #         filename = f'{name}.csv'
    #         df.to_csv(filename, index=False, encoding='utf-8')
    #         print(
    #             f"  [GESPEICHERT] '{filename}' mit {len(df)} Zeilen erstellt.")
    #     else:
    #         print(
    #             f"  [INFO] DataFrame '{name}' war leer (keine Daten gefunden), keine Datei erstellt.")

    # print("\nSkript beendet.")


if __name__ == "__main__":
    main()
