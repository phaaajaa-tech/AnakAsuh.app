-- Tabel users: akun pengguna (Anak Asuh, Sponsor, Admin)
CREATE TABLE IF NOT EXISTS users(
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone_e164 TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('CHILD','SPONSOR','ADMIN')),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING','ACTIVE','SUSPENDED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel whatsapp_otps: kode OTP untuk login WhatsApp
CREATE TABLE IF NOT EXISTS whatsapp_otps(
    id BIGSERIAL PRIMARY KEY,
    phone_e164 TEXT NOT NULL,
    otp_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts INT NOT NULL DEFAULT 0,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_wa_otps ON whatsapp_otps(phone_e164,created_at DESC);

-- Tabel children: data anak asuh yang dikelola admin
CREATE TABLE IF NOT EXISTS children(
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    jenjang TEXT NOT NULL CHECK(jenjang IN ('SD','SMP','SMA','PT')),
    poin INT NOT NULL DEFAULT 0,
    sponsors_count INT NOT NULL DEFAULT 0,
    prestasi TEXT DEFAULT '',
    catatan TEXT DEFAULT '',
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING','ACTIVE','SUSPENDED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_children_status ON children(status);
