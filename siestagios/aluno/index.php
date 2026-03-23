<?php
session_start();
if (!isset($_SESSION['login']) || $_SESSION['tipo'] != 'aluno') {
    header("Location: ../index.php");
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Portal do Aluno</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="login-box">
    <h2>Portal do Aluno</h2>

    <p><strong>Bem-vindo, <?php echo $_SESSION['login']; ?></strong></p>

    <ul style="list-style:none; padding:0;">
        <li style="margin-bottom:10px;">
            <a href="empresas.php"> Ver Empresas Disponíveis</a>
        </li>
    </ul>

    <a href="../logout.php">Logout</a>
</div>

</body>
</html>