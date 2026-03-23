-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 22-Dez-2025 às 03:10
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `siestagios`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `P1` (IN `p_aluno_id` INT, IN `p_empresa_id` INT, IN `p_estabelecimento_id` INT, IN `p_formador_id` INT, IN `p_data_inicio` DATE, IN `p_data_fim` DATE, IN `p_nota_escola` INT, IN `p_nota_relatorio` INT, IN `p_nota_procura` INT, IN `p_classificacao` TINYINT)   BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM aluno
        WHERE utilizador_id = p_aluno_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aluno não existe.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM formador
        WHERE utilizador_id = p_formador_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formador não existe.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM estabelecimento
        WHERE empresa_id = p_empresa_id
          AND estabelecimento_id = p_estabelecimento_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estabelecimento não existe.';
    END IF;

    INSERT INTO estagio (
        estabelecimento_empresa_id,
        estabelecimento_id,
        aluno_id,
        formador_id,
        data_inicio,
        data_fim,
        nota_escola,
        nota_relatorio,
        nota_procura,
        classificacao
    ) VALUES (
        p_empresa_id,
        p_estabelecimento_id,
        p_aluno_id,
        p_formador_id,
        p_data_inicio,
        p_data_fim,
        p_nota_escola,
        p_nota_relatorio,
        p_nota_procura,
        p_classificacao
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `P2` (IN `p_dias` INT)   BEGIN
    IF p_dias < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O número de dias não pode ser negativo.';
    END IF;

    SELECT *
    FROM estagio
    WHERE data_inicio BETWEEN CURDATE()
                         AND DATE_ADD(CURDATE(), INTERVAL p_dias DAY)
    ORDER BY data_inicio;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `F1` (`p_estabelecimento_empresa_id` INT, `p_estabelecimento_id` INT, `p_ano_letivo` INT) RETURNS DECIMAL(5,2) DETERMINISTIC BEGIN
    DECLARE v_media DECIMAL(5,2);

    SELECT AVG(classificacao)
    INTO v_media
    FROM estagio
    WHERE estabelecimento_empresa_id = p_estabelecimento_empresa_id
      AND estabelecimento_id = p_estabelecimento_id
      AND classificacao IS NOT NULL
      AND data_inicio >= CONCAT(p_ano_letivo, '-09-01')
      AND data_inicio <  CONCAT(p_ano_letivo + 1, '-09-01');

    RETURN v_media;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `F2` (`p_estabelecimento_empresa_id` INT, `p_estabelecimento_id` INT, `p_aluno_id` INT, `p_peso_empresa` DECIMAL(10,4), `p_peso_escola` DECIMAL(10,4), `p_peso_relatorio` DECIMAL(10,4), `p_peso_procura` DECIMAL(10,4)) RETURNS DECIMAL(5,2) DETERMINISTIC BEGIN
    DECLARE v_empresa DOUBLE;
    DECLARE v_escola DOUBLE;
    DECLARE v_relatorio DOUBLE;
    DECLARE v_procura DOUBLE;
    DECLARE v_soma DECIMAL(20,8);
    DECLARE v_res DECIMAL(10,4);

    IF NOT EXISTS (
        SELECT 1
        FROM estagio
        WHERE estabelecimento_empresa_id = p_estabelecimento_empresa_id
          AND estabelecimento_id = p_estabelecimento_id
          AND aluno_id = p_aluno_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estágio não existe.';
    END IF;

    SET v_soma = p_peso_empresa + p_peso_escola + p_peso_relatorio + p_peso_procura;

    IF v_soma = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Soma dos pesos não pode ser 0.';
    END IF;

    SELECT nota_empresa, nota_escola, nota_relatorio, nota_procura
      INTO v_empresa, v_escola, v_relatorio, v_procura
    FROM estagio
    WHERE estabelecimento_empresa_id = p_estabelecimento_empresa_id
      AND estabelecimento_id = p_estabelecimento_id
      AND aluno_id = p_aluno_id
    LIMIT 1;

    SET v_res =
        (v_empresa * p_peso_empresa +
         v_escola * p_peso_escola +
         v_relatorio * p_peso_relatorio +
         v_procura * p_peso_procura) / v_soma;

    RETURN ROUND(v_res, 2);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `administrativo`
--

CREATE TABLE `administrativo` (
  `utilizador_id` int(11) NOT NULL,
  `funcao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `administrativo`
--

INSERT INTO `administrativo` (`utilizador_id`, `funcao`) VALUES
(6, 'Secretariado'),
(7, 'Direção');

-- --------------------------------------------------------

--
-- Estrutura da tabela `aluno`
--

CREATE TABLE `aluno` (
  `turma_id` int(11) NOT NULL,
  `utilizador_id` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `aluno`
--

INSERT INTO `aluno` (`turma_id`, `utilizador_id`, `numero`, `observacoes`) VALUES
(1, 1, 10, NULL),
(1, 2, 11, NULL),
(2, 3, 4, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `classificacao`
--

CREATE TABLE `classificacao` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `classificacao_id` int(11) NOT NULL,
  `ano_letivo` varchar(150) DEFAULT NULL,
  `media` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `classificacao`
--

INSERT INTO `classificacao` (`estabelecimento_empresa_id`, `estabelecimento_id`, `classificacao_id`, `ano_letivo`, `media`) VALUES
(1, 1, 1, '2023/2024', 4.3),
(2, 1, 2, '2023/2024', 4),
(3, 1, 3, '2023/2024', 3.9);

-- --------------------------------------------------------

--
-- Estrutura da tabela `comercializa`
--

CREATE TABLE `comercializa` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `comercializa`
--

INSERT INTO `comercializa` (`estabelecimento_empresa_id`, `estabelecimento_id`, `produto_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `curso`
--

CREATE TABLE `curso` (
  `curso_id` int(11) NOT NULL,
  `codigo` varchar(150) DEFAULT NULL,
  `designacao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `curso`
--

INSERT INTO `curso` (`curso_id`, `codigo`, `designacao`) VALUES
(1, 'INF01', 'Informática'),
(2, 'GEST01', 'Gestão'),
(3, 'CONT01', 'Contabilidade'),
(4, 'MKT01', 'Marketing'),
(5, 'DIR01', 'Direito'),
(6, 'SAU01', 'Saúde'),
(7, 'EDI01', 'Edificações');

-- --------------------------------------------------------

--
-- Estrutura da tabela `disponibilidade`
--

CREATE TABLE `disponibilidade` (
  `empresa_id` int(11) NOT NULL,
  `disponibilidade_id` int(11) NOT NULL,
  `ano` int(11) DEFAULT NULL,
  `num_estagios` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `disponibilidade`
--

INSERT INTO `disponibilidade` (`empresa_id`, `disponibilidade_id`, `ano`, `num_estagios`) VALUES
(1, 1, 2024, 3),
(2, 2, 2024, 2),
(3, 3, 2024, 4);

-- --------------------------------------------------------

--
-- Estrutura da tabela `empresa`
--

CREATE TABLE `empresa` (
  `responsavel_id` int(11) DEFAULT NULL,
  `empresa_id` int(11) NOT NULL,
  `num_contribuinte` char(9) DEFAULT NULL,
  `firma` varchar(150) DEFAULT NULL,
  `morada_sede` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `codigo_postal` char(8) DEFAULT NULL,
  `telefone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  `tipo_organizacao` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `empresa`
--

INSERT INTO `empresa` (`responsavel_id`, `empresa_id`, `num_contribuinte`, `firma`, `morada_sede`, `localidade`, `codigo_postal`, `telefone`, `email`, `website`, `tipo_organizacao`, `observacoes`) VALUES
(1, 1, '123456789', 'TecSoft', 'Rua A', 'Lisboa', '1000-001', '210000001', 'info@tecsoft.com', NULL, 'Privada', NULL),
(2, 2, '234567890', 'MarketPlus', 'Rua B', 'Porto', '4000-002', '220000002', 'contact@marketplus.com', NULL, 'Privada', NULL),
(3, 3, '345678901', 'ContabPro', 'Rua C', 'Coimbra', '3000-003', '230000003', 'info@contabpro.com', NULL, 'Privada', NULL),
(4, 4, '456789012', 'HealthClinic', 'Rua D', 'Faro', '8000-004', '240000004', 'admin@healthclinic.com', NULL, 'Privada', NULL),
(5, 5, '567890123', 'BuilderCo', 'Rua E', 'Braga', '4700-005', '250000005', 'geral@builderco.com', NULL, 'Privada', NULL),
(6, 6, '678901234', 'LegalServices', 'Rua F', 'Évora', '7000-006', '260000006', 'info@legalservices.com', NULL, 'Privada', NULL),
(7, 7, '789012345', 'CreativeMedia', 'Rua G', 'Aveiro', '3800-007', '270000007', 'contact@creativemedia.com', NULL, 'Privada', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estabelecimento`
--

CREATE TABLE `estabelecimento` (
  `empresa_id` int(11) NOT NULL,
  `responsavel_id` int(11) NOT NULL,
  `zona_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `nome_comercial` varchar(150) DEFAULT NULL,
  `morada` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `codigo_postal` varchar(150) DEFAULT NULL,
  `telefone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `foto` int(11) DEFAULT NULL,
  `horario_funcionamento` varchar(150) DEFAULT NULL,
  `data_surgimento` date DEFAULT NULL,
  `aceitou_estagiarios` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `estabelecimento`
--

INSERT INTO `estabelecimento` (`empresa_id`, `responsavel_id`, `zona_id`, `estabelecimento_id`, `nome_comercial`, `morada`, `localidade`, `codigo_postal`, `telefone`, `email`, `foto`, `horario_funcionamento`, `data_surgimento`, `aceitou_estagiarios`, `observacoes`) VALUES
(1, 1, 1, 1, 'TecSoft Lisboa', 'Rua A1', 'Lisboa', '1000-001', '210000101', NULL, NULL, NULL, NULL, 'sim', NULL),
(2, 2, 2, 1, 'MarketPlus Porto', 'Rua B1', 'Porto', '4000-002', '220000102', NULL, NULL, NULL, NULL, 'sim', NULL),
(3, 3, 3, 1, 'ContabPro Coimbra', 'Rua C1', 'Coimbra', '3000-003', '230000103', NULL, NULL, NULL, NULL, 'sim', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estagio`
--

CREATE TABLE `estagio` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `aluno_id` int(11) NOT NULL,
  `formador_id` int(11) NOT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `nota_empresa` double DEFAULT NULL,
  `nota_escola` double NOT NULL,
  `nota_relatorio` double NOT NULL,
  `nota_procura` double NOT NULL,
  `nota_final` double DEFAULT NULL,
  `classificacao` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `estagio`
--

INSERT INTO `estagio` (`estabelecimento_empresa_id`, `estabelecimento_id`, `aluno_id`, `formador_id`, `data_inicio`, `data_fim`, `nota_empresa`, `nota_escola`, `nota_relatorio`, `nota_procura`, `nota_final`, `classificacao`) VALUES
(1, 1, 1, 4, '2024-02-01', '2024-06-01', 16, 0, 0, 0, 17, 4),
(1, 1, 2, 4, '2024-04-01', '2024-07-01', NULL, 15, 14, 16, NULL, 4),
(1, 1, 3, 4, '2024-03-01', '2024-06-01', NULL, 0, 0, 0, NULL, 4),
(2, 1, 2, 4, '2024-02-01', '2024-05-01', 14, 0, 0, 0, 15, 5),
(3, 1, 2, 5, '2025-11-02', '2025-11-28', 20, 19, 18, 18, 19, 5),
(3, 1, 3, 5, '2024-02-01', '2024-05-01', 18, 0, 0, 0, 17, 3);

--
-- Acionadores `estagio`
--
DELIMITER $$
CREATE TRIGGER `T1_Insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
    IF NEW.classificacao < 1 OR NEW.classificacao > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Classificação do estagiário deve estar entre 1 e 5';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T1_Update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    IF NEW.classificacao < 1 OR NEW.classificacao > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Classificação do estagiário deve estar entre 1 e 5';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T2` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    IF NEW.data_inicio > NEW.data_fim THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de início não pode ser posterior à data de fim';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `formador`
--

CREATE TABLE `formador` (
  `utilizador_id` int(11) NOT NULL,
  `num_formador` int(11) DEFAULT NULL,
  `disciplina` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `formador`
--

INSERT INTO `formador` (`utilizador_id`, `num_formador`, `disciplina`) VALUES
(4, 101, 'Programação'),
(5, 102, 'Gestão de Projetos');

-- --------------------------------------------------------

--
-- Estrutura da tabela `produto`
--

CREATE TABLE `produto` (
  `produto_id` int(11) NOT NULL,
  `nome_produto` varchar(150) DEFAULT NULL,
  `marca` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `produto`
--

INSERT INTO `produto` (`produto_id`, `nome_produto`, `marca`) VALUES
(1, 'Software Gestão', 'TecSoft'),
(2, 'Serviço Consultoria', 'MarketPlus'),
(3, 'Software Contabilidade', 'ContabPro'),
(4, 'Serviço Clínico', 'HealthClinic'),
(5, 'Material Construção', 'BuilderCo'),
(6, 'Serviço Jurídico', 'LegalServices'),
(7, 'Campanha Publicitária', 'CreativeMedia');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q1`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q1` (
`nome_formador` varchar(150)
,`total_estagios` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q2`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q2` (
`nome_empresa` varchar(150)
,`media_nota_empresa` double
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q3`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q3` (
`nome_empresa` varchar(150)
,`total_produtos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q4`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q4` (
`nome_empresa` varchar(150)
,`total_estagios` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q5`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q5` (
`nome_curso` varchar(150)
,`total_turmas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `q6`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `q6` (
`nome_formador` varchar(150)
,`media_formador` double
,`media_global` double
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `ramo_atividade`
--

CREATE TABLE `ramo_atividade` (
  `ramo_atividade_id` int(11) NOT NULL,
  `codigo_cae` varchar(150) DEFAULT NULL,
  `descricao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `ramo_atividade`
--

INSERT INTO `ramo_atividade` (`ramo_atividade_id`, `codigo_cae`, `descricao`) VALUES
(1, '6201', 'Programação informática'),
(2, '4711', 'Comércio'),
(3, '6920', 'Contabilidade'),
(4, '8622', 'Clínicas'),
(5, '4120', 'Construção Civil'),
(6, '6910', 'Direito'),
(7, '7311', 'Publicidade');

-- --------------------------------------------------------

--
-- Estrutura da tabela `responsavel`
--

CREATE TABLE `responsavel` (
  `responsavel_id` int(11) NOT NULL,
  `nome` varchar(150) DEFAULT NULL,
  `titulo` varchar(150) DEFAULT NULL,
  `cargo` varchar(150) DEFAULT NULL,
  `telefone_direto` varchar(150) DEFAULT NULL,
  `telemovel` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `responsavel`
--

INSERT INTO `responsavel` (`responsavel_id`, `nome`, `titulo`, `cargo`, `telefone_direto`, `telemovel`, `email`, `observacoes`) VALUES
(1, 'José Pereira', 'Dr.', 'Gerente Geral', '212345678', '912345678', 'jose@empresa.com', NULL),
(2, 'Rita Costa', 'Eng.', 'Diretora', '212398888', '918888888', 'rita@empresa.com', NULL),
(3, 'Pedro Alves', NULL, 'Supervisor', NULL, '919191919', NULL, NULL),
(4, 'Mariana Ribeiro', 'Dr.', 'Administradora', NULL, NULL, NULL, NULL),
(5, 'Tiago Ramos', NULL, 'Chefe', NULL, NULL, NULL, NULL),
(6, 'Carlos Martins', NULL, 'Gestor', NULL, NULL, NULL, NULL),
(7, 'Sofia Duarte', NULL, 'Responsável', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `serve`
--

CREATE TABLE `serve` (
  `transporte_id` int(11) NOT NULL,
  `zona_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `serve`
--

INSERT INTO `serve` (`transporte_id`, `zona_id`) VALUES
(1, 1),
(2, 2),
(3, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `servido`
--

CREATE TABLE `servido` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `transporte_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `servido`
--

INSERT INTO `servido` (`estabelecimento_empresa_id`, `estabelecimento_id`, `transporte_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `trabalha`
--

CREATE TABLE `trabalha` (
  `empresa_id` int(11) NOT NULL,
  `ramo_atividade_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `trabalha`
--

INSERT INTO `trabalha` (`empresa_id`, `ramo_atividade_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7);

-- --------------------------------------------------------

--
-- Estrutura da tabela `transporte`
--

CREATE TABLE `transporte` (
  `transporte_id` int(11) NOT NULL,
  `meio_transporte` varchar(150) DEFAULT NULL,
  `linha` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `transporte`
--

INSERT INTO `transporte` (`transporte_id`, `meio_transporte`, `linha`, `observacoes`) VALUES
(1, 'Autocarro', 'Linha 10', NULL),
(2, 'Metro', 'Linha Azul', NULL),
(3, 'Comboio', 'Linha Norte', NULL),
(4, 'Táxi', 'Linha 2', NULL),
(5, 'Uber', 'Linha Norte', NULL),
(6, 'Carrinha Empresa', NULL, NULL),
(7, 'Elétrico', 'Linha 28', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `turma`
--

CREATE TABLE `turma` (
  `curso_id` int(11) NOT NULL,
  `turma_id` int(11) NOT NULL,
  `sigla` varchar(150) DEFAULT NULL,
  `ano` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `turma`
--

INSERT INTO `turma` (`curso_id`, `turma_id`, `sigla`, `ano`) VALUES
(1, 1, 'INF-A', 2024),
(1, 2, 'INF-B', 2024),
(2, 3, 'GEST-A', 2024),
(3, 4, 'CONT-A', 2024),
(4, 5, 'MKT-A', 2024),
(5, 6, 'DIR-A', 2024),
(6, 7, 'SAU-A', 2024);

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

CREATE TABLE `utilizador` (
  `utilizador_id` int(11) NOT NULL,
  `login` varchar(150) DEFAULT NULL,
  `password` varchar(150) DEFAULT NULL,
  `nome` varchar(150) DEFAULT NULL,
  `tipo` enum('aluno','formador','administrativo','') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`utilizador_id`, `login`, `password`, `nome`, `tipo`) VALUES
(1, 'joao.silva', 'pass123', 'João Silva', 'aluno'),
(2, 'maria.lima', 'pass123', 'Maria Lima', 'aluno'),
(3, 'carlos.sousa', 'pass123', 'Carlos Sousa', 'aluno'),
(4, 'ana.mendes', 'pass123', 'Ana Mendes', 'formador'),
(5, 'ricardo.gomes', 'pass123', 'Ricardo Gomes', 'formador'),
(6, 'helena.alves', 'pass123', 'Helena Alves', 'administrativo'),
(7, 'paulo.rocha', 'pass123', 'Paulo Rocha', 'administrativo');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v1`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `v1` (
`nome_formador` varchar(150)
,`total_estagios` bigint(21)
,`media_notas_formador` double
,`media_global_notas` double
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v2`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `v2` (
`nome_empresa` varchar(150)
,`nome_curso` varchar(150)
,`media_nota_final` double
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `zona`
--

CREATE TABLE `zona` (
  `zona_id` int(11) NOT NULL,
  `designacao` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `mapa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `zona`
--

INSERT INTO `zona` (`zona_id`, `designacao`, `localidade`, `mapa`) VALUES
(1, 'Centro', 'Lisboa', NULL),
(2, 'Norte', 'Porto', NULL),
(3, 'Centro', 'Coimbra', NULL),
(4, 'Sul', 'Faro', NULL),
(5, 'Minho', 'Braga', NULL),
(6, 'Alentejo', 'Évora', NULL),
(7, 'Beira', 'Aveiro', NULL);

-- --------------------------------------------------------

--
-- Estrutura para vista `q1`
--
DROP TABLE IF EXISTS `q1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q1`  AS SELECT `u`.`nome` AS `nome_formador`, count(0) AS `total_estagios` FROM ((`estagio` `e` join `formador` `f` on(`f`.`utilizador_id` = `e`.`formador_id`)) join `utilizador` `u` on(`u`.`utilizador_id` = `f`.`utilizador_id`)) GROUP BY `u`.`utilizador_id`, `u`.`nome` HAVING count(0) > 1 ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q2`
--
DROP TABLE IF EXISTS `q2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q2`  AS SELECT `e`.`firma` AS `nome_empresa`, avg(`s`.`nota_empresa`) AS `media_nota_empresa` FROM (`empresa` `e` join `estagio` `s` on(`s`.`estabelecimento_empresa_id` = `e`.`empresa_id`)) GROUP BY `e`.`empresa_id`, `e`.`firma` HAVING avg(`s`.`nota_empresa`) >= 14 ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q3`
--
DROP TABLE IF EXISTS `q3`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q3`  AS SELECT `e`.`firma` AS `nome_empresa`, count(`c`.`produto_id`) AS `total_produtos` FROM (`empresa` `e` join `comercializa` `c` on(`c`.`estabelecimento_empresa_id` = `e`.`empresa_id`)) GROUP BY `e`.`firma` HAVING count(`c`.`produto_id`) >= 1 ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q4`
--
DROP TABLE IF EXISTS `q4`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q4`  AS SELECT `e`.`firma` AS `nome_empresa`, count(0) AS `total_estagios` FROM (`empresa` `e` join `estagio` `s` on(`s`.`estabelecimento_empresa_id` = `e`.`empresa_id`)) GROUP BY `e`.`empresa_id`, `e`.`firma` HAVING count(0) >= 1 ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q5`
--
DROP TABLE IF EXISTS `q5`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q5`  AS SELECT `c`.`designacao` AS `nome_curso`, count(`t`.`turma_id`) AS `total_turmas` FROM (`curso` `c` join `turma` `t` on(`t`.`curso_id` = `c`.`curso_id`)) GROUP BY `c`.`curso_id`, `c`.`designacao` HAVING count(`t`.`turma_id`) > (select avg(`sub`.`num_turmas`) from (select count(0) AS `num_turmas` from `turma` group by `turma`.`curso_id`) `sub`) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `q6`
--
DROP TABLE IF EXISTS `q6`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q6`  AS SELECT `u`.`nome` AS `nome_formador`, avg(`e`.`nota_final`) AS `media_formador`, (select avg(`estagio`.`nota_final`) from `estagio` where `estagio`.`nota_final` is not null) AS `media_global` FROM ((`estagio` `e` join `formador` `f` on(`f`.`utilizador_id` = `e`.`formador_id`)) join `utilizador` `u` on(`u`.`utilizador_id` = `f`.`utilizador_id`)) WHERE `e`.`nota_final` is not null GROUP BY `u`.`nome` HAVING avg(`e`.`nota_final`) > (select avg(`estagio`.`nota_final`) from `estagio` where `estagio`.`nota_final` is not null) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v1`
--
DROP TABLE IF EXISTS `v1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v1`  AS SELECT `u`.`nome` AS `nome_formador`, count(`e`.`formador_id`) AS `total_estagios`, avg(`e`.`nota_final`) AS `media_notas_formador`, (select avg(`estagio`.`nota_final`) from `estagio` where `estagio`.`nota_final` is not null) AS `media_global_notas` FROM ((`estagio` `e` join `formador` `f` on(`f`.`utilizador_id` = `e`.`formador_id`)) join `utilizador` `u` on(`u`.`utilizador_id` = `f`.`utilizador_id`)) WHERE `e`.`nota_final` is not null GROUP BY `u`.`nome` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v2`
--
DROP TABLE IF EXISTS `v2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v2`  AS SELECT `emp`.`firma` AS `nome_empresa`, `c`.`designacao` AS `nome_curso`, avg(`e`.`nota_final`) AS `media_nota_final` FROM ((((`estagio` `e` join `empresa` `emp` on(`emp`.`empresa_id` = `e`.`estabelecimento_empresa_id`)) join `aluno` `a` on(`a`.`utilizador_id` = `e`.`aluno_id`)) join `turma` `t` on(`t`.`turma_id` = `a`.`turma_id`)) join `curso` `c` on(`c`.`curso_id` = `t`.`curso_id`)) WHERE `e`.`nota_final` is not null GROUP BY `emp`.`firma`, `c`.`designacao` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `aluno`
--
ALTER TABLE `aluno`
  ADD PRIMARY KEY (`utilizador_id`),
  ADD KEY `fk_aluno_turma` (`turma_id`);

--
-- Índices para tabela `classificacao`
--
ALTER TABLE `classificacao`
  ADD PRIMARY KEY (`classificacao_id`),
  ADD KEY `fk_classificacao_recebe_estabelecimento` (`estabelecimento_empresa_id`,`estabelecimento_id`);

--
-- Índices para tabela `comercializa`
--
ALTER TABLE `comercializa`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`produto_id`),
  ADD KEY `fk_produto_comercializa_estabelecimento` (`produto_id`);

--
-- Índices para tabela `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`curso_id`);

--
-- Índices para tabela `disponibilidade`
--
ALTER TABLE `disponibilidade`
  ADD PRIMARY KEY (`disponibilidade_id`),
  ADD KEY `fk_disponibilidade_oferece_empresa` (`empresa_id`);

--
-- Índices para tabela `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`empresa_id`),
  ADD KEY `fk_empresa_lidera_responsavel` (`responsavel_id`);

--
-- Índices para tabela `estabelecimento`
--
ALTER TABLE `estabelecimento`
  ADD PRIMARY KEY (`empresa_id`,`estabelecimento_id`),
  ADD KEY `fk_estabelecimento_pertence_responsavel` (`responsavel_id`),
  ADD KEY `fk_estabelecimento_situado_zona` (`zona_id`);

--
-- Índices para tabela `estagio`
--
ALTER TABLE `estagio`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`aluno_id`),
  ADD KEY `fk_aluno_estagio_estabelecimento` (`aluno_id`),
  ADD KEY `fk_estagio_acompanhado_formador` (`formador_id`);

--
-- Índices para tabela `formador`
--
ALTER TABLE `formador`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`produto_id`);

--
-- Índices para tabela `ramo_atividade`
--
ALTER TABLE `ramo_atividade`
  ADD PRIMARY KEY (`ramo_atividade_id`);

--
-- Índices para tabela `responsavel`
--
ALTER TABLE `responsavel`
  ADD PRIMARY KEY (`responsavel_id`);

--
-- Índices para tabela `serve`
--
ALTER TABLE `serve`
  ADD PRIMARY KEY (`transporte_id`,`zona_id`),
  ADD KEY `fk_zona_serve_transporte` (`zona_id`);

--
-- Índices para tabela `servido`
--
ALTER TABLE `servido`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`transporte_id`),
  ADD KEY `fk_transporte_servido_estabelecimento` (`transporte_id`);

--
-- Índices para tabela `trabalha`
--
ALTER TABLE `trabalha`
  ADD PRIMARY KEY (`empresa_id`,`ramo_atividade_id`),
  ADD KEY `fk_ramo_atividade_trabalha_empresa` (`ramo_atividade_id`);

--
-- Índices para tabela `transporte`
--
ALTER TABLE `transporte`
  ADD PRIMARY KEY (`transporte_id`);

--
-- Índices para tabela `turma`
--
ALTER TABLE `turma`
  ADD PRIMARY KEY (`turma_id`),
  ADD KEY `fk_turma_tem_curso` (`curso_id`);

--
-- Índices para tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `zona`
--
ALTER TABLE `zona`
  ADD PRIMARY KEY (`zona_id`);

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD CONSTRAINT `fk_administrativo_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `aluno`
--
ALTER TABLE `aluno`
  ADD CONSTRAINT `fk_aluno_turma` FOREIGN KEY (`turma_id`) REFERENCES `turma` (`turma_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aluno_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `classificacao`
--
ALTER TABLE `classificacao`
  ADD CONSTRAINT `fk_classificacao_recebe_estabelecimento` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `comercializa`
--
ALTER TABLE `comercializa`
  ADD CONSTRAINT `fk_estabelecimento_comercializa_produto` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_produto_comercializa_estabelecimento` FOREIGN KEY (`produto_id`) REFERENCES `produto` (`produto_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `disponibilidade`
--
ALTER TABLE `disponibilidade`
  ADD CONSTRAINT `fk_disponibilidade_oferece_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `empresa`
--
ALTER TABLE `empresa`
  ADD CONSTRAINT `fk_empresa_lidera_responsavel` FOREIGN KEY (`responsavel_id`) REFERENCES `responsavel` (`responsavel_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estabelecimento`
--
ALTER TABLE `estabelecimento`
  ADD CONSTRAINT `fk_estabelecimento_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_pertence_responsavel` FOREIGN KEY (`responsavel_id`) REFERENCES `responsavel` (`responsavel_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_situado_zona` FOREIGN KEY (`zona_id`) REFERENCES `zona` (`zona_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estagio`
--
ALTER TABLE `estagio`
  ADD CONSTRAINT `fk_aluno_estagio_estabelecimento` FOREIGN KEY (`aluno_id`) REFERENCES `aluno` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_estagio_aluno` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estagio_acompanhado_formador` FOREIGN KEY (`formador_id`) REFERENCES `formador` (`utilizador_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `formador`
--
ALTER TABLE `formador`
  ADD CONSTRAINT `fk_formador_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `serve`
--
ALTER TABLE `serve`
  ADD CONSTRAINT `fk_transporte_serve_zona` FOREIGN KEY (`transporte_id`) REFERENCES `transporte` (`transporte_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_zona_serve_transporte` FOREIGN KEY (`zona_id`) REFERENCES `zona` (`zona_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `servido`
--
ALTER TABLE `servido`
  ADD CONSTRAINT `fk_estabelecimento_servido_transporte` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transporte_servido_estabelecimento` FOREIGN KEY (`transporte_id`) REFERENCES `transporte` (`transporte_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `trabalha`
--
ALTER TABLE `trabalha`
  ADD CONSTRAINT `fk_empresa_trabalha_ramo_atividade` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ramo_atividade_trabalha_empresa` FOREIGN KEY (`ramo_atividade_id`) REFERENCES `ramo_atividade` (`ramo_atividade_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `turma`
--
ALTER TABLE `turma`
  ADD CONSTRAINT `fk_turma_tem_curso` FOREIGN KEY (`curso_id`) REFERENCES `curso` (`curso_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
