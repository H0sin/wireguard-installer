#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
echo -e "${GREEN}🚀 نصب خودکار پنل وایرگارد در حال اجرا است...${NC}\n"

# بررسی دسترسی روت
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}⛔ لطفاً اسکریپت را با دسترسی روت اجرا کنید!${NC}\n"
  exit 1
fi

# دریافت آی‌پی سرور
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}🌍 آی‌پی سرور: $SERVER_IP${NC}\n"

# بررسی نصب بودن داکر
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🛠 داکر نصب نیست. در حال نصب داکر...${NC}\n"
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# بررسی نصب بودن Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}🛠 در حال نصب Docker Compose...${NC}\n"
    sudo apt-get install -y docker-compose
fi

# مسیر نصب پروژه
INSTALL_DIR="/root/Wireguard"

# دریافت اطلاعات گیت‌هاب
read -p "📝 لطفاً یوزرنیم گیت‌هاب خود را وارد کنید: " GITHUB_USER
read -s -p "🔑 لطفاً توکن خصوصی گیت‌هاب را وارد کنید: " GITHUB_TOKEN
echo -e "\n"

# بررسی و حذف نسخه قبلی
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️ نسخه قبلی پروژه یافت شد. حذف و نصب مجدد انجام می‌شود...${NC}\n"
    rm -rf $INSTALL_DIR
fi

# کلون کردن پروژه پرایوت از گیت‌هاب
echo -e "${GREEN}📥 دانلود پروژه از گیت‌هاب...${NC}\n"
git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/Wireguard.git /root

# بررسی موفقیت کلون شدن
if [[ $? -ne 0 ]]; then
    echo -e "${RED}⛔ خطا در کلون کردن پروژه! لطفاً توکن و یوزرنیم را بررسی کنید.${NC}\n"
    exit 1
fi

# تغییر آی‌پی در فایل‌های تنظیمات
echo -e "${YELLOW}🔄 جایگزینی آی‌پی سرور در تنظیمات...${NC}\n"
cd $INSTALL_DIR
sed -i "s/REPLACE_WITH_SERVER_IP/$SERVER_IP/g" $INSTALL_DIR/docker-compose.override.yml
sed -i "s/REPLACE_WITH_SERVER_IP/$SERVER_IP/g" $INSTALL_DIR/Src/Services/Api/Wireguard.Api/appsettings.Development.json
sed -i "s/REPLACE_WITH_SERVER_IP/$SERVER_IP/g" $INSTALL_DIR/Src/Services/Api/Wireguard.Api/appsettings.Development.json
# اجرای داکر کامپوز
echo -e "${GREEN}🚀 راه‌اندازی سرویس...${NC}\n"
cd $INSTALL_DIR
docker compose up -d

echo -e "${GREEN}✅ نصب و راه‌اندازی کامل شد!${NC}\n"
echo -e "🌍 برای دسترسی به پنل، به آدرس زیر بروید: http://$SERVER_IP"
