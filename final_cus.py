import streamlit as st
import pandas as pd
import os
import matplotlib.pyplot as plt
import seaborn as sns
import datetime

from github import Github



# --- إعداد الصفحة ---
st.set_page_config(
    page_title="Gemini Dashboard",
    page_icon="☁️",
    layout="wide"
)

gemini = st.image("logo.jpg",width=500)



st.markdown(
    f"""
    <div style="display:flex; align-items:center; justify-content:center; margin-bottom:25px;">
        <img src="https://img.freepik.com/free-vector/cute-hacker-operating-laptop-cartoon-vector-icon-illustration-people-technology-icon-isolated-flat_138676-7079.jpg?semt=ais_hybrid&w=740&q=80"
             style="
                width:90px;
                height:90px;
                border-radius:50%;
                object-fit:cover;
                border:3px solid #0DC3EC;
                margin-right:15px;
             ">
        <div>
            <h2 style="margin:0;">Kher Sarakbi</h2>
            <p style="margin:0; color:gray;">Gemini Direct Dashboard</p>
        </div>
    </div>
    """,
    unsafe_allow_html=True
)



@st.cache_data
def load_data():
    df = pd.read_csv("f.csv", sep=";")  # ت
    df.columns = df.columns.str.lower().str.strip()
    return df

df = load_data()
print(df.columns.tolist())

colu = ['mb012', 'mb024', 'mb012_p', 'mb024_p']
df["multibayer"] = df[colu].apply(
    lambda row: [col for col in colu if row[col] == 1],
    axis=1
)
df = df.explode("multibayer")
df = df[df["multibayer"].notna()]
df.drop(columns=colu, inplace=True)

df["geschlecht"] = df["gendertypeid"].map({
    1: "Mann",
    2: "Frau"
})
df = df.drop(columns=["gendertypeid"])
df = df.dropna(subset=["score_kgm"])

df["score_kgm"] = pd.to_numeric(df["score_kgm"], errors='coerce')
cols_to_show = st.multiselect(
    "Wähle die Spalten Aus",
    options=df.columns.tolist(),
    default='score_kgm'
)

df_display = df[cols_to_show].copy()

filter_cols = st.multiselect(
    "Hier Kannst du filter setzen",
    options=df.columns.tolist(),
)

for col in filter_cols:
    unique_values = df[col].dropna().unique()
    st.write(unique_values)
    selected = st.multiselect(f"Filter {col}", options=unique_values, default=unique_values)
    df_display = df_display[df[col].isin(selected)]

df_head = df_display.copy()

if "score_kgm" in df_display.columns:
    total_score = round(df_display["score_kgm"].sum(), 2)  # ت
    total_score_str = f"{total_score:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

    df_head.loc["SUM"] = [""] * (len(df_head.columns)-1) + [total_score_str]

st.dataframe(df_head, use_container_width=True)

if "score_kgm" in df_display.columns:
    st.metric("Total Score KGM", f"{total_score:,.0f}")

df["score_kgm"] = pd.to_numeric(df["score_kgm"], errors='coerce')

plt.figure(figsize=(12,4))
sns.barplot(data=df, x="ealter", y="score_kgm", hue="geschlecht", estimator=sum, palette="viridis")
plt.title("Sum of Score KGM by Age and Gender")
plt.xlabel("Alter Klassen")
plt.ylabel("Total Score KGM")
st.pyplot(plt.gcf())




# plt.figure(figsize=(12,6))

# sns.countplot(
#     data=df,
#     x="alter_kl",
#     hue="geschlecht",
#     palette="viridis"
# )

# plt.title("Count by Age and Gender")
# plt.xlabel("Alter Klassen")
# plt.ylabel("Anzahl")
# plt.show()

csv_data = df_display.to_csv(index=False, sep=",").encode("latin1")
st.download_button(
    label="Download CSV",
    data=csv_data,
    file_name="filtered_data.csv",
    mime="text/csv"
)

st.markdown("Notizen für Suzzi")
notes = st.text_area("einfach hinschreiben")

# زر الحفظ
if st.button("speichern"):
    if notes.strip():
        try:
            from github import Github
            import datetime

            REPO_NAME = "Kher92/KS_FIles"
            FILE_PATH = "client_notes.txt"
            BRANCH_NAME = "Customy"

            token = st.secrets["GITHUB_TOKEN"]
            g = Github(token)
            repo = g.get_repo(REPO_NAME)

            try:
                contents = repo.get_contents(FILE_PATH, ref=BRANCH_NAME)
                current_notes = contents.decoded_content.decode()
                sha = contents.sha
            except:
                current_notes = ""
                sha = None

            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            new_note = f"\n---\n[{timestamp}] {notes}"
            updated_notes = current_notes + new_note

            if sha:
                repo.update_file(FILE_PATH, "Add new note via Streamlit", updated_notes, sha, branch=BRANCH_NAME)
            else:
                repo.create_file(FILE_PATH, "Create notes file via Streamlit", updated_notes, branch=BRANCH_NAME)

            st.success("✅ ES wurde gespeichert")

        except Exception as e:
            st.error(f"❌ Error: {e}")
    else:
        st.warning("Nichts zum Speichern.")
