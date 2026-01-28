import streamlit as st
import pandas as pd
import datetime
import json
import requests  # أضف هذا الاستيراد
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
    return pd.read_excel(
        "Report_nutribiona.xlsx",
        sheet_name=None,
        header=1
    )

sheets = load_data()

sheet_name = st.selectbox(
    "📄 SheetAuswahl",
    options=list(sheets.keys())
)

df = sheets[sheet_name]

# تنظيف الأعمدة
df.columns = (
    df.columns
    .astype(str)
    .str.strip()
    .str.lower()
    .str.replace(r"unnamed:.*", "", regex=True)
)
df = df.loc[:, df.columns != ""]

# ---------------- متغيرات الجلسة ----------------
# تهيئة متغيرات الجلسة إذا لم تكن موجودة
if 'selected_columns' not in st.session_state:
    st.session_state.selected_columns = []
if 'filter_values' not in st.session_state:
    st.session_state.filter_values = {}
if 'marked_columns' not in st.session_state:
    st.session_state.marked_columns = []
if 'current_note' not in st.session_state:
    st.session_state.current_note = ""

# ---------------- فلترة الأعمدة المراد عرضها ----------------
st.sidebar.header("🔍 Filter Optionen")

# فلترة الأعمدة المراد عرضها
st.sidebar.subheader("1. Spalten auswählen")
all_columns = df.columns.tolist()
selected_columns = st.sidebar.multiselect(
    "Welche Spalten anzeigen?",
    options=all_columns,
    default=all_columns[:10] if len(all_columns) > 10 else all_columns
)

# حفظ في الجلسة
st.session_state.selected_columns = selected_columns

# إنشاء DataFrame مع الأعمدة المختارة
df_filtered = df[selected_columns].copy() if selected_columns else df.copy()

# ---------------- فلترة الصفوف ----------------
st.sidebar.subheader("2. Spaltenfilter für Zeilen")

# تخزين الفلترات في الجلسة
for col in selected_columns:
    if df_filtered[col].dtype in ['int64', 'float64']:
        # فلتر رقمي للنطاق
        min_val = float(df_filtered[col].min())
        max_val = float(df_filtered[col].max())
        
        selected_range = st.sidebar.slider(
            f"{col} Bereich",
            min_val,
            max_val,
            (min_val, max_val)
        )
        st.session_state.filter_values[col] = selected_range
    else:
        # فلتر نصي للقيم الفريدة
        unique_vals = df_filtered[col].dropna().unique().tolist()
        
        if len(unique_vals) <= 20:  # إذا كان عدد القيم معقول
            selected_vals = st.sidebar.multiselect(
                f"{col} Werte",
                options=unique_vals,
                default=unique_vals
            )
            st.session_state.filter_values[col] = selected_vals
        else:
            # استخدام حقل نصي للبحث
            search_text = st.sidebar.text_input(
                f"{col} enthält",
                ""
            )
            st.session_state.filter_values[col] = search_text

# تطبيق الفلترات على DataFrame
df_filtered_rows = df_filtered.copy()

for col, filter_val in st.session_state.filter_values.items():
    if col in df_filtered_rows.columns:
        if isinstance(filter_val, tuple) and len(filter_val) == 2:  # فلتر رقمي
            min_val, max_val = filter_val
            df_filtered_rows = df_filtered_rows[
                (df_filtered_rows[col] >= min_val) & 
                (df_filtered_rows[col] <= max_val)
            ]
        elif isinstance(filter_val, list):  # فلتر القيم المحددة
            if filter_val:
                df_filtered_rows = df_filtered_rows[df_filtered_rows[col].isin(filter_val)]
        elif isinstance(filter_val, str) and filter_val:  # فلتر البحث النصي
            df_filtered_rows = df_filtered_rows[
                df_filtered_rows[col].astype(str).str.contains(filter_val, case=False, na=False)
            ]

# ---------------- العرض الرئيسي ----------------
st.subheader("📊 Gefilterte Daten")

# عرض إحصائيات الفلترة
col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Ursprüngliche Zeilen", len(df))
with col2:
    st.metric("Gefilterte Zeilen", len(df_filtered_rows))
with col3:
    st.metric("Angezeigte Spalten", len(selected_columns))

