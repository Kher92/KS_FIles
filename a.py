import streamlit as st
import pandas as pd
import datetime
import json
from github import Github
import io


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
       
    return pd.read_excel(
        "Report_giordano_2026-01-27_13-51-57.xlsx",
        sheet_name=None
        
    )

sheets = load_data()

sheet_name = st.selectbox(
    "📄  SheetAuswahl",
    options=list(sheets.keys())
)

df = sheets[sheet_name]

df.columns = (
    df.columns
    .astype(str)
    .str.strip()
    .str.lower()
    .str.replace(r"unnamed:.*", "", regex=True)
)
df = df.loc[:, df.columns != ""]

st.subheader("📊 Original Daten")
st.dataframe(df)

st.subheader("🔍 Filter Zeilen nach seg_kgm")

if 'seg_kgm' in df.columns:
    seg_values = df.columns.tolist()
    
    # اختيار القيم المراد فلترتها
    selected_seg_values = st.multiselect(
        "Wähle seg_kgm Werte für Filterung",
        options=seg_values,
        default=seg_values[:3] if len(seg_values) >= 3 else seg_values  # 
    )
    
    # تطبيق الفلتر
    if selected_seg_values:
        filtered_df = df[df['seg_kgm'].isin(selected_seg_values)]
        
        # عرض عدد الصفوف المفلترة
        st.info(f"📈 **{len(filtered_df)} Zeilen** entsprechen den ausgewählten seg_kgm Werten")
        
        # عرض البيانات المفلترة
        st.dataframe(filtered_df, use_container_width=True)
        
        # إذا أردت رؤية الصفوف من 1 إلى 3 فقط
#         st.subheader("📋 Erstes bis drittes Ergebnis")
#         if len(filtered_df) >= 3:
#             first_three = filtered_df.head(3)
#             st.dataframe(first_three)
#         elif len(filtered_df) > 0:
#             st.dataframe(filtered_df)
#             st.warning(f"Nur {len(filtered_df)} Zeilen gefunden")
#         else:
#             st.warning("Keine Zeilen gefunden")
#     else:
#         st.warning("Bitte wählen Sie mindestens einen seg_kgm Wert")
# else:
#     st.error("Die Spalte 'seg_kgm' wurde nicht im Datensatz gefunden")

# # ---------------- فلترة الأعمدة ----------------
# st.subheader("📋 Spalten auswählen")

# اختيار الأعمدة المراد عرضها
all_columns = df.columns.tolist()
cols_to_show = st.multiselect(
    "Welche Spalten anzeigen?",
    options=all_columns,
    default=all_columns
)

if cols_to_show:
    if 'filtered_df' in locals() and not filtered_df.empty:
        df_display = filtered_df[cols_to_show].copy()
    else:
        df_display = df[cols_to_show].copy()
    
    # st.subheader("📊 Angezeigte Daten (Gefiltert)")
    # st.dataframe(df_display, use_container_width=True)

# ---------------- خيارات التمييز (Highlighting) ----------------
st.subheader("🎨 Spalten markieren")

if 'df_display' in locals():
    mark_cols = st.multiselect(
        "Welche Spalten gelb markieren?",
        options=df_display.columns.tolist(),
        default=[]
    )

    def highlight_columns(df, cols):
        styles = pd.DataFrame("", index=df.index, columns=df.columns)
        for c in cols:
            styles[c] = "background-color: yellow"
        return styles

    if mark_cols:
        styled_df = df_display.style.apply(
            highlight_columns,
            cols=mark_cols,
            axis=None
        )
        
        # تنسيق الأرقام
        numeric_cols = df_display.select_dtypes(include=['number']).columns
        if len(numeric_cols) > 0:
            styled_df = styled_df.format({col: "{:.0f}" for col in numeric_cols})
        
        st.dataframe(
            styled_df,
            use_container_width=True
        )
        df_clean_data = df_display[mark_cols]

# ---------------- التنزيل ----------------
st.subheader("💾 Download Optionen")

# إنشاء Excel مع البيانات المفلترة
buffer = io.BytesIO()
with pd.ExcelWriter(buffer, engine="openpyxl") as writer:
    # حفظ البيانات المفلترة حسب seg_kgm
    if 'filtered_df' in locals() and not filtered_df.empty:
        filtered_df.to_excel(writer, index=False, sheet_name='Gefiltert_seg_kgm')
    
    # حفظ البيانات مع الأعمدة المختارة
    if 'df_display' in locals():
        df_display.to_excel(writer, index=False, sheet_name='Ausgewaehlte_Spalten')
    
    # حفظ البيانات الأصلية
    df.to_excel(writer, index=False, sheet_name='Original_Daten')

excel_data = buffer.getvalue()

col1, col2 = st.columns(2)

with col1:
    st.download_button(
        label="📥 Excel herunterladen",
        data=excel_data,
        file_name="gefilterte_daten.xlsx",
        mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

with col2:
    if 'df_display' in locals():
        csv_data = df_display.to_csv(index=False, sep=";", encoding="utf-8-sig")
        st.download_button(
            label="📥 CSV herunterladen",
            data=csv_data,
            file_name="gefilterte_daten.csv",
            mime="text/csv"
        )

# ---------------- القسم الأخير للملاحظات ----------------
st.divider()
st.subheader("📝 Notizen für Suzzi")

notes = st.text_area("Notiz schreiben")

if st.button("💾 Speichern"):
    if not notes.strip():
        st.warning("⚠️ Bitte erst deine Anmerkung")
    else:
        try:
            token = st.secrets["GITHUB_TOKEN"]
            g = Github(token)
            repo = g.get_repo("Kher92/KS_FIles")

            FILE_PATH = "column_markings.json"
            BRANCH = "customy"

            # تحضير البيانات للحفظ
            payload = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "selected_seg_kgm_values": selected_seg_values if 'selected_seg_values' in locals() else [],
                "marked_columns": mark_cols if 'mark_cols' in locals() else [],
                "selected_columns": cols_to_show if 'cols_to_show' in locals() else [],
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



