<?php
session_start();
require_once "includes/db.php";

if (!isset($_POST['login'], $_POST['password'])) {
    header("Location: index.php");
    exit;
}

$login = trim($_POST['login']);
$password = trim($_POST['password']);

$sql = "SELECT * FROM utilizador 
        WHERE login = :login AND password = :password";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':login' => $login,
    ':password' => $password
]);

$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {

    $_SESSION['login'] = $user['login'];
    $_SESSION['tipo']  = $user['tipo'];

    if ($user['tipo'] === 'administrativo') {
        header("Location: admin/index.php");
    } elseif ($user['tipo'] === 'aluno') {
        header("Location: aluno/index.php");
    } elseif ($user['tipo'] === 'formador') {
        header("Location: formador/index.php");
    }
    exit;

} else {
    echo "Login inválido<br><a href='index.php'>Voltar</a>";
}