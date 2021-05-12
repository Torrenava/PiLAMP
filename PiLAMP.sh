#!/bin/bash

# Author: Torrenava

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${yellowColour}[*]${endColour}${grayColour}Proceso cancelado. Saliendo${endColour}"
	exit 0
  tput cnorm;
}

function helpPanel(){
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: ./PiLAMP.sh${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
	exit 0
}

function error() {
  echo -e "\n${redColour}[!]${endColour}${redColour} Ha ocurrido un eror.${endColour}"
  sleep 2; exit 1; tput cnorm
}

function updateRaspian(){
	clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Actualizando${endColour}${purpleColour} RasperryPi${endColour}${grayColour}.${endColour}"
  sleep 2
  apt update > /dev/null 2>/dev/null
  apt upgrade -y > /dev/null 2>/dev/null
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Actualización Correcta.${endColour}"
  sleep 2
	tput cnorm

}

function installApache() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Instalando Apache.${endColour}"
  sleep 2
  apt install -y apache2 > /dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
   echo -e "\n${yellowColour}[*]${endColour}${grayColour} Apache instalado correctamente.${endColour}"
   sleep 2
   apachePostInstall
  else
   echo -e "\n${redColour}[!]${endColour}${redColour} Error en la instalación de Apache.${endColour}"
   sleep 2
	 tput cnorm
   error
  fi
}

function apachePostInstall() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Ajustando Permisos.${endColour}"
  sleep 2
  cd /var/www/
  mkdir /var/www/html > /dev/null 2>/dev/null
  chown www-data:www-data /var/www/html > /dev/null 2>/dev/null
  find /var/www/html -type d -print -exec chmod 775 {} \ > /dev/null 2>/dev/null
  find /var/www/html -type f -print -exec chmod 664 {} \ > /dev/null 2>/dev/null
  usermod -aG www-data pi > /dev/null 2>/dev/null
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Proceso Correcto.${endColour}"
  sleep 2
	tput cnorm
	installPHP

}

function installPHP() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Instalando PHP.${endColour}"
  sleep 2
  apt install -y php libapache2-mod-php php-mysql > /dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
   echo -e "\n${yellowColour}[*]${endColour}${grayColour} PHP Instalado correctamente.${endColour}"
   sleep 2
	 tput cnorm
   installMariaDB
  else
   echo -e "\n${redColour}[!]${endColour}${redColour} Error en la instalación de PHP.${endColour}"
   sleep 2
   error
  fi

}
function installMariaDB() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Instalando MariaDB.${endColour}"
  sleep 2
  apt install -y mariadb-server > /dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
   echo -e "\n${yellowColour}[*]${endColour}${grayColour} MariaDB Instalado correctamente.${endColour}"
   sleep 2
	 tput cnorm
   configMariaDB
  else
   echo -e "\n${redColour}[!]${endColour}${redColour} Error en la instalación de MariaDB.${endColour}"
   sleep 2
   error
  fi
}

function configMariaDB() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Empezando con la configuración de MariaDB.${endColour}"
  sleep 1
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Sigue los pasos mostrados a continuación y configura una contraseña de Root.${endColour}"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Recuerda esa contraseña, pues va a ser solicitada más tarde.${endColour}"
	sleep 4
	sudo mysql_secure_installation
  echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} A continuación se van a configurar los permisos para un usuario que vamos a crear en MariaDB.${endColour}"
  sleep 1
	tput cnorm
  echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce el ${purpleColour}nombre de Usuario${endColour}${grayColour}.${endColour}"
  read userName
  echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce la${purpleColour} contraseña${endColour}${grayColour} del usuario${endColour}${purpleColour} $userName${endColour}${grayColour}.${endColour}"
  read userPass

	tput civis

	newUser=$userName
	newDbPassword=$userPass
	newDb='PiDB'
	host=localhost
	#host='%'

	commands="CREATE USER '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';GRANT USAGE ON *.* TO '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';GRANT ALL PRIVILEGES ON *.* TO '${newUser}'@'localhost' IDENTIFIED BY '${newDbPassword}';FLUSH PRIVILEGES;"

	echo "${commands}" | /usr/bin/mysql -u root -p > /dev/null 2>dev/null


  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configuración de MariDB terminada.${endColour}"
  sleep 2
	tput cnorm
  installPHPMyAdmin
}

function installPHPMyAdmin() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Instalando PHPMyAdmin.${endColour}"
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Complete la información cuando se le solicite.${endColour}\n\n"
  sleep 4
  clear
  apt install -y phpmyadmin php-mbstring php-gettext 2>/dev/null
	tput cnorm
  if [ $? -eq 0 ]; then
   echo -e "\n${yellowColour}[*]${endColour}${grayColour} PHPMyAdmin Instalado correctamente.${endColour}"
   sleep 1
   end
  else
   echo -e "\n${redColour}[!]${endColour}${redColour} Error en la instalación de PHPMyAdmin.${endColour}"
   sleep 2
   error
  fi
}
function end() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} La instalación ha terminado.${endColour}"
	sleep 5
	tput cnorm
}

# Main function
updateRaspian
installApache

