import streamlit as st
import pandas as pd
import os
from io import BytesIO

files_in = r"C:\Users\ks\Desktop\excelFiles"

st.set_page_config(
    page_title="Auszählung",
    layout="wide",
    page_icon="📊",
    
)

excel_files = [
    f for f in os.listdir(files_in)
    if f.lower().endswith((".xlsx", ".xls"))
]

selected_file = st.selectbox(
    "Wähle die Datei aus",
    excel_files
)

st.title(f"📊 Auftrag: {selected_file}")
col1, col2, col3 = st.columns([1,6,1]) # Adjust column ratios as needed
with col2:
    st.image("gemini.png")
# st.image("gemini.png",caption="Unsere Firma",width='content',)

file_path = os.path.join(files_in, selected_file)

@st.cache_data
def load_data(path):
    df = pd.read_excel(path)
    return df

df = load_data(file_path)
df = df.dropna(how="all")

st.subheader("📋 Data Preview")
st.dataframe(df, use_container_width=True)

st.subheader("📈 Pivot Table Builder")
cols = df.columns.tolist()

rows = st.multiselect("Rows", cols)
columns = st.multiselect("Columns", cols)
values = st.selectbox("Values", cols)

if rows and columns and values:
    pivot = pd.pivot_table(
        df,
        index=rows,
        columns=columns,
        values=values,
        aggfunc="count",
        fill_value=0
    )
    st.dataframe(pivot, use_container_width=True)

st.download_button(
    label="⬇️ Download data as excel",
    data=df.to_excel(index=False).encode("latin1"),
    file_name=f"{selected_file}.xlsx",
    mime="text/xlsx"
)


# output = BytesIO()
# df.to_excel(output, index=False, engine="openpyxl")
# output.seek(0)

# st.download_button(
#     label="⬇️ Download data as Excel",
#     data=output,
#     file_name=f"{selected_file}",
#     mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
# )