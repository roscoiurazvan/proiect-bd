# Proiect SC-ELROM - Baze de Date

Acesta este un proiect universitar la materia Baze de Date (BD), reprezentând site-ul de prezentare pentru o firmă de instalații electrice (SC-ELROM), conectat la **Supabase** (pentru backend) și optimizat pentru a fi găzduit pe **Cloudflare Pages**.

## Funcționalități (Backend - Supabase)
Acest proiect folosește Supabase (PostgreSQL) pentru următoarele funcționalități:

1. **Autentificare Utilizatori** (Email & Parolă)
2. **Formular de Contact** - Mesajele vizitatorilor sunt salvate în baza de date.
3. **Sistem de Programări** - Utilizatorii pot stabili o întâlnire, iar aceasta ajunge direct în BD.
4. **Newsletter** - Sistem de abonare la noutăți (verificare duplicat pe email).
5. **Recenzii Dinamice** - Utilizatorii autentificați pot lăsa recenzii (cu note de 1-5 stele). Acestea apar pe prima pagină după ce sunt aprobate de un administrator.
6. **Panou de Administrare (Admin Dashboard)** - Accesibil doar utilizatorilor cu drepturi speciale, unde se pot vedea și gestiona:
   - Mesajele (marcare ca citit / ștergere)
   - Programările (schimbare status: în așteptare, confirmată, anulată)
   - Abonările la newsletter
   - Recenziile (aprobare pentru afișare publică)

## Tehnologii Folosite
* **Frontend**: HTML5, CSS3 (Vanilla), JavaScript
* **Backend / Bază de Date**: Supabase (PostgreSQL) + Supabase JS Client
* **Hosting**: Cloudflare Pages

## Structura Bazei de Date
Proiectul include un fișier SQL complet `database/setup.sql` care creează structura relațională și politicile de securitate (RLS - Row Level Security).
Tabele utilizate:
- `mesaje_contact`
- `programari`
- `abonati_newsletter`
- `recenzii`
- `admin_users` (Face legătura cu sistemul nativ `auth.users` din Supabase)

## Instrucțiuni de Rulare
1. Creează un cont gratuit pe [Supabase.com](https://supabase.com).
2. Rulează conținutul din `database/setup.sql` în SQL Editor-ul proiectului tău Supabase.
3. Deschide fișierul `index.html` în browser. (Nu necesită server local NodeJS pentru frontend, poate fi rulat direct sau prin VSCode Live Server).
4. Creează un cont pe site cu adresa de email, apoi acordă-i drepturi de administrator din Supabase rulând query-ul corespunzător.

---
*Proiect realizat pentru universitate.*
