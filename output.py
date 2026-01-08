import streamlit as st
import pandas as pd
import os
from PIL import Image

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
    # st.subheader("👨‍💻 Created by: Kher Sarakbi")
    # st.image("kher.png", width=40)
    # st.html(
    #     """
    #     <p> 
    #         Created by: Kher Sarakbi 
    #         <img src="kher.png" style="width: 40px; height: 40px; vertical-align: middle;"> 
    #     </p>
    #     """
    # )
    image = Image.open("kher.png")

# قم بإنشاء عمودين: واحد للصورة وواحد للاسم
    col1, col2 = st.columns([1, 50])  # نسبة 1:3 بين الصورة والنص

    with col1:
        st.image(image, width=50)  # التحكم بحجم الصورة هنا

    with col2:
        st.markdown("**Created by: Kher Sarakbi**", unsafe_allow_html=True)

#     st.markdown("---")
#     # HTML Korrektur: "Creator" statt "Creater" ;)
#     st.markdown("---")
#     # HTML Korrektur: Das korrekte <img> Tag wird verwendet
#     st.markdown(
#     """
#     <!-- KORREKTES TAG STARTET MIT <img -->
#     <img src="kher.png" style="width: 40px; height: 40px; vertical-align: middle;">
#     Created by: Kher Sarakbi
#     """,
#     unsafe_allow_html=True
# )

    # Download Button
    st.download_button(
        label="⬇️ Download data as CSV",
        data=df.to_csv(index=False).encode("utf-8"),
        file_name=f"export_{selected_file}",
        mime="text/csv"
    )
else:
    st.warning("Keine CSV-Dateien im Ordner gefunden.")