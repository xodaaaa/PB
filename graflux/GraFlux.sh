#!/bin/bash

# Crear volúmenes para InfluxDB y Grafana
echo "Creando volúmenes de Docker..."
docker volume create influxdb_data
docker volume create grafana_data
echo "Volúmenes creados con éxito."

# Solicitar al usuario ingresar las credenciales
echo "Por favor, introduce las credenciales para el archivo .env"

read -p "Usuario de InfluxDB (default: admin): " influx_user
influx_user=${influx_user:-admin}

read -sp "Contraseña de InfluxDB: " influx_password
echo

read -p "Usuario de Grafana (default: admin): " grafana_user
grafana_user=${grafana_user:-admin}

read -sp "Contraseña de Grafana: " grafana_password
echo

# Crear el archivo .env con los valores proporcionados
echo "Creando archivo .env..."
cat <<EOF > .env
INFLUXDB_ADMIN_USER=$influx_user
INFLUXDB_ADMIN_PASSWORD=$influx_password
GF_SECURITY_ADMIN_USER=$grafana_user
GF_SECURITY_ADMIN_PASSWORD=$grafana_password
EOF

echo "Archivo .env creado con éxito."

# Ejecutar docker-compose
echo "Levantando los servicios con docker-compose..."
docker compose up -d

if [ $? -eq 0 ]; then
  echo "Servicios levantados correctamente."
else
  echo "Ocurrió un error al levantar los servicios."
fi
