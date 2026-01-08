import streamlit as st
import pandas as pd
import os
from io import BytesIO

files_in = r"C:\Users\ks\Desktop\excelFiles" # dafür muss auch eine Lösung geben


st.set_page_config(
    page_title="Probe",
    page_icon="📊",
    layout="centered", # Optionen: "centered" oder "wide"
    initial_sidebar_state="auto", # Optionen: "auto", "expanded", "collapsed"
    menu_items={
        'Get Help': 'https://www.extremelycoolapp.com/help',
        'Report a bug': "https://www.extremelycoolapp.com/bug",
        'About': "# Dies ist eine Probe-App!"
    }
)

excel_files = [
    f for f in os.listdir(files_in)
    if f.lower().endswith((".xlsx", ".csv"))
]
option = st.selectbox(
    label="Wähle eine Stadt:",
    options=["Berlin", "Hamburg", "München"],
    index=0,  # Standardmäßig ist das erste Element (Index 0) vorausgewählt
    help="Dies ist ein Hinweis für den Nutzer."
)
st.write("Deine Auswahl:", option)
selected_file = st.selectbox(
    "Wähle die Datei aus",
    excel_files
)

# st.title(f"📊 Auftrag: {selected_file}")
st.title(
    body="10", 
    help="This is a tooltip for the title", 
    anchor=None  # Optional: identifier for the title in the URL
)
file_path = os.path.join(files_in, selected_file)

@st.cache_data
def load_data(path):
    if path.endswith('.csv'):
        try:
            # Versuche Standard-CSV (Komma)
            return pd.read_csv(path, encoding='utf-8')
        except (UnicodeDecodeError, pd.errors.ParserError):
            try:
                # Versuche deutsches Excel-Format (Semikolon + ISO-Encoding)
                return pd.read_csv(path, sep=';', encoding='iso-8859-1')
            except Exception:
                # Letzter Versuch: Alles überspringen, was Fehler macht
                return pd.read_csv(path, sep=None, engine='python', on_bad_lines='skip', encoding='cp1252')
    else:    
        return pd.read_excel(path)


df = load_data(file_path)
df = df.dropna(how="all")

st.subheader("📋 Data Preview")
st.dataframe(df, use_container_width=True)

st.subheader("📈 Pivot Table Builder")
cols = df.columns.tolist()

# rows = st.multiselect("Rows", cols)
# columns = st.multiselect("Columns", cols)
# values = st.selectbox("Values", cols)

# if rows and columns and values:
#     pivot = pd.pivot_table(
#         df,
#         index=rows,
#         columns=columns,
#         values=values,
#         aggfunc="count",
#         fill_value=0
#     )
#     st.dataframe(pivot, use_container_width=True)

# st.download_button(
#     label="⬇️ Download data as excel",
#     data=df.to_excel(index=False).encode("latin1"),
#     file_name=f"{selected_file}.xlsx",
#     mime="text/xlsx"
# )


output = BytesIO()
df.to_excel(output, index=False, engine="openpyxl")
output.seek(0)

st.download_button(
    label="⬇️ Download data as Excel",
    data=output,
    file_name=f"{selected_file}",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
)