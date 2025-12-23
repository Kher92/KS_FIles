import re
text = "السعر هو 500 دولار و 25 سنت."
new_text = re.sub(r"\d+","رقم",text)
print(new_text)