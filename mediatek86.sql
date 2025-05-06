-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 30 avr. 2025 à 22:27
-- Version du serveur : 8.2.0
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : mediatek86
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `insertAbonnementRevue`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertAbonnementRevue` (IN `v_id` VARCHAR(5), IN `v_dateCommande` DATE, IN `v_montant` DOUBLE, IN `v_dateFinAbonn` DATE, IN `v_idRevue` VARCHAR(5))   BEGIN
	INSERT INTO commande (id, dateCommande, montant)
    VALUES (v_id, v_dateCommande, v_montant);
    
    INSERT INTO abonnement (id, dateFinAbonnement, idRevue)
    VALUES (v_id, v_dateFinAbonn, v_idRevue);
END$$

DROP PROCEDURE IF EXISTS `insertCommande`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertCommande` (IN `v_id` VARCHAR(5), IN `v_dateCommande` DATE, IN `v_montant` DOUBLE, IN `v_nbExemplaire` INT, IN `v_idLivreDvd` VARCHAR(10), IN `v_idSuivi` VARCHAR(10))   BEGIN
	
	INSERT INTO commande (id, dateCommande, montant) 
    VALUES (v_id, v_dateCommande, v_montant);
	
	INSERT INTO commandedocument (id, nbExemplaire, idLivreDvd, idSuivi) 
    VALUES (v_id, v_nbExemplaire, v_idLivreDvd, v_idSuivi);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table abonnement
--

