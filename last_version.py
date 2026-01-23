import streamlit as st
import pandas as pd
import datetime
import json
from github import Github

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
        "Report_nutribiona_2026-01-23_12-38-40.xlsx",
        header=1  # تجاهل صف Männer / Frauen
    )

    df.columns = (
        df.columns
        .astype(str)
        .str.strip()
        .str.lower()
        .str.replace("unnamed:.*", "", regex=True)
    )

    df = df.loc[:, df.columns != ""]
    return df

df = load_data()

# ---------------- Column selection ----------------
st.subheader("Spalten auswählen")

cols_to_show = st.multiselect(
    "Welche Spalten anzeigen?",
    options=df.columns.tolist(),
    default=df.columns.tolist()
)

df_display = df[cols_to_show].copy()

# ---------------- Filters ----------------
st.subheader("Filter setzen")

filter_cols = st.multiselect(
    "Filter nach Spalten",
    options=df_display.columns.tolist()
)

for col in filter_cols:
    unique_values = df_display[col].dropna().unique().tolist()

    selected = st.multiselect(
        f"Filter {col}",
        options=unique_values,
        default=unique_values
    )

    if selected:
        df_display = df_display[df_display[col].isin(selected)]

# ---------------- Column Highlight ----------------
st.subheader("Spalten markieren")

mark_cols = st.multiselect(
    "Welche Spalten gelb markieren?",
    options=df_display.columns.tolist()
)

def highlight_columns(df, cols):
    styles = pd.DataFrame("", index=df.index, columns=df.columns)
    for c in cols:
        styles[c] = "background-color: yellow"
    return styles

st.dataframe(
    df_display.style.apply(
        highlight_columns,
        cols=mark_cols,
        axis=None
    ),
    use_container_width=True
)

# ---------------- Download CSV ----------------
csv_data = df_display.to_csv(index=False, sep=";").encode("latin1")

st.download_button(
    label="⬇️ Download CSV",
    data=csv_data,
    file_name="filtered_data.csv",
    mime="text/csv"
)

# ---------------- Notes & Save to GitHub ----------------
st.divider()
st.subheader("Notizen für Suzzi")

notes = st.text_area("Notiz schreiben (z.B. انتهيت)")

if st.button("💾 Speichern"):
    if not mark_cols and not notes.strip():
        st.warning("⚠️ لا يوجد تعليم أو ملاحظة")
    else:
        try:
            token = st.secrets["GITHUB_TOKEN"]
            g = Github(token)
            repo = g.get_repo("Kher92/KS_FIles")

            FILE_PATH = "column_markings.json"
            BRANCH = "customy"

            payload = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "marked_columns": mark_cols,
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