# عرض البيانات المفلترة
if not df_filtered_rows.empty:
    st.dataframe(
        df_filtered_rows,
        use_container_width=True,
        height=400
    )
else:
    st.warning("⚠️ Keine Daten entsprechen den Filterkriterien")

# ---------------- خيارات التمييز (Highlighting) ----------------
st.subheader("🎨 Spalten markieren")

marked_columns = st.multiselect(
    "Welche Spalten gelb markieren?",
    options=selected_columns,
    default=[]
)

# حفظ في الجلسة
st.session_state.marked_columns = marked_columns

def highlight_columns(df, cols):
    styles = pd.DataFrame("", index=df.index, columns=df.columns)
    for c in cols:
        if c in df.columns:
            styles[c] = "background-color: yellow"
    return styles

if marked_columns and not df_filtered_rows.empty:
    styled_df = df_filtered_rows.style.apply(
        highlight_columns,
        cols=marked_columns,
        axis=None
    )
    
    # تنسيق الأرقام
    numeric_cols = df_filtered_rows.select_dtypes(include=['number']).columns
    for col in numeric_cols:
        styled_df = styled_df.format({col: "{:.2f}"})
    
    st.dataframe(
        styled_df,
        use_container_width=True
    )

# ---------------- التنزيل ----------------
st.subheader("💾 Download Optionen")

# إنشاء Excel مع البيانات المفلترة
buffer = io.BytesIO()
with pd.ExcelWriter(buffer, engine="openpyxl") as writer:
    df_filtered_rows.to_excel(writer, index=False, sheet_name='Gefilterte_Daten')
    df.to_excel(writer, index=False, sheet_name='Original_Daten')

excel_data = buffer.getvalue()

