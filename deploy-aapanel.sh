#!/bin/bash
# =============================================================
# AnakAsuh - Deployment Script untuk aaPanel
# Jalankan di server aaPanel: bash deploy-aapanel.sh
# =============================================================

set -e

echo "========================================"
echo "  AnakAsuh - Deploy ke aaPanel"
echo "========================================"

# Konfigurasi
APP_NAME="anakasuh"
APP_DIR="/www/wwwroot/anakasuh"
NODE_VERSION="22"

# 1. Cek Node.js
echo ""
echo "[1/6] Cek Node.js..."
if command -v node &> /dev/null; then
    NODE_VER=$(node -v | sed 's/v//')
    echo "  Node.js terdeteksi: v$NODE_VER"
else
    echo "  Node.js belum terinstall!"
    echo "  Install via aaPanel: App Store > Node.js Version Manager"
    echo "  Atau jalankan: nvm install $NODE_VERSION"
    exit 1
fi

# 2. Cek PM2
echo ""
echo "[2/6] Cek PM2..."
if ! command -v pm2 &> /dev/null; then
    echo "  PM2 belum terinstall, menginstall..."
    npm install -g pm2
else
    echo "  PM2 sudah terinstall: $(pm2 --version)"
fi

# 3. Cek PostgreSQL
echo ""
echo "[3/6] Cek PostgreSQL..."
if command -v psql &> /dev/null; then
    echo "  PostgreSQL terdeteksi"
else
    echo "  PostgreSQL belum terinstall!"
    echo "  Install via aaPanel: App Store > PostgreSQL Manager"
    exit 1
fi

# 4. Setup direktori aplikasi
echo ""
echo "[4/6] Setup direktori aplikasi..."
echo "  Jika Anda menjalankan script ini dari dalam folder project,"
echo "  pastikan file project sudah berada di: $APP_DIR"
echo ""
echo "  Jika belum, jalankan:"
echo "    mkdir -p $APP_DIR"
echo "    cp -r ./* $APP_DIR/"
echo "    cd $APP_DIR"

# 5. Install dependencies
echo ""
echo "[5/6] Install dependencies..."
if [ -f "package.json" ]; then
    npm install --production
    echo "  Dependencies terinstall"
else
    echo "  ERROR: package.json tidak ditemukan!"
    echo "  Pastikan Anda berada di direktori project: $APP_DIR"
    exit 1
fi

# 6. Setup .env
echo ""
echo "[6/6] Setup environment..."
if [ ! -f ".env" ]; then
    echo "  File .env belum ada!"
    echo "  Salin dari template:"
    echo "    cp .env.production .env"
    echo "  Lalu edit isi .env dengan kredensial yang benar:"
    echo "    nano .env"
    echo ""
    echo "  Setelah itu, jalankan database migration:"
    echo "    psql \$DATABASE_URL -f schema.sql"
    echo ""
    echo "  Lalu start aplikasi dengan PM2:"
    echo "    pm2 start ecosystem.config.cjs"
    echo "    pm2 save"
    echo "    pm2 startup"
    echo ""
    echo "  Setup Nginx reverse proxy:"
    echo "    Copy nginx-anakasuh.conf ke config Nginx aaPanel"
    echo ""
    echo "========================================"
    echo "  SETUP BELUM SELESAI - lanjutkan langkah di atas"
    echo "========================================"
    exit 0
else
    echo "  File .env sudah ada"
fi

# Jalankan database migration
echo ""
echo "Menjalankan database migration..."
DB_URL=$(grep DATABASE_URL .env | cut -d= -f2-)
if [ -n "$DB_URL" ]; then
    psql "$DB_URL" -f schema.sql
    echo "  Database migration selesai"
else
    echo "  DATABASE_URL tidak ditemukan di .env, skip migration"
fi

# Start aplikasi dengan PM2
echo ""
echo "Start aplikasi dengan PM2..."
pm2 delete anakasuh 2>/dev/null || true
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup 2>/dev/null || true

echo ""
echo "========================================"
echo "  DEPLOY BERHASIL!"
echo "========================================"
echo ""
echo "Aplikasi berjalan di port 3000"
echo "Cek status: pm2 status"
echo "Cek log: pm2 logs anakasuh"
echo ""
echo "LANGKAH SELANJUTNYA:"
echo "  1. Setup Nginx reverse proxy (copy nginx-anakasuh.conf)"
echo "  2. Buka port 80 di firewall aaPanel"
echo "  3. Akses via: http://IP-SERVER-ANDA/"
echo "  4. Test health: http://IP-SERVER-ANDA/api/health"
echo ""
