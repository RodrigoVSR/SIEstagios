<?php
require_once "../includes/db.php";

$anoAtual = (int) date("Y");

$anoDb = $pdo->query("SELECT MAX(ano) FROM disponibilidade")->fetchColumn();

$anoUsado = $anoDb ? (int)$anoDb : $anoAtual;


$zona = $_GET["zona"] ?? "";


$sql = "
SELECT DISTINCT 
    e.empresa_id,
    e.firma,
    e.tipo_organizacao,
    e.localidade,
    e.telefone,
    e.website
FROM empresa e
JOIN disponibilidade d ON d.empresa_id = e.empresa_id
WHERE d.ano = :ano
";

$params = [
    ":ano" => $anoUsado
];

if (!empty($zona)) {
    $sql .= " AND e.localidade LIKE :zona";
    $params[":zona"] = "%" . $zona . "%";
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$empresas = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt">
<head>
     <meta charset="UTF-8">
    <title>Empresas Disponíveis</title>

    <style>
        body {
            background: #f7f3ee; 
        }
    </style>
</head>
<body>

<h1>Portal do Aluno</h1>

<h2>Empresas com disponibilidade para estágio</h2>

<form method="get">
    <label>Localidade:</label>
    <input type="text" name="zona" value="<?= htmlspecialchars($zona) ?>">
    <button type="submit">Filtrar</button>
</form>

<p><em>A mostrar disponibilidades do ano: <?= $anoUsado ?></em></p>

<table border="1" cellpadding="5">
    <tr>
        <th>Empresa</th>
        <th>Tipo</th>
        <th>Localidade</th>
        <th>Telefone</th>
        <th>Website</th>
        <th>Ver Estágios</th>
    </tr>

<?php if (count($empresas) === 0): ?>
    <tr>
        <td colspan="6">Não existem empresas com disponibilidade.</td>
    </tr>
<?php endif; ?>

<?php foreach ($empresas as $e): ?>
    <tr>
        <td><?= htmlspecialchars($e["firma"]) ?></td>
        <td><?= htmlspecialchars($e["tipo_organizacao"]) ?></td>
        <td><?= htmlspecialchars($e["localidade"]) ?></td>
        <td><?= htmlspecialchars($e["telefone"]) ?></td>
        <td>
            <?php if (!empty($e["website"])): ?>
                <a href="<?= htmlspecialchars($e["website"]) ?>" target="_blank">Website</a>
            <?php else: ?>
                -
            <?php endif; ?>
        </td>
        <td>
            <form action="/siestagios/aluno/estagios_empresa.php" method="get" style="margin:0;">
                <input type="hidden" name="id" value="<?= (int)$e["empresa_id"] ?>">
                <button type="submit">Ver estágios</button>
            </form>
        </td>
    </tr>
<?php endforeach; ?>

</table>

</body>
</html>