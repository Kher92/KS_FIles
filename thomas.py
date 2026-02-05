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
print(df.columns)


mask = (df['old'].isna()) & (df['kauf_2120'] == 1) & (df['gendertypeid'] == 2)
df_filtered = df[mask].copy()
print(f"df_filtered ich bin hier \n{df_filtered}\n")
print("__________"*5)
print(f"the length of df_filtterd is {len(df_filtered)}  ")
df_filtered = df_filtered[df_filtered['ealter'] == '60-75']

conditions = {
    'mb012_p_count': df_filtered['MB012_p'] == 1,
    'mb012_count':   df_filtered['MB012'] == 1,
    'mb024_p_count': df_filtered['MB024_p'] == 1,
    'mb024_count':   df_filtered['MB024'] == 1,
    'mb024_p_rest':  df_filtered['MB024_p'].isna(),
    'mb024_rest':    df_filtered['MB024'].isna()
}

# إضافة أعمدة مؤقتة (True/False) لكل شرط للعد
for col_name, condition in conditions.items():
    df_filtered[col_name] = condition

df_pivot = pd.pivot_table(
    df_filtered,
    values=['mb012_p_count', 'mb012_count', 'mb024_p_count', 'mb024_count'],
    index=['seg_kgm'],
    columns=['ealter'], # هنا سيكون [60-80]
    aggfunc='sum',      # جمع القيم True (التي تعادل 1)
    fill_value=0
)

# ترتيب النتائج حسب seg_kgm كما في SQL
df_pivot = df_pivot.sort_index()
