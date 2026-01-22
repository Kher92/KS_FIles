import streamlit as st
from github import Github
import os
import datetime

# --- إعداد صفحة Streamlit ---
st.set_page_config(
    page_title="Gemini Dashboard",
    page_icon="☁️",
    layout="wide"
)

st.markdown("<h2>Notizen für Suzzi</h2>", unsafe_allow_html=True)

# مربع النص
notes = st.text_area("einfach hinschreiben")

# زر الحفظ
if st.button("speichern"):
    if notes.strip():
        try:
            # الاتصال بـ GitHub
            GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
            REPO_NAME = "username/repo"  # استبدل بمستودعك
            FILE_PATH = "client_notes.txt"

            g = Github(GITHUB_TOKEN)
            repo = g.get_repo(REPO_NAME)

            # قراءة محتوى الملف الحالي
            try:
                contents = repo.get_contents(FILE_PATH)
                current_notes = contents.decoded_content.decode()
                sha = contents.sha
            except:
                current_notes = ""
                sha = None

            # إعداد الملاحظة الجديدة مع التاريخ
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            new_note = f"\n---\n[{timestamp}] {notes}"

            updated_notes = current_notes + new_note

            # رفع الملف إلى GitHub
            if sha:
                repo.update_file(FILE_PATH, "Add new note via Streamlit", updated_notes, sha)
            else:
                repo.create_file(FILE_PATH, "Create notes file via Streamlit", updated_notes)

            st.success("✅ الملاحظة تم حفظها على GitHub بنجاح!")

        except Exception as e:
            st.error(f"❌ خطأ أثناء الحفظ: {e}")
    else:
        st.warning("لا توجد ملاحظة لحفظها.")
