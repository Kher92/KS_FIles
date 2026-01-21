import streamlit as st
import pandas as pd
from PIL import Image


image = Image.open("kher.png")
col1, col2 = st.columns([1, 500])  # نسبة 1:3 بين الصورة والنص

with col1:
    st.image(image, width=500)  # التحكم بحجم الصورة هنا

with col2:
    st.markdown("**Created by: Kher Sarakbi**", unsafe_allow_html=True)


col1, col2, col3 = st.columns([1,6,1]) # Adjust column ratios as needed
with col2:
    st.image("gemini.png")

@st.cache_data
def load_data():
    return pd.read_csv("f.csv",sep=';')

df = load_data()
print(df.columns.tolist())

df = df.loc[:, ~df.columns.str.contains("^Unnamed")]
df.columns = df.columns.str.lower().str.strip()

st.write(df.columns)
gender = st.multiselect(
    "Geschlecht",
    options=df["gendertypeid"].unique(),
    default=df["gendertypeid"].unique()
)

df_f = df[df["gendertypeid"].isin(gender)]


ages = st.multiselect(
    "Alter",
    df_f["alter_kl"].dropna().unique()
)

if ages:
    df_f = df_f[df_f["alter_kl"].isin(ages)]


synergie_only = st.checkbox("Nur Synergie")

if synergie_only:
    df_f = df_f[df_f["synergie"] >= 1]    


total_score = df_f["score_kgm"].sum()

st.metric("Total Score KGM", f"{total_score:,.0f}")
for col in ["gendertypeid", "alter_kl", "seg_kgm"]:
    vals = st.multiselect(f"Filter {col}", df[col].dropna().unique(), default=df[col].unique())
    if vals:
        df_f = df_f[df_f[col].isin(vals)]

# st.download_button(
#     label="⬇️ Download data as Excel",
#     data=output,
#     file_name="data.xlsx",
#     mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
# )