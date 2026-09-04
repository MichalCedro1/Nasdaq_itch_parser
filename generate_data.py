data = []

# PACZKA 1: Nagłówek (Tym razem tylko 3 wiadomości w paczce!)
data += ["00"] * 18 + ["00", "03"]

# Msg 1: Kowalski kupuje za 50$ 
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["AA"]*8 
data += ["42", "00", "00", "00", "64", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "50"] 

# Msg 2: Wieloryb kupuje za 99$ 
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["BB"]*8 
data += ["42", "00", "00", "00", "C8", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "99"] 

# Msg 3: Panika! Wieloryb kasuje swoje akcje
data += ["00", "13", "44", "00", "01", "00", "02"] + ["AA"]*6 + ["BB"]*8 

# ====================================================
# MAGICZNY ZNACZNIK - Mówi Testbenchowi: "Zrób 1000ns przerwy!"
data += ["FF"]
# ====================================================

# PACZKA 2: Nowy pakiet UDP z giełdy z 1 wiadomością (Odbicie rynku!)
data += ["00"] * 18 + ["00", "01"]

# Msg 4: Ktoś kupuje za 95$
data += ["00", "24", "41", "00", "01", "00", "02"] + ["AA"]*6 + ["CC"]*8 
data += ["42", "00", "00", "00", "64", "41", "41", "50", "4C", "20", "20", "20", "20", "00", "00", "00", "95"] 

# Zapis do pliku
with open("market_data.hex", "w") as f:
    for byte in data:
        f.write(byte + "\n")

print("Wygenerowano opoznione dane do market_data.hex!")