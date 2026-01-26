import streamlit as st
import pandas as pd
import datetime
import json
from github import Github
import io


# ---------------- Page config ----------------
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
             style="width:90px;height:90px;border-radius:50%;border:3px solid #0DC3EC;margin-right:15px;">
        <div>
            <h2 style="margin:0;">Kher Sarakbi</h2>
            <p style="margin:0;color:gray;">Gemini Direct Dashboard</p>
        </div>
    </div>
    """,
    unsafe_allow_html=True
)

# ---------------- Load data ----------------
@st.cache_data
def load_data():
    df = pd.read_excel(
        "Report_nutribiona.xlsx",
       
        header=1
        
    )
    df.columns = (
        df.columns
        .astype(str)
        .str.strip()
        .str.lower()
        .str.replace(r"unnamed:.*", "", regex=True)
)
    df = df.loc[:, df.columns != ""]
    return df

df = load_data()



# st.subheader("Spalten auswählen")

# cols_to_show = st.multiselect(
#     "Welche Spalten anzeigen?",
#     options=df.columns.tolist(), #### hier muss angepasst werden 
#     default=df.columns.tolist()
# )

# df_display = df[cols_to_show].copy()
st.dataframe(df)

st.subheader("Filter setzen")
# for col in df:
#     if col == 'seg_kgm':
#         df_display=df.drop(columns={'seg_kgm'})  
   
filter_cols = st.multiselect(
    "Filter nach Spalten",
    options=df.columns.tolist(),
    default=df.columns.tolist()
)
df_neu ={}

for col in filter_cols:
    unique_values = df[col].dropna().unique().tolist()
    df_neu[col] = unique_values

    
   
st.dataframe(df_neu)
    

    # selected = st.multiselect(
    #     f"Filter {col}",
    #     options=unique_values
    # )

    # if selected:
    #     df_display = df_display[df_display[col].isin(selected)]

# st.subheader("Spalten markieren")

# mark_cols = st.multiselect(
#     "Welche Spalten gelb markieren?",
#     options=filter_cols
# )

# def highlight_columns(df, cols):
#     styles = pd.DataFrame("", index=df.index, columns=df.columns)
#     for c in cols:
#         styles[c] = "background-color: yellow"
#     return styles
# df_higli= df[mark_cols].copy()
# print(f"the df_hig ist : {df_higli}")
# numeric_cols = df_higli.select_dtypes(include=['number']).columns
# styled_df = df_higli.style.format({col: "{:.0f}" for col in numeric_cols})
# # styled_df = df_higli.style.format(
# #     formatter={col: "{:.0f}" for col in df_higli.columns if df_higli.dtypes==int  str} 

# # )
# styled_df=styled_df.apply(
#     highlight_columns,
#     cols=mark_cols,
#     axis=None
# )

# st.dataframe(
#     styled_df,
    
#     use_container_width=True
# )
# df_clean_data = df[mark_cols]
buffer = io.BytesIO()
with pd.ExcelWriter(buffer, engine="openpyxl") as writer:
    df.to_excel(writer, index=False)
    
    # الحصول على الكائن المنسق لإضافة لمسات إضافية إذا لزم الأمر
    workbook  = writer.book
    worksheet = writer.sheets['Sheet1']

# تجهيز البيانات للتنزيل
excel_data = buffer.getvalue()
st.download_button(
    label="speichern📥",
    data=excel_data,
    file_name="data_colored.xlsx",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
)
#csv_data = df_clean_data.to_csv(index=False, sep=";",encoding="utf-8-sig")


# st.download_button(
#     label="⬇️ Download CSV",
#     data=csv_data,
#     file_name="filtered_data.csv",
#     mime="text/csv"
# )

st.divider()
st.subheader("Notizen für Suzzi")

notes = st.text_area("Notiz schreiben")

if st.button("💾 Speichern"):
    if not df.columns and not notes.strip():
        st.warning("⚠️ Bitte erst deine Anmerkung")
    else:
        try:
            token = st.secrets["GITHUB_TOKEN"]
            g = Github(token)
            repo = g.get_repo("Kher92/KS_FIles")

            FILE_PATH = "column_markings.json"
            BRANCH = "customy"

            payload = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "marked_columns": df.columns,
                "note": notes
            }

            content = json.dumps(payload, indent=2, ensure_ascii=False)

            try:
                file = repo.get_contents(FILE_PATH, ref=BRANCH)
                repo.update_file(
                    FILE_PATH,
                    "Update column markings",
                    content,
                    file.sha,
                    branch=BRANCH
                )
            except:
                repo.create_file(
                    FILE_PATH,
                    "Create column markings",
                    content,
                    branch=BRANCH
                )

            st.success("✅ تم حفظ التعليم والملاحظة بنجاح")

        except Exception as e:
            st.error(f"❌ Error: {e}")

st.markdown("✔️ **Fertig**")
