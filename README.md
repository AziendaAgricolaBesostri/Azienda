# BESOSTRI FARM – PWA COMPLETA

Questa è la PWA pronta di **BESOSTRI FARM** (Raccolti OMAR/FABRIZIO, vista Capo, Essiccatoi 1/2).

## Da fare (solo da iPhone)
1. Vai su **console.firebase.google.com** → crea progetto `besostri-farm`.
2. In **Impostazioni progetto → SDK per app Web**, copia i parametri e incollali in `lib/firebase_options.dart` al posto dei `PASTE_...`.
3. Carica questo ZIP su **Google Drive** e prendi il link di condivisione.
4. Apri **codemagic.io** → *Aggiungi URL* → incolla il link allo ZIP → scegli build **Web**.
5. Scarica l'output `build/web` e caricalo in **Firebase Hosting** (scheda Hosting nella console).
6. Otterrai un link pubblico tipo `https://besostri-farm.web.app`.
7. Apri il link sui telefoni e fai **Aggiungi a Home** (Safari/Chrome).

## Firestore (regole test)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // SOLO PER TEST
    }
  }
}
```
Ricordati poi di mettere regole più sicure (login) quando vuoi.
 
