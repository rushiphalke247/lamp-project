<?php
include 'db.php';

$result = $mysqli->query("SELECT * FROM posts");

echo "<h2>Posts:</h2>";
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "<h3>{$row['title']}</h3><p>{$row['content']}</p><hr>";
    }
} else {
    echo "No posts found.";
}
?>
