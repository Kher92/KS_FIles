import streamlit as st
import pandas as pd
import os

files_in = r"C:\Users\ks\Desktop\excelFiles"

st.set_page_config(
    page_title="Probe",
    layout="wide",
    page_icon="📊"
)

# Dateien auflisten
if os.path.exists(files_in):
    excel_files = [
        f for f in os.listdir(files_in) if f.lower().endswith('.csv')
    ]
else:
    st.error(f"Ordner nicht gefunden: {files_in}")
    excel_files = []

if excel_files:
    selected_file = st.selectbox("Wähle die Datei aus", excel_files)

    # Datei-Pfad zusammenbauen
    file_path = os.path.join(files_in, selected_file)
    
    # Laden mit Encoding-Schutz (falls Umlaute enthalten sind)
    try:
        df = pd.read_csv(file_path, sep=None, engine='python', encoding='utf-8')
    except:
        df = pd.read_csv(file_path, sep=None, engine='python', encoding='iso-8859-1')

    df = df.dropna(how="all")

    st.subheader("📋 Data Preview")
    st.dataframe(df, use_container_width=True)

    st.markdown("---")
    # HTML Korrektur: "Creator" statt "Creater" ;)
    st.markdown(
    """
    <h1 style='text-align: center;'>
       
        <img src="cyber-criminal_15097060.png" style="width: 40px; height: 40px; vertical-align: middle;">
        Created by: Kher Sarakbi
    </h1>
    """, 
    unsafe_allow_html=True
    )

    # Download Button
    st.download_button(
        label="⬇️ Download data as CSV",
        data=df.to_csv(index=False).encode("utf-8"),
        file_name=f"export_{selected_file}",
        mime="text/csv"
    )
else:
    st.warning("Keine CSV-Dateien im Ordner gefunden.")