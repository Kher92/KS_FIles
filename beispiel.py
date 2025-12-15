import streamlit as st
import pandas as pd

st.set_page_config(
    page_title="Probe",
    layout="wide",
    page_icon="📊"
)

# قائمة الملفات على GitHub
excel_files = [
    "https://github.com/Kher92/KS_FIles/blob/main/2025-11-24-127_KS_3521.xlsx",
    "https://github.com/Kher92/KS_FIles/blob/main/2025-12-01-017_KS_3421.xlsx",
    "https://github.com/Kher92/KS_FIles/blob/main/2025-12-02-035_KS_2390.xlsx"
]

selected_file_url = st.selectbox("Wähle die Datei aus", excel_files)

file_url = selected_file_url.replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")
df = pd.read_excel(file_url, engine="openpyxl")
df = df.dropna()

st.subheader("📋 Data Preview")
st.write(df)

st.subheader("📈 Pivot Table Builder")
cols = df.columns

st.markdown("---")
st.markdown("👨‍💻 Created by: Kher Sarakbi", unsafe_allow_html=True)

st.download_button(
    label="⬇️ Download data as excel",
    data=df.to_excel(index=False).encode("latin1"),
    file_name=f"{excel_files}.xlsx",
    mime="text/xlsx"
)
