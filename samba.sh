#!/bin/bash

# Actualizar los repositorios
apt update

# Instalar Samba y wsdd
apt install -y samba wsdd

# Crear los directorios necesarios
mkdir -p /media/Datos
mkdir -p /media/Descargas

# Configurar permisos
chmod 0777 /media/Descargas
chmod 0777 /media/Datos

# Hacer una copia de seguridad del archivo de configuración de Samba
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Pedir al usuario que elija un nombre de usuario
echo "Introduce el nombre de usuario que deseas crear:"
read username

# Crear un nuevo archivo de configuración de Samba
cat <<EOL > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 50
   dns proxy = no
   follow symlinks = yes
   wide links = yes
   force user = $username

[Descargas]
   browseable = yes
   writeable = yes
   path = /media/Descargas

[Datos]
   browseable = yes
   writeable = yes
   path = /media/Datos
EOL

# Crear un nuevo usuario
adduser --disabled-password --gecos "" $username

# Pedir al usuario la contraseña para Samba
echo "Introduce la contraseña para el usuario de Samba '$username':"
read -s samba_password
echo "Introduce la contraseña nuevamente para confirmar:"
read -s samba_password_confirm

# Verificar que las contraseñas coinciden
if [ "$samba_password" != "$samba_password_confirm" ]; then
    echo "Las contraseñas no coinciden. Inténtalo de nuevo."
    exit 1
fi

# Configurar la contraseña del usuario de sistema
echo "$username:$samba_password" | chpasswd

# Configurar la contraseña de Samba para el usuario
(echo "$samba_password"; echo "$samba_password") | smbpasswd -s -a $username

# Reiniciar los servicios de Samba y wsdd
systemctl restart smbd
systemctl restart nmbd
systemctl restart wsdd

# Habilitar los servicios para que se inicien automáticamente
systemctl enable smbd
systemctl enable nmbd
systemctl enable wsdd

echo "Configuración completada con éxito."
