<?php
$mysqli = new mysqli("localhost", "webuser", "password123", "mysite");
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}
?>
