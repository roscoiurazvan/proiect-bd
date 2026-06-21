-- =============================================
-- SC-ELROM Supabase Database Setup
-- Run this entire script in the Supabase SQL Editor
-- =============================================

-- 1. TABELA: mesaje_contact
CREATE TABLE IF NOT EXISTS mesaje_contact (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nume TEXT NOT NULL,
    email TEXT NOT NULL,
    mesaj TEXT NOT NULL,
    citit BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABELA: programari
CREATE TABLE IF NOT EXISTS programari (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nume TEXT NOT NULL,
    telefon TEXT NOT NULL,
    data_intalnire DATE NOT NULL,
    status TEXT DEFAULT 'in_asteptare' CHECK (status IN ('in_asteptare', 'confirmata', 'anulata')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABELA: abonati_newsletter
CREATE TABLE IF NOT EXISTS abonati_newsletter (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    activ BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABELA: recenzii
CREATE TABLE IF NOT EXISTS recenzii (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    nume_autor TEXT NOT NULL,
    oras TEXT NOT NULL,
    mesaj TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    aprobat BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABELA: admin_users
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Activare RLS pe toate tabelele
ALTER TABLE mesaje_contact ENABLE ROW LEVEL SECURITY;
ALTER TABLE programari ENABLE ROW LEVEL SECURITY;
ALTER TABLE abonati_newsletter ENABLE ROW LEVEL SECURITY;
ALTER TABLE recenzii ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Functie helper: verifica daca userul curent este admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ---- mesaje_contact ----
-- Oricine poate trimite un mesaj
CREATE POLICY "Oricine poate trimite mesaje" ON mesaje_contact
    FOR INSERT WITH CHECK (true);

-- Doar adminul poate citi mesajele
CREATE POLICY "Adminul poate citi mesajele" ON mesaje_contact
    FOR SELECT USING (is_admin());

-- Doar adminul poate actualiza (marca ca citit)
CREATE POLICY "Adminul poate actualiza mesajele" ON mesaje_contact
    FOR UPDATE USING (is_admin());

-- Doar adminul poate sterge
CREATE POLICY "Adminul poate sterge mesajele" ON mesaje_contact
    FOR DELETE USING (is_admin());

-- ---- programari ----
-- Oricine poate crea o programare
CREATE POLICY "Oricine poate crea programari" ON programari
    FOR INSERT WITH CHECK (true);

-- Doar adminul poate vedea programarile
CREATE POLICY "Adminul poate vedea programarile" ON programari
    FOR SELECT USING (is_admin());

-- Doar adminul poate actualiza statusul
CREATE POLICY "Adminul poate actualiza programarile" ON programari
    FOR UPDATE USING (is_admin());

-- Doar adminul poate sterge
CREATE POLICY "Adminul poate sterge programarile" ON programari
    FOR DELETE USING (is_admin());

-- ---- abonati_newsletter ----
-- Oricine se poate abona
CREATE POLICY "Oricine se poate abona" ON abonati_newsletter
    FOR INSERT WITH CHECK (true);

-- Doar adminul poate vedea abonatii
CREATE POLICY "Adminul poate vedea abonatii" ON abonati_newsletter
    FOR SELECT USING (is_admin());

-- Doar adminul poate actualiza
CREATE POLICY "Adminul poate actualiza abonatii" ON abonati_newsletter
    FOR UPDATE USING (is_admin());

-- Doar adminul poate sterge
CREATE POLICY "Adminul poate sterge abonatii" ON abonati_newsletter
    FOR DELETE USING (is_admin());

-- ---- recenzii ----
-- Oricine poate vedea recenziile aprobate
CREATE POLICY "Oricine poate vedea recenziile aprobate" ON recenzii
    FOR SELECT USING (aprobat = true OR is_admin());

-- Utilizatorii autentificati pot trimite recenzii
CREATE POLICY "Utilizatorii autentificati pot trimite recenzii" ON recenzii
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Doar adminul poate actualiza (aproba/respinge)
CREATE POLICY "Adminul poate actualiza recenziile" ON recenzii
    FOR UPDATE USING (is_admin());

-- Doar adminul poate sterge
CREATE POLICY "Adminul poate sterge recenziile" ON recenzii
    FOR DELETE USING (is_admin());

-- ---- admin_users ----
-- Doar adminul poate vedea lista de admini
CREATE POLICY "Adminul poate vedea adminii" ON admin_users
    FOR SELECT USING (is_admin());

-- =============================================
-- DATE INITIALE (SEED DATA)
-- =============================================

-- Inserare recenzii existente (cele 3 hardcodate din site)
INSERT INTO recenzii (nume_autor, oras, mesaj, rating, aprobat) VALUES
    ('Kevin Wilson', 'Cardiff, Wales', 'Am achizitionat serviciile acum mai bine de 5 ani si nu am intampinat niciodata probleme.', 5, true),
    ('Kevin Muller', 'Bremen, Germany', 'Calitatea serviciilor este extraordinara. Totul arata de parca a fost facut sa reziste pentru eternitate.', 5, true),
    ('Sara Gotenberg', 'Malmo, Sweden', 'Eu si sotul meu ne-am dorit o instalatie electrica de durata, iar multumita celor de la SC-ELROM, dorinta noastra a fost indeplinita cu succes.', 5, true);

-- =============================================
-- SETUP ADMIN
-- =============================================
-- PASUL 1: Mai intai, inregistreaza-te pe site cu email-ul admin@admin.ro
-- PASUL 2: Dupa inregistrare, ruleaza comanda de mai jos in SQL Editor
--          inlocuind 'USER_ID_AICI' cu UUID-ul userului din tabela auth.users
--
-- INSERT INTO admin_users (user_id) 
-- SELECT id FROM auth.users WHERE email = 'admin@admin.ro';
--
-- SAU daca vrei sa rulezi direct dupa ce userul exista:
-- (Decommenteaza linia de mai jos DUPA ce te-ai inregistrat)
-- INSERT INTO admin_users (user_id) SELECT id FROM auth.users WHERE email = 'admin@admin.ro';
