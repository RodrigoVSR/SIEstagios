<?php
session_start();
if (!isset($_SESSION['login']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: ../index.php");
    exit;
}

require_once "../includes/db.php";

/* Estabelecimentos */
$estabelecimentos = $pdo->query("
    SELECT 
        est.estabelecimento_id,
        est.empresa_id,
        est.nome_comercial,
        emp.firma
    FROM estabelecimento est
    JOIN empresa emp ON emp.empresa_id = est.empresa_id
    ORDER BY emp.firma, est.nome_comercial
")->fetchAll();

/* Alunos */
$alunos = $pdo->query("
    SELECT 
        a.utilizador_id,
        u.nome,
        a.numero
    FROM aluno a
    JOIN utilizador u ON u.utilizador_id = a.utilizador_id
    ORDER BY u.nome
")->fetchAll();

/* Formadores */
$formadores = $pdo->query("
    SELECT utilizador_id, nome
    FROM utilizador
    WHERE tipo = 'formador'
    ORDER BY nome
")->fetchAll();

$mensagem = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    [
        $empresa_id,
        $estabelecimento_id
    ] = explode("|", $_POST["estabelecimento"]);

    $aluno_id = $_POST["aluno_id"];
    $formador_id = $_POST["formador_id"];
    $data_inicio = $_POST["data_inicio"];
    $data_fim = $_POST["data_fim"] ?: null;

    try {
        $stmt = $pdo->prepare("
            INSERT INTO estagio (
                estabelecimento_empresa_id,
                estabelecimento_id,
                aluno_id,
                formador_id,
                data_inicio,
                data_fim
            )
            VALUES (
                :empresa,
                :estabelecimento,
                :aluno,
                :formador,
                :inicio,
                :fim
            )
        ");

        $stmt->execute([
            ":empresa" => $empresa_id,
            ":estabelecimento" => $estabelecimento_id,
            ":aluno" => $aluno_id,
            ":formador" => $formador_id,
            ":inicio" => $data_inicio,
            ":fim" => $data_fim
        ]);

        $mensagem = "<p style='color:green;'>Estágio registado com sucesso.</p>";

    } catch (PDOException $e) {
        $mensagem = "<p style='color:red;'>Erro ao registar estágio.</p>";
    }
}
?>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Registar Estágio</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="login-box" style="width:500px">
    <h2>Novo Estágio</h2>

    <?= $mensagem ?>

   <form method="post">

    <div class="form-grid">

        <div>
            <label>Estabelecimento</label>
            <select name="estabelecimento" required>
                <option value="">— selecionar —</option>
                <?php foreach ($estabelecimentos as $e): ?>
                    <option value="<?= $e['empresa_id'] . '|' . $e['estabelecimento_id'] ?>">
                        <?= htmlspecialchars($e['firma']) ?> — <?= htmlspecialchars($e['nome_comercial']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label>Aluno</label>
            <select name="aluno_id" required>
                <option value="">— selecionar —</option>
                <?php foreach ($alunos as $a): ?>
                    <option value="<?= $a['utilizador_id'] ?>">
                        <?= htmlspecialchars($a['nome']) ?> (<?= $a['numero'] ?>)
                    </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label>Formador</label>
            <select name="formador_id" required>
                <option value="">— selecionar —</option>
                <?php foreach ($formadores as $f): ?>
                    <option value="<?= $f['utilizador_id'] ?>">
                        <?= htmlspecialchars($f['nome']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label>Data início</label>
            <input type="date" name="data_inicio" required>
        </div>

        <div class="full">
            <label>Data fim</label>
            <input type="date" name="data_fim">
        </div>

    </div>

    <button type="submit">Registar Estágio</button>

</form>

    <br>
    <a href="index.php">Voltar ao menu</a>
</div>

</body>
</html>