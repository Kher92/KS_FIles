import pandas as pd 


a = ['30-40','40-50','50-60']
b = ""
while b not in a:
    print("verfä" \
    "ügbare werte", a)
    b = input("select einen wert ").lower()
    print(b)
    if b in a:
        break




