#!/bin/bash
yum update -y
yum install -y python3 python3-pip
pip3 install flask flask-cors mysql-connector-python
yum install -y mysql

sleep 60

export DB_HOST="${database_address}"
export DB_USER="root"
export DB_PASSWORD="root123456789"
export DB_NAME="mydb"

until mysql -h $DB_HOST -u$DB_USER -p$DB_PASSWORD -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for MySQL to be ready..."
  sleep 5
done

mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "
CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100)
);
INSERT INTO users (name) VALUES ('Kamal Sabry'), ('Ahmed Ali'), ('Sara Mostafa');
"

mkdir -p /app
cat <<'APP' > /app/app.py
${app_file}
APP

nohup python3 /app/app.py > /app/flask.log 2>&1 &