<?php
require_once "../includes/db.php";

$empresa_id = $_GET["id"] ?? null;

if (!$empresa_id) {
    die("Empresa inválida.");
}


$sql = "
SELECT 
    est.estabelecimento_id,
    est.data_inicio,
    est.data_fim,

    e.firma AS empresa,
    e.telefone AS empresa_telefone,
    e.localidade AS empresa_localidade,

    estb.morada,
    estb.localidade AS estabelecimento_localidade,

    r.nome AS responsavel_nome,
    r.cargo,
    r.telemovel,
    r.email
FROM estagio est
JOIN estabelecimento estb ON estb.estabelecimento_id = est.estabelecimento_id
JOIN empresa e ON e.empresa_id = est.estabelecimento_empresa_id
JOIN responsavel r ON r.responsavel_id = e.responsavel_id
WHERE e.empresa_id = :empresa_id
";

$stmt = $pdo->prepare($sql);
$stmt->execute([":empresa_id" => $empresa_id]);
$estagios = $stmt->fetchAll();
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Estágios da Empresa</title>

    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f7f3ee; /* bege suave */
            margin: 0;
            padding: 30px;
        }

        h1, h2 {
            margin-top: 0;
        }

        .container {
            max-width: 1000px;
            margin: auto;
        }

        .estagio-card {
            background: #fff;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
        }

        .grid h4 {
            margin-top: 0;
            margin-bottom: 8px;
            color: #333;
        }

        .grid p {
            margin: 4px 0;
            font-size: 14px;
        }

        .datas {
            margin-top: 10px;
            font-size: 13px;
            color: #555;
        }

        .voltar {
            display: inline-block;
            margin-top: 20px;
        }
    </style>
</head>
<body>

<div class="container">

    <h1>Portal do Aluno</h1>
    <h2>Estágios da Empresa</h2>

    <?php if (count($estagios) === 0): ?>
        <p>Esta empresa não tem estágios registados.</p>
    <?php endif; ?>

    <?php foreach ($estagios as $e): ?>
        <div class="estagio-card">

            <div class="grid">

                <!-- Empresa -->
                <div>
                    <h4>Empresa</h4>
                    <p><strong><?= htmlspecialchars($e["empresa"]) ?></strong></p>
                    <p>Telefone: <?= htmlspecialchars($e["empresa_telefone"]) ?></p>
                    <p>Localidade: <?= htmlspecialchars($e["empresa_localidade"]) ?></p>
                </div>

                <!-- Estabelecimento -->
                <div>
                    <h4>Estabelecimento</h4>
                    <p>Morada: <?= htmlspecialchars($e["morada"]) ?></p>
                    <p>Localidade: <?= htmlspecialchars($e["estabelecimento_localidade"]) ?></p>
                </div>

                <!-- Responsável -->
                <div>
                    <h4>Responsável</h4>
                    <p><?= htmlspecialchars($e["responsavel_nome"]) ?></p>
                    <p><?= htmlspecialchars($e["cargo"]) ?></p>
                    <p><?= htmlspecialchars($e["telemovel"]) ?></p>
                    <p><?= htmlspecialchars($e["email"]) ?></p>
                </div>

            </div>

            <div class="datas">
                <strong>Data de início:</strong> <?= htmlspecialchars($e["data_inicio"]) ?> |
                <strong>Data de fim:</strong> <?= htmlspecialchars($e["data_fim"] ?? "Em curso") ?>
            </div>

        </div>
    <?php endforeach; ?>

    <a href="empresas.php" class="voltar">Voltar às empresas</a>

</div>

</body>
</html>