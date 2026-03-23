<?php
session_start();
if (!isset($_SESSION['login']) || $_SESSION['tipo'] != 'formador') {
    header("Location: ../index.php");
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Portal do Formador</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="login-box">
    <h2>Portal do Formador</h2>

    <p><strong>Bem-vindo, <?php echo $_SESSION['login']; ?></strong></p>

    <ul style="list-style:none; padding:0;">
        <li style="margin-bottom:10px;">
            <a href="atribuir_notas.php">Avaliar Estágio</a>
        </li>
    </ul>

    <a href="../logout.php">Logout</a>
</div>

</body>
</html>