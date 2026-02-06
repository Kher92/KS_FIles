import streamlit as st
import pandas as pd
import datetime
import json
from github import Github
import io
import smtplib
from email.mime.text import MIMEText
import requests


st.set_page_config(
    page_title="Gemini Dashboard",
    page_icon="☁️",
    layout="wide"
)


st.image("Logo.png", use_column_width=True)

st.markdown(
    """
    <div style="display:flex; align-items:center; justify-content:center; margin-bottom:25px;">
        <img src="https://img.freepik.com/free-vector/cute-hacker-operating-laptop-cartoon-vector-icon-illustration-people-technology-icon-isolated-flat_138676-7079.jpg"
             style="width:150px;height:150px;border-radius:50%;border:3px solid #0DC3EC;margin-right:15px;">
        <div>
            <h2 style="margin:0;">Kher Sarakbi</h2>
            <p style="margin:0;color:gray;">Gemini Direct Dashboard</p>
        </div>
    </div>
    """,
    unsafe_allow_html=True
)


@st.cache_data
def load_data():

    alle_sheet = pd.read_excel(
        "Kunde_nutribiona_2026-02-05_13-28-22.xlsx",
        sheet_name=None
    )
    return alle_sheet['Sheet1']


df = load_data()
st.dataframe(df)
print(df.columns)
if 'seg_kgm' in df.columns:
    available_seg_values = df['seg_kgm'].unique()
    
    selected_seg_values = st.multiselect(
        "Welche Segment-Werte (seg_kgm) filtern?",
        options=available_seg_values
    )


    if selected_seg_values:
        df_filtered_rows = df[df['seg_kgm'].isin(selected_seg_values)].copy()
    else:
        df_filtered_rows = df.copy()
    
    st.info(f"📈 es wurde die Zeilen   {len(df_filtered_rows)}  gefunden   .")
else:
    st.error("العمود 'seg_kgm' غير موجود.")
    df_filtered_rows = df.copy()




st.subheader("📋 2. Spalten auswählen")

all_columns = df_filtered_rows.columns.tolist()
selected_cols = st.multiselect(
    "Welche Spalten möchtest du behalten?",
    options=all_columns,
    default=all_columns[:5] if len(all_columns) > 5 else all_columns # افتراضياً أول 5 أعمدة
)

if not selected_cols:
    st.warning("    Mindestens eine Zeile wählen .")
    df_step2 = df_filtered_rows.copy()
else:
    df_step2 = df_filtered_rows[selected_cols].copy()


st.subheader("🖱️ 3. Spezifische Zeilen auswählen")
st.write("Wähle die Zeielen Aus")
#st.write("قم بتحديد الأسطر التي تريد العمل عليها من الجدول أدناه:")

# عرض الجدول مع خاصية التحديد
event = st.dataframe(
    df_step2,
    use_container_width=True,
    on_select="rerun", # تفعيل خاصية التحديد التفاعلي
    selection_mode="multi-row"
)




























# df_long = df.melt(
#     id_vars=['seg_kgm', 'score_kgm'], 
#     value_vars=['MB012', 'MB024', 'MB012_p', 'MB024_p'],
#     var_name='Spalten_Name', 
#     value_name='Inhalt'       
# )

# pivot = pd.pivot_table(
#     df_long,
#     values='score_kgm',
#     index='seg_kgm',
#     columns='Spalten_Name',
#     aggfunc='sum',
#     fill_value=0
# )
# print(pivot)
# st.dataframe(pivot)

# import pandas as pd
# import numpy as np

# df = load_data() # Dein geladenes DataFrame

