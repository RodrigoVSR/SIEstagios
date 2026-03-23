<?php
require_once "../includes/db.php";

/*
 * LISTAR ESTÁGIOS EM CURSO (data_fim IS NULL)
 * e mostrar empresa + nº aluno
 *
 * ATENÇÃO:
 * estagio.aluno_id corresponde a aluno.utilizador_id (na tua BD)
 */
$sqlEstagios = "
SELECT 
    est.estabelecimento_empresa_id,
    est.estabelecimento_id,
    est.aluno_id,
    est.data_inicio,

    a.numero AS numero_aluno,
    e.firma AS empresa
FROM estagio est
JOIN aluno a ON a.utilizador_id = est.aluno_id
JOIN empresa e ON e.empresa_id = est.estabelecimento_empresa_id
WHERE est.data_fim IS NULL
";

$estagios = $pdo->query($sqlEstagios)->fetchAll();

/*
 * SUBMISSÃO DAS NOTAS
 */
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $empresa_id         = (int)$_POST["empresa_id"];
    $estabelecimento_id = (int)$_POST["estabelecimento_id"];
    $aluno_id           = (int)$_POST["aluno_id"]; // isto é estagio.aluno_id

    $nota_empresa   = (float)$_POST["nota_empresa"];
    $nota_escola    = (float)$_POST["nota_escola"];
    $nota_relatorio = (float)$_POST["nota_relatorio"];
    $nota_procura   = (float)$_POST["nota_procura"];
    $data_fim       = $_POST["data_fim"];

    // média
    $nota_final = ($nota_empresa + $nota_escola + $nota_relatorio + $nota_procura) / 4;

    $sqlUpdate = "
    UPDATE estagio
    SET 
        nota_empresa = :nota_empresa,
        nota_escola = :nota_escola,
        nota_relatorio = :nota_relatorio,
        nota_procura = :nota_procura,
        nota_final = :nota_final,
        data_fim = :data_fim
    WHERE estabelecimento_empresa_id = :empresa_id
      AND estabelecimento_id = :estabelecimento_id
      AND aluno_id = :aluno_id
    ";

    try {
        $stmt = $pdo->prepare($sqlUpdate);
        $stmt->execute([
            ":nota_empresa" => $nota_empresa,
            ":nota_escola" => $nota_escola,
            ":nota_relatorio" => $nota_relatorio,
            ":nota_procura" => $nota_procura,
            ":nota_final" => $nota_final,
            ":data_fim" => $data_fim,
            ":empresa_id" => $empresa_id,
            ":estabelecimento_id" => $estabelecimento_id,
            ":aluno_id" => $aluno_id
        ]);

        echo "<p style='color:green;'>Estágio finalizado com sucesso!</p>";

        // refrescar lista depois de finalizar
        $estagios = $pdo->query($sqlEstagios)->fetchAll();

    } catch (PDOException $e) {
        echo "<p style='color:red;'>Erro ao atribuir notas: " . htmlspecialchars($e->getMessage()) . "</p>";
    }
}
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Portal do Formador</title>
</head>
<body>

<h1>Portal do Formador</h1>
<h2>Atribuir Notas e Finalizar Estágio</h2>

<?php if (count($estagios) === 0): ?>
    <p>Não existem estágios em curso.</p>
<?php endif; ?>

<?php foreach ($estagios as $e): ?>
<hr>

<p><strong>Empresa:</strong> <?= htmlspecialchars($e["empresa"]) ?></p>
<p><strong>Aluno Nº:</strong> <?= htmlspecialchars($e["numero_aluno"]) ?></p>
<p><strong>Data de Início:</strong> <?= htmlspecialchars($e["data_inicio"]) ?></p>

<form method="post" style="margin-bottom:20px;">

    <!-- chaves reais do estágio -->
    <input type="hidden" name="empresa_id" value="<?= (int)$e["estabelecimento_empresa_id"] ?>">
    <input type="hidden" name="estabelecimento_id" value="<?= (int)$e["estabelecimento_id"] ?>">
    <input type="hidden" name="aluno_id" value="<?= (int)$e["aluno_id"] ?>">

    <label>Nota da Empresa:</label><br>
    <input type="number" name="nota_empresa" min="0" max="20" step="0.1" required><br><br>

    <label>Nota da Escola:</label><br>
    <input type="number" name="nota_escola" min="0" max="20" step="0.1" required><br><br>

    <label>Nota do Relatório:</label><br>
    <input type="number" name="nota_relatorio" min="0" max="20" step="0.1" required><br><br>

    <label>Nota da Procura:</label><br>
    <input type="number" name="nota_procura" min="0" max="20" step="0.1" required><br><br>

    <label>Data de Fim:</label><br>
    <input type="date" name="data_fim" required><br><br>

    <button type="submit">Finalizar Estágio</button>

</form>

<?php endforeach; ?>

</body>
</html>