DROP TABLE IF EXISTS abonnement;
CREATE TABLE abonnement (
  id varchar(5) NOT NULL,
  dateFinAbonnement date DEFAULT NULL,
  idRevue varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table abonnement
--

INSERT INTO abonnement (id, dateFinAbonnement, idRevue) VALUES
('00004', '2025-05-05', '10006');

-- --------------------------------------------------------

--
-- Structure de la table commande
--

DROP TABLE IF EXISTS commande;
CREATE TABLE commande (
  id varchar(5) NOT NULL,
  dateCommande date DEFAULT NULL,
  montant double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table commande
--

INSERT INTO commande (id, dateCommande, montant) VALUES
('00001', '2025-04-21', 12),
('00002', '2025-04-21', 30),
('00003', '2025-04-21', 15),
('00004', '2025-04-21', 12),
('00005', '2025-04-21', 10),
('00006', '2025-04-21', 30),
('00007', '2025-04-28', 37),
('00008', '2025-04-28', 20),
('00009', '2025-04-28', 60),
('00010', '2025-04-28', 55),
('00012', '2025-04-28', 20),
('00013', '2025-04-29', 20),
('00015', '2025-04-30', 15),
('00016', '2025-04-30', 15),
('00017', '2025-04-30', 30),
('00018', '2025-04-30', 25);

--
-- Déclencheurs commande
--
DROP TRIGGER IF EXISTS `supprimer_commande_doc`;
DELIMITER $$
CREATE TRIGGER `supprimer_commande_doc` BEFORE DELETE ON `commande` FOR EACH ROW BEGIN
    IF EXISTS (SELECT 1 FROM commandedocument WHERE id 		= OLD.id) THEN
        DELETE FROM commandedocument WHERE id = 			OLD.id;
    ELSE
        DELETE FROM abonnement WHERE id = OLD.id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table commandedocument
--

DROP TABLE IF EXISTS commandedocument;
CREATE TABLE commandedocument (
  id varchar(5) NOT NULL,
  nbExemplaire int DEFAULT NULL,
  idLivreDvd varchar(10) NOT NULL,
  idSuivi varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table commandedocument
--

INSERT INTO commandedocument (id, nbExemplaire, idLivreDvd, idSuivi) VALUES
('00001', 1, '00003', '3'),
('00002', 1, '00017', '3'),
('00003', 1, '20003', '3'),
('00005', 2, '00007', '3'),
('00006', 1, '20002', '2'),
('00007', 3, '00013', '3'),
('00008', 2, '20001', '2'),
('00009', 15, '00011', '1'),
('00010', 20, '00016', '1'),
('00012', 2, '20002', '2'),
('00015', 1, '00004', '2'),
('00017', 2, '00003', '2'),
('00018', 1, '20004', '2');

--
-- Déclencheurs commandedocument
--
DROP TRIGGER IF EXISTS `ajout_exemplaires`;
DELIMITER $$
CREATE TRIGGER `ajout_exemplaires` AFTER UPDATE ON `commandedocument` FOR EACH ROW BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE nb_ex INT;
    DECLARE numero_seq INT;
    DECLARE date_com DATE;
    
    -- Vérifie si idSuivi est passé à 2
    IF NEW.idSuivi = 2 THEN
        -- Compter combien d'exemplaires existent déjà pour ce document
        SELECT COUNT(*) INTO numero_seq FROM exemplaire WHERE id = NEW.idLivreDvd;
        
        SET nb_ex = NEW.nbExemplaire;
        
        -- récupération de la date
        SELECT dateCommande INTO date_com
		FROM commande
		WHERE commande.id = NEW.id;
        
        -- Boucle pour insérer les nouveaux exemplaires
        WHILE i < nb_ex DO
            INSERT INTO exemplaire (id,
                numero, dateAchat, photo, idEtat
            ) VALUES (
                NEW.idLivreDvd,
                numero_seq + i + 1,
                date_com,
                "",                
                '00001'                
            );
            SET i = i + 1;
        END WHILE;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table document
--

DROP TABLE IF EXISTS document;
CREATE TABLE document (
  id varchar(10) NOT NULL,
  titre varchar(60) DEFAULT NULL,
  image varchar(500) DEFAULT NULL,
  idRayon varchar(5) NOT NULL,
  idPublic varchar(5) NOT NULL,
  idGenre varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table document
--

INSERT INTO document (id, titre, image, idRayon, idPublic, idGenre) VALUES
('00001', 'Quand sort la recluse', '', 'LV003', '00002', '10014'),
('00002', 'Un pays à l\'aube', '', 'LV001', '00002', '10004'),
('00003', 'Et je danse aussi', '', 'LV002', '00003', '10013'),
('00004', 'L\'armée furieuse', '', 'LV003', '00002', '10014'),
('00005', 'Les anonymes', '', 'LV001', '00002', '10014'),
('00006', 'La marque jaune', '', 'BD001', '00003', '10001'),
('00007', 'Dans les coulisses du musée', '', 'LV001', '00003', '10006'),
('00008', 'Histoire du juif errant', '', 'LV002', '00002', '10006'),
('00009', 'Pars vite et reviens tard', '', 'LV003', '00002', '10014'),
('00010', 'Le vestibule des causes perdues', '', 'LV001', '00002', '10006'),
('00011', 'L\'île des oubliés', '', 'LV002', '00003', '10006'),
('00012', 'La souris bleue', '', 'LV002', '00003', '10006'),
('00013', 'Sacré Pêre Noël', '', 'JN001', '00001', '10001'),
('00014', 'Mauvaise étoile', '', 'LV003', '00003', '10014'),
('00015', 'La confrérie des téméraires', '', 'JN002', '00004', '10014'),
('00016', 'Le butin du requin', '', 'JN002', '00004', '10014'),
('00017', 'Catastrophes au Brésil', '', 'JN002', '00004', '10014'),
('00018', 'Le Routard - Maroc', '', 'DV005', '00003', '10011'),
('00019', 'Guide Vert - Iles Canaries', '', 'DV005', '00003', '10011'),
('00020', 'Guide Vert - Irlande', '', 'DV005', '00003', '10011'),
('00021', 'Les déferlantes', '', 'LV002', '00002', '10006'),
('00022', 'Une part de Ciel', '', 'LV002', '00002', '10006'),
('00023', 'Le secret du janissaire', '', 'BD001', '00002', '10001'),
('00024', 'Pavillon noir', '', 'BD001', '00002', '10001'),
('00025', 'L\'archipel du danger', '', 'BD001', '00002', '10001'),
('00026', 'La planète des singes', '', 'LV002', '00003', '10002'),
('10001', 'Arts Magazine', '', 'PR002', '00002', '10016'),
('10002', 'Alternatives Economiques', '', 'PR002', '00002', '10015'),
('10003', 'Challenges', '', 'PR002', '00002', '10015'),
('10004', 'Rock and Folk', '', 'PR002', '00002', '10016'),
('10005', 'Les Echos', '', 'PR001', '00002', '10015'),
('10006', 'Le Monde', '', 'PR001', '00002', '10018'),
('10007', 'Telerama', '', 'PR002', '00002', '10016'),
('10008', 'L\'Obs', '', 'PR002', '00002', '10018'),
('10009', 'L\'Equipe', '', 'PR001', '00002', '10017'),
('10010', 'L\'Equipe Magazine', '', 'PR002', '00002', '10017'),
('10011', 'Geo', '', 'PR002', '00003', '10016'),
('20001', 'Star Wars 5 L\'empire contre attaque', '', 'DF001', '00003', '10002'),
('20002', 'Le seigneur des anneaux : la communauté de l\'anneau', '', 'DF001', '00003', '10019'),
('20003', 'Jurassic Park', '', 'DF001', '00003', '10002'),
('20004', 'Matrix', '', 'DF001', '00003', '10002');

-- --------------------------------------------------------

--
-- Structure de la table dvd
--

DROP TABLE IF EXISTS dvd;
CREATE TABLE dvd (
  id varchar(10) NOT NULL,
  synopsis text,
  realisateur varchar(20) DEFAULT NULL,
  duree int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table dvd
--

INSERT INTO dvd (id, synopsis, realisateur, duree) VALUES
('20001', 'Luc est entraîné par Yoda pendant que Han et Leia tentent de se cacher dans la cité des nuages.', 'George Lucas', 124),
('20002', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 228),
('20003', 'Un milliardaire et des généticiens créent des dinosaures à partir de clonage.', 'Steven Spielberg', 128),
('20004', 'Un informaticien réalise que le monde dans lequel il vit est une simulation gérée par des machines.', 'Les Wachowski', 136);

-- --------------------------------------------------------

--
-- Structure de la table etat
--

DROP TABLE IF EXISTS etat;
CREATE TABLE etat (
  id char(5) NOT NULL,
  libelle varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table etat
--

INSERT INTO etat (id, libelle) VALUES
('00001', 'neuf'),
('00002', 'usagé'),
('00003', 'détérioré'),
('00004', 'inutilisable');

-- --------------------------------------------------------

--
-- Structure de la table exemplaire
--

DROP TABLE IF EXISTS exemplaire;
CREATE TABLE exemplaire (
  id varchar(10) NOT NULL,
  numero int NOT NULL,
  dateAchat date DEFAULT NULL,
  photo varchar(500) NOT NULL,
  idEtat char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table exemplaire
--

INSERT INTO exemplaire (id, numero, dateAchat, photo, idEtat) VALUES
('00001', 1, '2025-04-13', '', '00001'),
('00001', 2, '2025-04-13', '', '00001'),
('00001', 3, '2025-04-13', '', '00001'),
('00001', 4, '2025-04-13', '', '00001'),
('00001', 5, '2025-04-13', '', '00001'),
('00001', 6, '2025-04-13', '', '00001'),
('00001', 7, '2025-04-13', '', '00001'),
('00001', 8, '2025-04-13', '', '00001'),
('00001', 9, '2025-04-13', '', '00001'),
('00001', 10, '2025-04-13', '', '00001'),
('00002', 1, '2025-04-14', '', '00001'),
('00002', 2, '2025-04-14', '', '00001'),
('00002', 3, '2025-04-14', '', '00001'),
('00003', 1, '2025-04-21', '', '00001'),
('00003', 2, '2025-04-30', '', '00001'),
('00003', 3, '2025-04-30', '', '00001'),
('00004', 1, '2025-04-30', '', '00001'),
('00004', 2, '2025-04-30', '', '00001'),
('00004', 3, '2025-04-30', '', '00001'),
('00005', 1, '2025-04-14', '', '00001'),
('00005', 2, '2025-04-14', '', '00001'),
('00005', 3, '2025-04-14', '', '00001'),
('00013', 1, '2025-04-28', '', '00001'),
('00013', 2, '2025-04-28', '', '00001'),
('00013', 3, '2025-04-28', '', '00001'),
('00017', 1, '2025-04-21', '', '00001'),
('00017', 2, '2025-04-21', '', '00001'),
('10001', 301, '2025-04-16', '', '00001'),
('10002', 418, '2021-12-01', '', '00001'),
('10004', 115, '2025-04-25', '', '00001'),
('10006', 401, '2025-04-25', '', '00001'),
('10007', 3237, '2021-11-23', '', '00001'),
('10007', 3238, '2021-11-30', '', '00001'),
('10007', 3239, '2021-12-07', '', '00001'),
('10007', 3240, '2021-12-21', '', '00001'),
('10007', 3241, '2025-04-30', '', '00001'),
('10011', 505, '2022-10-16', '', '00001'),
('10011', 506, '2021-04-01', '', '00001'),
('10011', 507, '2021-05-03', '', '00001'),
('10011', 508, '2021-06-05', '', '00001'),
('10011', 509, '2021-07-01', '', '00001'),
('10011', 510, '2021-08-04', '', '00001'),
('10011', 511, '2021-09-01', '', '00001'),
('10011', 512, '2021-10-06', '', '00001'),
('10011', 513, '2021-11-01', '', '00001'),
('10011', 514, '2021-12-01', '', '00001'),
('10011', 600, '2025-03-13', '', '00001'),
('10011', 601, '2025-04-12', '', '00001'),
('10011', 602, '2025-04-16', '', '00001'),
('10011', 603, '2025-04-30', '', '00001'),
('20001', 1, '2025-04-28', '', '00001'),
('20001', 2, '2025-04-28', '', '00001'),
('20002', 1, '2025-04-21', '', '00001'),
('20002', 2, '2025-04-28', '', '00001'),
('20002', 3, '2025-04-28', '', '00001'),
('20004', 1, '2025-04-17', '', '00001'),
('20004', 2, '2025-04-30', '', '00001');

-- --------------------------------------------------------

--
-- Structure de la table genre
--

DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
  id varchar(5) NOT NULL,
  libelle varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table genre
--

INSERT INTO genre (id, libelle) VALUES
('10000', 'Humour'),
('10001', 'Bande dessinée'),
('10002', 'Science Fiction'),
('10003', 'Biographie'),
('10004', 'Historique'),
('10006', 'Roman'),
('10007', 'Aventures'),
('10008', 'Essai'),
('10009', 'Documentaire'),
('10010', 'Technique'),
('10011', 'Voyages'),
('10012', 'Drame'),
('10013', 'Comédie'),
('10014', 'Policier'),
('10015', 'Presse Economique'),
('10016', 'Presse Culturelle'),
('10017', 'Presse sportive'),
('10018', 'Actualités'),
('10019', 'Fantazy'),
('10020', 'Manga');

-- --------------------------------------------------------

--
-- Structure de la table livre
--

DROP TABLE IF EXISTS livre;
CREATE TABLE livre (
  id varchar(10) NOT NULL,
  ISBN varchar(13) DEFAULT NULL,
  auteur varchar(20) DEFAULT NULL,
  collection varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table livre
--

INSERT INTO livre (id, ISBN, auteur, collection) VALUES
('00001', '1234569877896', 'Fred Vargas', 'Commissaire Adamsberg'),
('00002', '1236547896541', 'Dennis Lehanne', ''),
('00003', '6541236987410', 'Anne-Laure Bondoux', ''),
('00004', '3214569874123', 'Fred Vargas', 'Commissaire Adamsberg'),
('00005', '3214563214563', 'RJ Ellory', ''),
('00006', '3213213211232', 'Edgar P. Jacobs', 'Blake et Mortimer'),
('00007', '6541236987541', 'Kate Atkinson', ''),
('00008', '1236987456321', 'Jean d\'Ormesson', ''),
('00009', '', 'Fred Vargas', 'Commissaire Adamsberg'),
('00010', '', 'Manon Moreau', ''),
('00011', '', 'Victoria Hislop', ''),
('00012', '', 'Kate Atkinson', ''),
('00013', '', 'Raymond Briggs', ''),
('00014', '', 'RJ Ellory', ''),
('00015', '', 'Floriane Turmeau', ''),
('00016', '', 'Julian Press', ''),
('00017', '', 'Philippe Masson', ''),
('00018', '', '', 'Guide du Routard'),
('00019', '', '', 'Guide Vert'),
('00020', '', '', 'Guide Vert'),
('00021', '', 'Claudie Gallay', ''),
('00022', '', 'Claudie Gallay', ''),
('00023', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00024', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00025', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00026', '', 'Pierre Boulle', 'Julliard');

-- --------------------------------------------------------

--
-- Structure de la table livres_dvd
--

DROP TABLE IF EXISTS livres_dvd;
CREATE TABLE livres_dvd (
  id varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table livres_dvd
--

INSERT INTO livres_dvd (id) VALUES
('00001'),
('00002'),
('00003'),
('00004'),
('00005'),
('00006'),
('00007'),
('00008'),
('00009'),
('00010'),
('00011'),
('00012'),
('00013'),
('00014'),
('00015'),
('00016'),
('00017'),
('00018'),
('00019'),
('00020'),
('00021'),
('00022'),
('00023'),
('00024'),
('00025'),
('00026'),
('20001'),
('20002'),
('20003'),
('20004');

-- --------------------------------------------------------

--
-- Structure de la table public
--

DROP TABLE IF EXISTS public;
CREATE TABLE public (
  id varchar(5) NOT NULL,
  libelle varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table public
--

INSERT INTO public (id, libelle) VALUES
('00001', 'Jeunesse'),
('00002', 'Adultes'),
('00003', 'Tous publics'),
('00004', 'Ados');

-- --------------------------------------------------------

--
-- Structure de la table rayon
--

DROP TABLE IF EXISTS rayon;
CREATE TABLE rayon (
  id char(5) NOT NULL,
  libelle varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table rayon
--

INSERT INTO rayon (id, libelle) VALUES
('BD001', 'BD Adultes'),
('BL001', 'Beaux Livres'),
('DF001', 'DVD films'),
('DV001', 'Sciences'),
('DV002', 'Maison'),
('DV003', 'Santé'),
('DV004', 'Littérature classique'),
('DV005', 'Voyages'),
('JN001', 'Jeunesse BD'),
('JN002', 'Jeunesse romans'),
('LV001', 'Littérature étrangère'),
('LV002', 'Littérature française'),
('LV003', 'Policiers français étrangers'),
('PR001', 'Presse quotidienne'),
('PR002', 'Magazines');

-- --------------------------------------------------------

--
-- Structure de la table revue
--

DROP TABLE IF EXISTS revue;
CREATE TABLE revue (
  id varchar(10) NOT NULL,
  periodicite varchar(2) DEFAULT NULL,
  delaiMiseADispo int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table revue
--

INSERT INTO revue (id, periodicite, delaiMiseADispo) VALUES
('10001', 'MS', 52),
('10002', 'MS', 52),
('10003', 'HB', 15),
('10004', 'HB', 15),
('10005', 'QT', 5),
('10006', 'QT', 5),
('10007', 'HB', 26),
('10008', 'HB', 26),
('10009', 'QT', 5),
('10010', 'HB', 12),
('10011', 'MS', 52);

-- --------------------------------------------------------

--
-- Structure de la table service
--

DROP TABLE IF EXISTS service;
CREATE TABLE service (
  id varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  libelle varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table service
--

INSERT INTO service (id, libelle) VALUES
('1', 'admin'),
('2', 'administratif'),
('3', 'prêts'),
('4', 'culture');

-- --------------------------------------------------------

--
-- Structure de la table suivi
--

DROP TABLE IF EXISTS suivi;
CREATE TABLE suivi (
  id varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  libelle varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table suivi
--

INSERT INTO suivi (id, libelle) VALUES
('1', 'en cours'),
('2', 'livrée'),
('3', 'réglée'),
('4', 'relancée');

-- --------------------------------------------------------

--
-- Structure de la table users
--

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  login varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  pwd varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  idService varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table users
--

INSERT INTO users (id, login, pwd, idService) VALUES
('00001', 'adminMediatek', '4c1ef5fcf562c413e2b995713f1a59f54bded08243de0e22f99e28538e51d413', '1'),
('00002', 'valCommande', '44de515427f941b05a4ff29a51f0a676a95e2fb4cf14d2560c2b6813190629f3', '2'),
('00004', 'sylvieCulture', '8878af0d0fffa80c39c6b378cf7116a5577a8543f85b7aa55416e2c58bf6764e', '4'),
('00003', 'jeanPret', 'dc3c711f5ccb70606ad02a7f360bf86e01dc236b4b7fab4ea7c34ecb68562925', '3'),
('00005', 'charlesPret', 'f56a2e8661e104df5142a62e55d95b95754b1554dbfe041fb2603b8e66bb35dd', '3');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table abonnement
--
ALTER TABLE abonnement
  ADD PRIMARY KEY (id),
  ADD KEY idRevue (idRevue);

--
-- Index pour la table commande
--
ALTER TABLE commande
  ADD PRIMARY KEY (id);

--
-- Index pour la table commandedocument
--
ALTER TABLE commandedocument
  ADD PRIMARY KEY (id),
  ADD KEY idLivreDvd (idLivreDvd),
  ADD KEY idSuivi (idSuivi) USING BTREE;

--
-- Index pour la table document
--
ALTER TABLE document
  ADD PRIMARY KEY (id),
  ADD KEY idRayon (idRayon),
  ADD KEY idPublic (idPublic),
  ADD KEY idGenre (idGenre);

--
-- Index pour la table dvd
--
ALTER TABLE dvd
  ADD PRIMARY KEY (id);

--
-- Index pour la table etat
--
ALTER TABLE etat
  ADD PRIMARY KEY (id);

--
-- Index pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD PRIMARY KEY (id,numero),
  ADD KEY idEtat (idEtat);

--
-- Index pour la table genre
--
ALTER TABLE genre
  ADD PRIMARY KEY (id);

--
-- Index pour la table livre
--
ALTER TABLE livre
  ADD PRIMARY KEY (id);

--
-- Index pour la table livres_dvd
--
ALTER TABLE livres_dvd
  ADD PRIMARY KEY (id);

--
-- Index pour la table public
--
ALTER TABLE public
  ADD PRIMARY KEY (id);

--
-- Index pour la table rayon
--
ALTER TABLE rayon
  ADD PRIMARY KEY (id);

--
-- Index pour la table revue
--
ALTER TABLE revue
  ADD PRIMARY KEY (id);

--
-- Index pour la table service
--
ALTER TABLE service
  ADD PRIMARY KEY (id);

--
-- Index pour la table suivi
--
ALTER TABLE suivi
  ADD PRIMARY KEY (id),
  ADD KEY idx_suivi_id (id);

--
-- Index pour la table users
--
ALTER TABLE users
  ADD PRIMARY KEY (id),
  ADD KEY FK_IDSERVICE (idService);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table abonnement
--
ALTER TABLE abonnement
  ADD CONSTRAINT abonnement_ibfk_1 FOREIGN KEY (id) REFERENCES commande (id),
  ADD CONSTRAINT abonnement_ibfk_2 FOREIGN KEY (idRevue) REFERENCES revue (id);

--
-- Contraintes pour la table commandedocument
--
ALTER TABLE commandedocument
  ADD CONSTRAINT commandedocument_ibfk_1 FOREIGN KEY (id) REFERENCES commande (id),
  ADD CONSTRAINT commandedocument_ibfk_2 FOREIGN KEY (idLivreDvd) REFERENCES livres_dvd (id),
  ADD CONSTRAINT commandedocument_ibfk_3 FOREIGN KEY (idSuivi) REFERENCES suivi (id);

--
-- Contraintes pour la table document
--
ALTER TABLE document
  ADD CONSTRAINT document_ibfk_1 FOREIGN KEY (idRayon) REFERENCES rayon (id),
  ADD CONSTRAINT document_ibfk_2 FOREIGN KEY (idPublic) REFERENCES public (id),
  ADD CONSTRAINT document_ibfk_3 FOREIGN KEY (idGenre) REFERENCES genre (id);

--
-- Contraintes pour la table dvd
--
ALTER TABLE dvd
  ADD CONSTRAINT dvd_ibfk_1 FOREIGN KEY (id) REFERENCES livres_dvd (id);

--
-- Contraintes pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD CONSTRAINT exemplaire_ibfk_1 FOREIGN KEY (id) REFERENCES document (id),
  ADD CONSTRAINT exemplaire_ibfk_2 FOREIGN KEY (idEtat) REFERENCES etat (id);

--
-- Contraintes pour la table livre
--
ALTER TABLE livre
  ADD CONSTRAINT livre_ibfk_1 FOREIGN KEY (id) REFERENCES livres_dvd (id);

--
-- Contraintes pour la table livres_dvd
--
ALTER TABLE livres_dvd
  ADD CONSTRAINT livres_dvd_ibfk_1 FOREIGN KEY (id) REFERENCES document (id);

--
-- Contraintes pour la table revue
--
ALTER TABLE revue
  ADD CONSTRAINT revue_ibfk_1 FOREIGN KEY (id) REFERENCES document (id);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
