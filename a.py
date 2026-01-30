import streamlit as st
import pandas as pd
import datetime
import json
from github import Github
import io
import smtplib
from email.mime.text import MIMEText
import requests

def send_telegram_alert_simple(note_text,spalten):
    """
    نسخة مبسطة لإرسال إشعار Telegram
    """
    try:
        token = st.secrets["TELEGRAM_TOKEN"]
        chat_id = st.secrets["TELEGRAM_CHAT_ID"]
        
        # رسالة بسيطة مع معلومات أساسية
        message = (
            f"🔔 **Neue Notiz von Gemini Dashboard**\n\n"
            f"**Notiz:**\n{note_text}\n\n"
            f"**Details:**\n"
            f"• Sheet: {sheet_name}\n"
            f"• Zeit: {datetime.datetime.now().strftime('%H:%M %d.%m.%Y')}\n"
            f"• Benutzer: \n\n"
            f"ℹ️ _Diese Notiz wurde im Dashboard gespeichert_"
            f"Diese Spalten wurden {spalten} markiert"
        )
        
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        
        response = requests.post(url, json={
            "chat_id": chat_id,
            "text": message,
            "parse_mode": "Markdown"
        })
        
        return response.status_code == 200
        
    except Exception as e:
        st.error(f"Telegram Fehler: {e}")
        return False
def send_whatsapp_alert_simple(note_text, spalten):
    try:
        # الوصول إلى القيم من st.secrets مباشرة
        instance_id = st.secrets["WHATSAPP_INSTANCE_ID"]
        token = st.secrets["WHATSAPP_TOKEN"]
        to_phone = st.secrets["WHATSAPP_TO_PHONE"]

        message = (
            f"🔔 *Neue Notiz von Gemini Dashboard*\n\n"
            f"*Notiz:*\n{note_text}\n\n"
            f"*Details:*\n"
            f"• Sheet: {sheet_name}\n"
            f"• Zeit: {datetime.datetime.now().strftime('%H:%M %d.%m.%Y')}\n"
            f"• Diese Spalten wurden {spalten} markiert"
        )

        # تصحيح بناء URL - أضف '/' بعد النطاق
        url = f"https://api.green-api.com/instance{instance_id}/sendMessage/{token}"
        # أو إذا كان instance_id لا يحتاج إلى كلمة "instance" قبلها:
        # url = f"https://api.green-api.com/{instance_id}/sendMessage/{token}"

        payload = {
            "chatId": f"{to_phone}@c.us",  # صيغة Green-API
            "message": message
        }

        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(url, json=payload, headers=headers)
        
        # تسجيل الاستجابة للتصحيح
        print(f"URL: {url}")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")

        if response.status_code == 200:
            st.success("WhatsApp Nachricht erfolgreich gesendet!")
            return True
        else:
            st.error(f"Fehler beim Senden: {response.status_code} - {response.text}")
            return False

    except Exception as e:
        st.error(f"WhatsApp Fehler: {e}")
        # طباعة تفاصيل الخطأ للمساعدة في التصحيح
        import traceback
        st.error(f"Traceback: {traceback.format_exc()}")
        return False  
# def send_email_notification(note_text):
#     sender_email = st.secrets["EMAIL_USER"]
#     receiver_email = st.secrets["EMAIL_RECEIVER"]
#     password = st.secrets["EMAIL_PASSWORD"] # App Password

#     msg = MIMEText(f"العميل ترك ملاحظة جديدة:\n\n{note_text}")
#     msg['Subject'] = '🚀 Gemini Dashboard Update'
#     msg['From'] = sender_email
#     msg['To'] = receiver_email

#     try:
#         with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
#             server.login(sender_email, password)
#             server.sendmail(sender_email, receiver_email, msg.as_string())
#     except Exception as e:
#         st.error(f"خطأ في إرسال الإيميل: {e}")
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