col1, col2 = st.columns(2)
with col1:
    st.download_button(
        label="📥 Gefilterte Daten herunterladen",
        data=excel_data,
        file_name="gefilterte_daten.xlsx",
        mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

with col2:
    csv_data = df_filtered_rows.to_csv(index=False, sep=";", encoding="utf-8-sig")
    st.download_button(
        label="📥 Als CSV herunterladen",
        data=csv_data,
        file_name="gefilterte_daten.csv",
        mime="text/csv"
    )

# ---------------- دالة إرسال Telegram ----------------
def send_telegram_alert(note_text, selected_columns, filter_values, marked_columns):
    """
    إرسال إشعار إلى Telegram مع تفاصيل التغييرات
    """
    try:
        token = st.secrets.get("TELEGRAM_TOKEN")
        chat_id = st.secrets.get("TELEGRAM_CHAT_ID")
        
        if not token or not chat_id:
            st.warning("⚠️ Telegram credentials not configured")
            return False
        
        # تنسيق رسالة مفصلة
        message = (
            f"🔔 **Gemini Dashboard - Neue Änderungen**\n\n"
            f"📝 **Notiz:**\n{note_text}\n\n"
            f"📊 **Ausgewählte Spalten ({len(selected_columns)}):**\n"
        )
        
        # إضافة الأعمدة المحددة
        cols_per_line = 5
        for i in range(0, len(selected_columns), cols_per_line):
            cols_chunk = selected_columns[i:i+cols_per_line]
            message += f"`{'`, `'.join(cols_chunk)}`\n"
        
        # إضافة الأعمدة المميزة
        if marked_columns:
            message += f"\n🎨 **Markierte Spalten ({len(marked_columns)}):**\n"
            message += f"`{'`, `'.join(marked_columns)}`\n"
        
        # إضافة الفلترات
        if filter_values:
            message += f"\n🔍 **Aktive Filter ({len(filter_values)}):**\n"
            for col, val in list(filter_values.items())[:5]:  # أول 5 فقط
                if isinstance(val, tuple):
                    message += f"• `{col}`: {val[0]} - {val[1]}\n"
                elif isinstance(val, list):
                    if len(val) <= 3:
                        message += f"• `{col}`: {', '.join(str(v) for v in val)}\n"
                    else:
                        message += f"• `{col}`: {len(val)} Werte ausgewählt\n"
                elif isinstance(val, str) and val:
                    message += f"• `{col}`: enthält '{val}'\n"
            
            if len(filter_values) > 5:
                message += f"• ... und {len(filter_values) - 5} weitere Filter\n"
        
        # إضافة التوقيت
        message += f"\n⏰ **Zeitpunkt:** {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        message += f"📈 **Daten:** {len(df_filtered_rows)} Zeilen (von {len(df)})"
        
        # إرسال الرسالة
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        
        payload = {
            "chat_id": chat_id,
            "text": message,
            "parse_mode": "Markdown",
            "disable_web_page_preview": True
        }
        
        response = requests.post(url, json=payload, timeout=10)
        
        if response.status_code == 200:
            return True
        else:
            error_msg = response.json().get('description', 'Unknown error')
            st.error(f"Telegram error: {error_msg}")
            return False
            
    except Exception as e:
        st.error(f"❌ Error sending Telegram: {e}")
        return False

# ---------------- القسم الأخير للملاحظات ----------------
st.divider()
st.subheader("📝 Notizen für Suzzi")

# حقل النص مع حفظ في الجلسة
notes = st.text_area(
    "Notiz schreiben",
    value=st.session_state.current_note,
    height=150,
    placeholder="Schreiben Sie hier Ihre Notizen und Änderungen..."
)

# حفظ الملاحظة في الجلسة
st.session_state.current_note = notes

# زر الحفظ مع إرسال Telegram
if st.button("💾 Speichern & Telegram senden", type="primary"):
    if not notes.strip():
        st.warning("⚠️ Bitte erst deine Anmerkung schreiben")
    else:
        try:
            # 1. إرسال إشعار Telegram أولاً
            telegram_sent = send_telegram_alert(
                notes,
                st.session_state.selected_columns,
                st.session_state.filter_values,
                st.session_state.marked_columns
            )
            
            if telegram_sent:
                st.success("✅ Telegram-Benachrichtigung gesendet")
            
            # 2. حفظ في GitHub
            token = st.secrets["GITHUB_TOKEN"]
            g = Github(token)
            repo = g.get_repo("Kher92/KS_FIles")

            FILE_PATH = "column_markings.json"
            BRANCH = "customy"

            payload = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "note": notes,
                "selected_columns": st.session_state.selected_columns,
                "marked_columns": st.session_state.marked_columns,
                "filter_values": st.session_state.filter_values,
                "data_stats": {
                    "original_rows": len(df),
                    "filtered_rows": len(df_filtered_rows),
                    "selected_columns_count": len(st.session_state.selected_columns),
                    "marked_columns_count": len(st.session_state.marked_columns)
                }
            }

            content = json.dumps(payload, indent=2, ensure_ascii=False)

            try:
                file = repo.get_contents(FILE_PATH, ref=BRANCH)
                repo.update_file(
                    FILE_PATH,
                    "Update column markings and notes",
                    content,
                    file.sha,
                    branch=BRANCH
                )
            except:
                repo.create_file(
                    FILE_PATH,
                    "Create column markings and notes",
                    content,
                    branch=BRANCH
                )

            st.success("✅ تم حفظ التعليم والملاحظة بنجاح في GitHub")
            
            # 3. إظهار ملخص التغييرات
            with st.expander("📋 Änderungsübersicht anzeigen", expanded=False):
                st.json(payload)
                
            # 4. تنظيف الملاحظة بعد الحفظ
            st.session_state.current_note = ""
            st.rerun()
            
        except Exception as e:
            st.error(f"❌ Error: {e}")

# زر لمعاينة Telegram
if st.button("👁️ Telegram-Vorschau", help="Zeigt eine Vorschau der Telegram-Nachricht"):
    if notes.strip():
        preview_message = f"**Vorschau Telegram-Nachricht:**\n\n{notes}\n\n"
        preview_message += f"Spalten: {len(st.session_state.selected_columns)}\n"
        preview_message += f"Markiert: {len(st.session_state.marked_columns)}\n"
        preview_message += f"Filter: {len(st.session_state.filter_values)}"
        
        st.info(preview_message)
    else:
        st.warning("Bitte zuerst eine Notiz schreiben")

# زر لمسح كل شيء
if st.button("🗑️ Alles zurücksetzen"):
    st.session_state.selected_columns = []
    st.session_state.filter_values = {}
    st.session_state.marked_columns = []
    st.session_state.current_note = ""
    st.success("✅ Alle Einstellungen zurückgesetzt")
    st.rerun()

st.markdown("✔️ **Fertig**")