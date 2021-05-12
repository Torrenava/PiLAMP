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
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: sudo bash PiLAMP.sh${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
	exit 0
}

function error() {
  echo -e "\n${redColour}[!]${endColour}${redColour} Ha ocurrido un eror.${endColour}"
  sleep 2; exit 1; tput cnorm
}

function dependencies1(){
	tput civis
	clear; dependencies=(apache2 php libapache2-mod-php php-mysql mariadb-server phpmyadmin php-mbstring php-gettext)
	echo -e "${yellowColour}[*]${endColour}${grayColour} Se van a instalar los programas de configuración automática.${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}\n"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando e Instalando herramienta ${endColour}${blueColour}$program${endColour}${yellowColour}...${endColour}"
		apt install $program -y > /dev/null 2>&1
		sleep 1
	done
}

function dependencies2(){
	tput civis
	clear; dependencies=(mariadb-server phpmyadmin)
	echo -e "${yellowColour}[*]${endColour}${grayColour} Se van a instalar los programas de configuración manual.${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}\n"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando e Instalando herramienta ${endColour}${blueColour}$program${endColour}${yellowColour}...${endColour}"
		apt install $program -y 2>&1
		sleep 1
	done
}

function configApache(){
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Ajustando Permisos.${endColour}"
  sleep 2
	mkdir /var/www/html/
	chown www-data:www-data /var/www/
	chmod -R 775 /var/www/
	usermod -aG www-data pi > /dev/null 2>/dev/null
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Proceso Correcto.${endColour}"
	sleep 5
	tput cnorm
}

function configMariaDB() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Empezando con la configuración de MariaDB.${endColour}"
  sleep 1
  echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} A continuación se van a configurar los permisos para un usuario que vamos a crear en MariaDB.${endColour}"
  sleep 1
	tput cnorm

	# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce el nombre de la${endColour}${purpleColour} base de datos${endColour}${grayColour}.${endColour}${blueColour} (ejemplo: database1)${endColour}${grayColour}.${endColour}"
	read dbname
	echo -e "${yellowColour}[*]${endColour}${grayColour} Elige el${endColour}${purpleColour} tipo de caracteres${endColour}${grayColour} de la base de datos.${endColour}${blueColour} (ejemplo: latin1, utf8, ...)${endColour}${grayColour}.${endColour}"
  echo -e "${turquoiseColour}[?]${endColour}${grayColour} Elige${endColour}${purpleColour} utf8${endColour}${grayColour} si no sabes cual elegir.${endColour}"
	read charset
	echo -e "${yellowColour}[*]${endColour}${grayColour} Creando la${endColour}${purpleColour} base de datos${endColour}${grayColour}.${endColour}"
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo -e "${yellowColour}[*]${endColour}${purpleColour} Base de datos${endColour}${grayColour}creada correctamente.${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Mostrando las${endColour}${purpleColour} base de datos.${endColour}"
	mysql -e "show databases;"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Introduce el ${endColour}${purpleColour}usuario${endColour}${grayColour} a crear.${endColour}${blueColour} (ejemplo: user1)${endColour}${grayColour}.${endColour}"
	read username
	echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce la${endColour}${purpleColour} contraseña${endColour}${grayColour} del usuario.${endColour}"
  echo -e "${yellowColour}[*]${endColour}${grayColour} La contraseña será ocultada mientras la escribas.${endColour}"
	read -s userpass
  echo -e "${yellowColour}[*]${endColour}${grayColour} Creando el${endColour}${purpleColour} nuevo usuario${endColour}${grayColour}.${endColour}"
	mysql -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Usuario creado${endColour}${purpleColour} correctamente${endColour}${grayColour}.${endColour}"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Dando todos los privilegios a ${endColour}${purpleColour} ${username}${endColour}${grayColour}.${endColour}"
	mysql -e "GRANT USAGE ON *.* TO '${username}'@'%' IDENTIFIED BY '${userpass}';"
	mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${username}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo -e "\n${greenColour}[*]${endColour}${grayColour} Proceso terminado.${endColour}"

# If /root/.my.cnf doesn't exist then it'll ask for root password
else
	echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce la${endColour}${purpleColour} contraseña${endColour}${grayColour} de${endColour}${blueColour} root${endColour}${grayColour} de${endColour}${blueColour} MariaDB${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} La contraseña será ocultada mientras la escribas.${endColour}"
	read -s rootpasswd
	echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce el nombre de la${endColour}${purpleColour} base de datos${endColour}${grayColour}.${endColour}${blueColour} (ejemplo: database1)${endColour}${grayColour}.${endColour}"
	read dbname
	echo -e "${yellowColour}[*]${endColour}${grayColour} Elige el${endColour}${purpleColour} tipo de caracteres${endColour}${grayColour} de la base de datos.${endColour}${blueColour} (ejemplo: latin1, utf8, ...)${endColour}${grayColour}.${endColour}"
  echo -e "${turquoiseColour}[?]${endColour}${grayColour} Elige${endColour}${purpleColour} utf8${endColour}${grayColour} si no sabes cual elegir.${endColour}"
	read charset
	echo -e "${yellowColour}[*]${endColour}${grayColour} Creando la${endColour}${purpleColour} base de datos${endColour}${grayColour}.${endColour}"
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo -e "${yellowColour}[*]${endColour}${purpleColour} Base de datos${endColour}${grayColour}creada correctamente.${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Mostrando las${endColour}${purpleColour} base de datos.${endColour}"
	mysql -uroot -p${rootpasswd} -e "show databases;"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Introduce el ${endColour}${purpleColour}usuario${endColour}${grayColour} a crear.${endColour}${blueColour} (ejemplo: user1)${endColour}${grayColour}.${endColour}"
	read username
	echo -e "${yellowColour}[*]${endColour}${grayColour} Introduce la${endColour}${purpleColour} contraseña${endColour}${grayColour} del usuario.${endColour}"
  echo -e "${yellowColour}[*]${endColour}${grayColour} La contraseña será ocultada mientras la escribas.${endColour}"
	read -s userpass
  echo -e "${yellowColour}[*]${endColour}${grayColour} Creando el${endColour}${purpleColour} nuevo usuario${endColour}${grayColour}.${endColour}"
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Usuario creado${endColour}${purpleColour} correctamente${endColour}${grayColour}.${endColour}"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Dando todos los privilegios a ${endColour}${purpleColour} ${username}${endColour}${grayColour}.${endColour}"
	mysql -uroot -p${rootpasswd} -e "GRANT USAGE ON *.* TO '${username}'@'%' IDENTIFIED BY '${userpass}';"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON *.* TO '${username}'@'localhost';"
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
	echo -e "\n${greenColour}[*]${endColour}${grayColour} Proceso terminado.${endColour}"
fi
  sleep 4
	tput cnorm
}

function end() {
  clear
	tput civis
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} La instalación ha terminado.${endColour}"
	sleep 10
	tput cnorm
}

# Main Function
dependencies1
dependencies2
configApache
configMariaDB
end
