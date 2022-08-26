#!/bin/bash
# Author: M Ali <onesender.id@gmail.com>

# wajib root
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run this script with root access"
    echo " sudo bash install-en.sh"
    exit
fi


echo "OneSender Installer"
echo "(Install script v-3)"
echo ""
echo ""
read -p "Press y to continue: " lanjut

if [[ $lanjut != "y" ]]; then
  exit
fi

MODE_INSTALL=3

echo "Please fill in the following data:"
echo ""
echo "=============================== "
echo "1. DATABASE SETTING"
read -p "   MySQL Database : " MYSQL_DATABASE
read -p "   MySQL User     : " MYSQL_USER
read -p "   MySQL Password : " MYSQL_PASSWORD

while ! mysql -u$MYSQL_USER -p$MYSQL_PASSWORD  -e ";" ; do
  echo "Incorrect MySQL user or password"
  echo ""
  read -p "   MySQL Database : " MYSQL_DATABASE
  read -p "   MySQL User     : " MYSQL_USER
  read -p "   MySQL Password : " MYSQL_PASSWORD
done

CEK_DB=`mysqlshow --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}| grep -v Wildcard | grep -o ${MYSQL_DATABASE}`
if [ "$CEK_DB" == "${MYSQL_DATABASE}" ]; then
  echo ""
  echo "   DATABASE EXISTS."
  echo "   Do you want to delete the database ${MYSQL_DATABASE}? default no"
  read -p "   (y) Yes (n) no : " MYSQL_CONFIRM_DELETE
  if [ "$MYSQL_CONFIRM_DELETE" == "y" ]; then
    echo ""
    echo "   - Delete table ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE ${MYSQL_DATABASE};"
    echo "   - Create tables ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo ""
  fi
else
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo ""
  echo "   - Database ${MYSQL_DATABASE} created"
  echo ""
fi

NOMOR=1
echo ""
echo "=============================== "
echo "2. ONESENDER SETTING"
echo "   How many instances do you want to install?"
read -p "   Example: (5)   : " SNOMOR

if ! [[ "$SNOMOR" =~ ^[0-9]+$ ]] ; 
 then exec >&2; echo "error: Not a number"; exit 1
fi
NOMOR=$(($SNOMOR))

PORT=3001
echo "   Start from port?"
read -p "   Example  (3001)   : " SPORT

if ! [[ "$SPORT" =~ ^[0-9]+$ ]] ; 
 then exec >&2; echo "error: Not a number"; exit 1
fi
PORT=$(($SPORT))


echo ""
echo "Review Setting "
echo "=============================== "
echo "Mysql User          : $MYSQL_USER"
echo "Mysql Pass          : $MYSQL_PASSWORD"
echo "Mysql Database      : $MYSQL_DATABASE"
echo "Number of instances : $NOMOR"
echo "Start from port     : $PORT"
echo ""
read -p "Press y to continue: " lanjut2

if [[ $lanjut2 != "y" ]]; then
  exit
fi

FUNC_INSTALL_APLIKASI () {
  OLD_ONESENDER_DIR="/opt/onesender_$(date +%H-%M)"
  ONESENDER_DIR="/opt/onesender"
  ONESENDER_RESOURCE_DIR="/opt/onesender/resources"
  ONESENDER_APP="/opt/onesender/onesender-x86_64"
  ONESENDER_BINARY="onesender-x86_64"


  ONESENDER_CONFIG="/opt/onesender/config_${NOMOR}.yaml"

  INIT_SERVER="/etc/systemd/system/onesender@.service"

  #if [ -d "$ONESENDER_DIR" ]; then
  #  mv $ONESENDER_DIR $OLD_ONESENDER_DIR
  #fi

  echo "- Buat file /opt/onesender"
  mkdir $ONESENDER_DIR
  cp -r ./resources $ONESENDER_RESOURCE_DIR
  cp "./${ONESENDER_BINARY}" $ONESENDER_APP
  cp ./install.sh /opt/onesender/install.sh
  cp ./install-many.sh /opt/onesender/install-many.sh
  chmod +x $ONESENDER_APP

}

FUNC_INSTALL_SYSTEMD() {

echo "[Unit]
Description=onesender Multi device Service

[Service]
Type=simple
ExecStart=/opt/onesender/$ONESENDER_BINARY --config=/opt/onesender/config_%i.yaml
Wants=network.target
After=syslog.target network-online.target
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
" > $INIT_SERVER

}

# FUNC_INSTALL_CONFIG prefix port 
# FUNC_INSTALL_CONFIG 1 3001 
FUNC_INSTALL_CONFIG() {

echo "app:
  sync_contacts: true
  wamd_session_path: /opt/onesender/whatsapp_${1}.session
database:
  connection: mysql
  host: 127.0.0.1
  name: $MYSQL_DATABASE
  password: $MYSQL_PASSWORD
  port: 3306
  user: $MYSQL_USER
  prefix: os${1}_
server:
  port: ${2}
" > "/opt/onesender/config_${1}.yaml"

}


# FUNC_FINISHING_INSTALL 1 
FUNC_FINISHING_INSTALL() {

$ONESENDER_APP --config=/opt/onesender/config_${1}.yaml --install

echo ""
echo "- Install init script"
systemctl daemon-reload
systemctl enable "onesender@${1}"
sleep 3
echo ""
echo "- Start server"
systemctl start "onesender@${1}"
sleep 3

}


## Jalankan install
FUNC_INSTALL_APLIKASI
FUNC_INSTALL_SYSTEMD

for (( i=1; i<=$NOMOR; i++ ))
do
  echo "Install instance #$i"
  FUNC_INSTALL_CONFIG $i $PORT
  FUNC_FINISHING_INSTALL $i
  $PORT++
done

