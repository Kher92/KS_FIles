import streamlit as st
import pandas as pd
from PIL import Image

# --- عنوان وشعار ---

col1, col2, col3 = st.columns([1,6,1]) # Adjust column ratios as needed
with col2:
    st.image("gemini.png")

st.markdown("""
<div style="text-align:center">
    <h1> Kher Sarakbi</h1>
</div>
""", unsafe_allow_html=True)
image = Image.open("kher.png")
col1, col2 = st.columns([2, 8])  # نسبة 1:3 بين الصورة والنص

with col1:
    st.image(image, width="content",output_format="PNG")
# --- تحميل البيانات ---
@st.cache_data
def load_data():
    df = pd.read_csv("f.csv", sep=';')
    df.columns = df.columns.str.lower().str.strip()
    return df

df = load_data()

# --- اختيار الأعمدة ---
all_columns = df.columns.tolist()
columns_to_show = st.multiselect(
    "Wähle die Spalten, die du anzeigen willst:",
    default=["gendertypeid"]
    ,options=all_columns
)

# --- فلترة القيم ---
filters = {}
for col in columns_to_show:
    if df[col].dtype in ['float64','int64','object']:
        unique_vals = df[col].dropna().unique()
        selected = st.multiselect(f"Filter {col}:", options=unique_vals, default=unique_vals)
        filters[col] = selected

# --- تطبيق الفلتر ---
df_filtered = df.copy()
for col, selected_vals in filters.items():
    df_filtered = df_filtered[df_filtered[col].isin(selected_vals)]

# --- عرض الجدول ---
if columns_to_show:
    st.dataframe(df_filtered[columns_to_show])

# --- المجموع النهائي ---
if "score_kgm" in df_filtered.columns:
    total_score = df_filtered["score_kgm"].sum()
    st.metric("Total Score KGM", f"{total_score:,.0f}")
