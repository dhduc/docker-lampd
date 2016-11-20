<?php
$dsn = 'mysql:dbname=db_magento;host=mysql;port=3306';
$username = 'magento';
$password = 'password';
try {
    $db = new PDO($dsn, $username, $password); // also allows an extra parameter of configuration
} catch(PDOException $e) {
    die('Could not connect to the database:<br/>' . $e);
}
$db = null;
echo 'working';