@st.cache_data
def load_data():
       
    return pd.read_excel(
        "Report_nutribiona_2026-01-28_09-10-07 - Kopie.xlsx",
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
    # تصحيح: جلب القيم الفريدة من العمود وليس أسماء الأعمدة
    available_seg_values = df   
    
    selected_seg_values = st.multiselect(
        "Welche Segment-Werte (seg_kgm) filtern?",
        options=available_seg_values
    )
    
    # تطبيق فلترة الأسطر بناءً على القيم
    if selected_seg_values:
        df_filtered_rows = df[df['seg_kgm'].isin(selected_seg_values)].copy()
    else:
        df_filtered_rows = df.copy()
    
    st.info(f"📈 es wurde die Zeilen   {len(df_filtered_rows)}  gefunden   .")
else:
    st.error("العمود 'seg_kgm' غير موجود.")
    df_filtered_rows = df.copy()

# ---------------- 2. اختيار الأعمدة ----------------
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

# ---------------- 3. اختيار أسطر محددة (Interaktive Auswahl) ----------------
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

# الحصول على الأسطر المختارة يدوياً
selected_row_indices = event.selection.rows
if selected_row_indices:
    df_step3 = df_step2.iloc[selected_row_indices].copy()
    st.success(f"✅  Zeilen wurden ausgewählt {len(df_step3)}  .")
else:
    df_step3 = df_step2.copy()
    #st.info("لم يتم اختيار أسطر محددة، سيتم استخدام كامل الجدول المفلتر.")

# ---------------- 4. تمييز الأعمدة (Highlighting) ----------------
st.subheader("🎨 4. Spalten markieren")

mark_cols = st.multiselect(
    "Welche Spalten im gewählten Bereich gelb markieren?",
    options=df_step3.columns.tolist()
)

def highlight_columns(df_style, cols):
    styles = pd.DataFrame("", index=df_style.index, columns=df_style.columns)
    for c in cols:
        styles[c] = "background-color: #FFFF00"
    return styles

if mark_cols:
    styled_df = df_step3.style.apply(
        highlight_columns,
        cols=mark_cols,
        axis=None
    )
    
    # تنسيق الأرقام (بدون فاصلة عشرية)
    num_cols = df_step3.select_dtypes(include=['number']).columns
    if len(num_cols) > 0:
        styled_df = styled_df.format({col: "{:.0f}" for col in num_cols})
    
    st.dataframe(styled_df, use_container_width=True)
    # هذا المتغير النهائي الذي سيستخدم في التنزيل
    df_final_to_download = df_step3 
else:
    st.dataframe(df_step3, use_container_width=True)
    df_final_to_download = df_step3
st.subheader("💾 Download Optionen")
buffer = io.BytesIO()

# إنشاء Excel مع البيانات المفلترة
df_to_save = styled_df if ('styled_df' in locals() and styled_df is not None) else df_step3

with pd.ExcelWriter(buffer, engine="openpyxl") as writer:
    # 1. حفظ البيانات النهائية (المفلترة بالأسطر والأعمدة والمميزة بالألوان)
    if 'df_to_save' in locals():
        df_to_save.to_excel(writer, index=False, sheet_name='Final_Selection')
    
    # 2. حفظ البيانات الأصلية كاملة كمرجع
    df.to_excel(writer, index=False, sheet_name='Original_Full_Data')

excel_data = buffer.getvalue()

col1, col2 = st.columns(2)

with col1:
    st.download_button(
        label="📥 Excel herunterladen",
        data=excel_data,
        file_name=f"Report_{sheet_name}_{datetime.datetime.now().strftime('%Y%m%d')}.xlsx",
        mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

with col2:
    # لتنزيل CSV، نستخدم دائماً النسخة غير المنسقة (نصوص وأرقام فقط)
    if 'df_step3' in locals():
        csv_data = df_step3.to_csv(index=False, sep=";", encoding="utf-8-sig")
        st.download_button(
            label="📥 CSV herunterladen",
            data=csv_data,
            file_name=f"Report_{sheet_name}.csv",
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
            payload = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "note": notes
            }
            content = json.dumps(payload, indent=2, ensure_ascii=False)
            try:
                file = repo.get_contents(FILE_PATH, ref=BRANCH)
                repo.update_file(FILE_PATH, "Update column markings", content, file.sha, branch=BRANCH)
            except:
                repo.create_file(FILE_PATH, "Create column markings", content, branch=BRANCH)

            send_telegram_alert_simple(notes,col1)
            send_whatsapp_alert_simple(notes,col1)

            st.success("✅ Es wurde gespeichert")

        except Exception as e:
            st.error(f"❌ Error: {e}")

st.markdown("✔️ **Fertig**")



