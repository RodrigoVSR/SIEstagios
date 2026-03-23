<?php
session_start();
if (!isset($_SESSION['login']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: ../index.php");
    exit;
}

require_once "../includes/db.php";


if (isset($_GET['apagar'])) {
    [
        $empresa_id,
        $estabelecimento_id,
        $aluno_id,
        $formador_id,
        $data_inicio
    ] = explode("|", $_GET['apagar']);

    $sql = "
        DELETE FROM estagio
        WHERE estabelecimento_empresa_id = :empresa
          AND estabelecimento_id = :estabelecimento
          AND aluno_id = :aluno
          AND formador_id = :formador
          AND data_inicio = :data_inicio
          AND data_fim IS NULL
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ":empresa" => $empresa_id,
        ":estabelecimento" => $estabelecimento_id,
        ":aluno" => $aluno_id,
        ":formador" => $formador_id,
        ":data_inicio" => $data_inicio
    ]);

    header("Location: gerir_estagios.php");
    exit;
}

$sql = "
SELECT
    est.estabelecimento_empresa_id,
    est.estabelecimento_id,
    est.aluno_id,
    est.formador_id,
    est.data_inicio,
    est.data_fim,

    emp.firma AS empresa,
    estb.nome_comercial AS estabelecimento,
    u1.nome AS aluno,
    u2.nome AS formador
FROM estagio est
JOIN empresa emp
    ON emp.empresa_id = est.estabelecimento_empresa_id
JOIN estabelecimento estb
    ON estb.estabelecimento_id = est.estabelecimento_id
JOIN utilizador u1
    ON u1.utilizador_id = est.aluno_id
JOIN utilizador u2
    ON u2.utilizador_id = est.formador_id
ORDER BY est.data_inicio DESC
";

$estagios = $pdo->query($sql)->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerir Estágios</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="login-box" style="width:900px">
    <h2>Gestão de Estágios</h2>

    <table border="1" cellpadding="5" width="100%">
        <tr>
            <th>Empresa</th>
            <th>Estabelecimento</th>
            <th>Aluno</th>
            <th>Formador</th>
            <th>Data Início</th>
            <th>Estado</th>
            <th>Ações</th>
        </tr>

        <?php foreach ($estagios as $e): 
            $key = implode("|", [
                $e['estabelecimento_empresa_id'],
                $e['estabelecimento_id'],
                $e['aluno_id'],
                $e['formador_id'],
                $e['data_inicio']
            ]);
        ?>
        <tr>
            <td><?= htmlspecialchars($e['empresa']) ?></td>
            <td><?= htmlspecialchars($e['estabelecimento']) ?></td>
            <td><?= htmlspecialchars($e['aluno']) ?></td>
            <td><?= htmlspecialchars($e['formador']) ?></td>
            <td><?= htmlspecialchars($e['data_inicio']) ?></td>
            <td>
                <?= $e['data_fim'] ? '<span style="color:red">Terminado</span>' : 'Em curso' ?>
            </td>
            <td>
                <?php if (!$e['data_fim']): ?>
                    <a href="gerir_estagios.php?apagar=<?= urlencode($key) ?>"
                       onclick="return confirm('Apagar este estágio?');">
                        Apagar
                    </a>
                <?php else: ?>
                    —
                <?php endif; ?>
            </td>
        </tr>
        <?php endforeach; ?>
    </table>

    <br>
    <a href="index.php">Voltar ao menu</a>
</div>

</body>
</html>