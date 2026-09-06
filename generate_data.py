# Skrypt generujący surowe dane giełdowe ITCH (Plik HEX)
# WERSJA V2: Czysty rynkowy żywioł, żadnych sztucznych opóźnień!

data = []

# 1. Nagłówek MoldUDP64 (20 bajtów) - 4 wiadomości w jednej paczce!
data += ["00"] * 18 + ["00", "04"]

# 2. WIADOMOŚĆ 'A': Kowalski kupuje za 50$ (100 akcji)
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["AA"]*8 
data += ["42", "00", "00", "00", "64", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "50"] 

# 3. WIADOMOŚĆ 'A': Wieloryb kupuje za 99$ (200 akcji)
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["BB"]*8 
data += ["42", "00", "00", "00", "C8", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "99"] 

# 4. WIADOMOŚĆ 'D': Panika! Wieloryb kasuje swoje 200 akcji
data += ["00", "13", "44", "00", "01", "00", "02"] + ["AA"]*6 + ["BB"]*8 

# 5. WIADOMOŚĆ 'A': Nowy klient kupuje za 95$ - LECI BEZPOŚREDNIO ZA KASOWANIEM!
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["CC"]*8 
data += ["42", "00", "00", "00", "64", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "95"] 

# Zapis do pliku
with open("market_data.hex", "w") as f:
    for byte in data:
        f.write(byte + "\n")

print(f"Wygenerowano {len(data)} bajtow do pliku market_data.hex!")