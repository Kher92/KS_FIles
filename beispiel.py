import streamlit as st
import pandas as pd

st.set_page_config(
    page_title="Probe",
    layout="wide",
    page_icon="📊"
)

st.title("📊 Auftrag: 2025-11-25-133_KS_3521")

file_path = "2025-11-25-133_KS_3521.xlsx"
df = pd.read_excel(file_path)
df = df.dropna()

print(df)

st.subheader("📋 Data Preview")
st.write(df)

st.subheader("📈 Pivot Table Builder")
cols = df.columns

col1, col2, col3 = st.columns(3)
print(f"columns1 is {col1}")

rows = col1.multiselect("Rows", cols)
columns = col2.multiselect("Columns", cols)
values = col3.selectbox("Values", cols)

if rows and columns:
    pivot = df.pivot_table(
        index=rows,
        columns=columns,
        values=values,
        aggfunc="count",
        fill_value=0
    )
    st.dataframe(pivot)

    export_btn = st.download_button(
        label="⬇️ Download Pivot as Excel",
        data=pivot.to_csv().encode("Ansi"),
        file_name="pivot_export.csv",
        mime="text/csv"
    )
