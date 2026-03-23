<?php
session_start();
if (!isset($_SESSION['login']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: ../index.php");
    exit;
}

require_once "../includes/db.php";


$turmas = $pdo->query("
    SELECT turma_id, sigla, ano 
    FROM turma 
    ORDER BY ano DESC, sigla
")->fetchAll();

$mensagem = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $nome = trim($_POST["nome"]);
    $login = trim($_POST["login"]);
    $password = $_POST["password"];
    $confirmar = $_POST["confirmar"];
    $numero = $_POST["numero"];
    $turma_id = $_POST["turma_id"];

    if ($password !== $confirmar) {
        $mensagem = "<p style='color:red;'>Passwords não coincidem.</p>";
    } else {
        try {
            $pdo->beginTransaction();

           
            $stmt = $pdo->prepare("
                INSERT INTO utilizador (login, password, nome, tipo)
                VALUES (:login, :password, :nome, 'aluno')
            ");
            $stmt->execute([
                ":login" => $login,
                ":password" => $password,
                ":nome" => $nome
            ]);

            $utilizador_id = $pdo->lastInsertId();

          
            $stmt = $pdo->prepare("
                INSERT INTO aluno (turma_id, utilizador_id, numero)
                VALUES (:turma, :utilizador, :numero)
            ");
            $stmt->execute([
                ":turma" => $turma_id,
                ":utilizador" => $utilizador_id,
                ":numero" => $numero
            ]);

            $pdo->commit();
            $mensagem = "<p style='color:green;'>Aluno criado com sucesso.</p>";

        } catch (PDOException $e) {
            $pdo->rollBack();
            $mensagem = "<p style='color:red;'>Erro: login já existente ou dados inválidos.</p>";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Adicionar Aluno</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="login-box">
    <h2>Adicionar Novo Aluno</h2>

    <?= $mensagem ?>

    <form method="post">

        <label>Nome completo</label>
        <input type="text" name="nome" required>

        <label>Login (username)</label>
        <input type="text" name="login" required>

        <label>Password</label>
        <input type="password" name="password" required>

        <label>Confirmar password</label>
        <input type="password" name="confirmar" required>

        <label>Número do aluno</label>
        <input type="number" name="numero" required>

        <label>Turma</label>
        <select name="turma_id" required>
            <option value="">— selecionar —</option>
            <?php foreach ($turmas as $t): ?>
                <option value="<?= $t['turma_id'] ?>">
                    <?= htmlspecialchars($t['sigla']) ?> (<?= $t['ano'] ?>)
                </option>
            <?php endforeach; ?>
        </select>

        <br><br>
        <button type="submit">Criar Aluno</button>
    </form>

    <br>
    <a href="index.php">Voltar ao menu</a>
</div>

</body>
</html>