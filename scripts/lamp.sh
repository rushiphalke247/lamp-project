#!/bin/bash

# === CONFIGURATION ===
PROJECT_DIR="/var/www/html/lamp-demo"
DB_NAME="mysite"
DB_USER="webuser"
DB_PASS="password123"

# === STEP 1: Update system ===
echo "[*] Updating system..."
sudo apt update -y

# === STEP 2: Install LAMP stack ===
echo "[*] Installing Apache, MySQL, PHP..."
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y

# === STEP 3: Create MySQL database and user ===
echo "[*] Configuring MySQL..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# === STEP 4: Setup project directory ===
echo "[*] Creating project at $PROJECT_DIR..."
sudo mkdir -p "$PROJECT_DIR"
sudo rm -rf "$PROJECT_DIR"/*
sudo chown -R $USER:$USER "$PROJECT_DIR"

# === STEP 5: Create index.php ===
cat <<EOF > "$PROJECT_DIR/index.php"
<?php
include 'db.php';

\$result = \$mysqli->query("SELECT * FROM posts");

echo "<h2>Posts:</h2>";
if (\$result && \$result->num_rows > 0) {
    while (\$row = \$result->fetch_assoc()) {
        echo "<h3>{\$row['title']}</h3><p>{\$row['content']}</p><hr>";
    }
} else {
    echo "No posts found.";
}
?>
EOF

# === STEP 6: Create db.php ===
cat <<EOF > "$PROJECT_DIR/db.php"
<?php
\$mysqli = new mysqli("localhost", "$DB_USER", "$DB_PASS", "$DB_NAME");
if (\$mysqli->connect_error) {
    die("Connection failed: " . \$mysqli->connect_error);
}
?>
EOF

# === STEP 7: Create MySQL table and sample data ===
echo "[*] Creating sample table and data..."
sudo mysql -u root -e "
USE $DB_NAME;
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    content TEXT
);
INSERT INTO posts (title, content) VALUES
('Welcome to LAMP', 'This is your first post on a LAMP-powered website.');
"

# === STEP 8: Restart Apache ===
echo "[*] Restarting Apache..."
sudo sed -i 's/index.html/index.php/g' /etc/apache2/apache2.conf
sudo systemctl restart apache2

# === DONE ===
echo "[✔] LAMP project setup complete!"
echo "Visit: http://$(hostname -I | awk '{print $1}')/lamp-demo"
