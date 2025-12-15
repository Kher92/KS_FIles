import streamlit as st
import pandas as pd
import io
st.set_page_config(
    page_title="Auszählung",
    layout="wide",
    page_icon="📊"
)

# قائمة الملفات على GitHub
excel_files = [
    "https://github.com/Kher92/KS_FIles/blob/main/2025-11-24-127_KS_3521.xlsx",
    "https://github.com/Kher92/KS_FIles/blob/main/2025-12-01-017_KS_3421.xlsx",
    "https://github.com/Kher92/KS_FIles/blob/main/2025-12-02-035_KS_2390.xlsx"
]
col1, col2, col3 = st.columns([1,6,1]) # Adjust column ratios as needed
with col2:
    st.image("gemini.png")
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

output = io.BytesIO()
df.to_excel(output, index=False, engine='openpyxl')
output.seek(0)  # رجوع للبداية

st.download_button(
    label="⬇️ Download data as Excel",
    data=output,
    file_name="data.xlsx",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
)
