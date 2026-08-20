-- ============================================================
--  BI RH - Schéma + données fictives
--  Entreprise : "Mudecorp International SA"
--  Base : bi_rh | Période : 01/01/2024 -> 31/12/2027
--  Contenu : employés, départements, paie, absences, formations
-- ============================================================

DROP DATABASE IF EXISTS bi_rh;
CREATE DATABASE bi_rh CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bi_rh;

-- ------------------------------------------------------------
-- 1. Départements
-- ------------------------------------------------------------
CREATE TABLE dim_departement (
    departement_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_departement VARCHAR(60) NOT NULL,
    directeur      VARCHAR(80) NOT NULL,
    localisation   VARCHAR(50) NOT NULL,
    budget_annuel  DECIMAL(14,2) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Employés
-- ------------------------------------------------------------
CREATE TABLE dim_employe (
    employe_id     INT PRIMARY KEY AUTO_INCREMENT,
    nom            VARCHAR(50) NOT NULL,
    prenom         VARCHAR(50) NOT NULL,
    genre          ENUM('M','F') NOT NULL,
    date_naissance DATE NOT NULL,
    date_embauche  DATE NOT NULL,
    departement_id INT NOT NULL,
    poste          VARCHAR(80) NOT NULL,
    contrat        ENUM('CDI','CDD','STAGE','CONSULTANT') NOT NULL,
    salaire_base   DECIMAL(12,2) NOT NULL,
    statut         ENUM('ACTIF','CONGE_MATERNITE','CONGE_LONGUE_DUREE','DEPART') NOT NULL,
    CONSTRAINT fk_emp_dept FOREIGN KEY (departement_id) REFERENCES dim_departement(departement_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Paie (mensuelle)
-- ------------------------------------------------------------
CREATE TABLE fact_paie (
    paie_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    employe_id     INT NOT NULL,
    annee          SMALLINT NOT NULL,
    mois           TINYINT NOT NULL,
    salaire_brut   DECIMAL(12,2) NOT NULL,
    primes         DECIMAL(12,2) NOT NULL DEFAULT 0,
    impots         DECIMAL(12,2) NOT NULL,
    cotisations    DECIMAL(12,2) NOT NULL,
    salaire_net    DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_paie_emp FOREIGN KEY (employe_id) REFERENCES dim_employe(employe_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Absences
-- ------------------------------------------------------------
CREATE TABLE fact_absence (
    absence_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
    employe_id     INT NOT NULL,
    date_debut     DATE NOT NULL,
    date_fin       DATE NOT NULL,
    type_absence   ENUM('MALADIE','CONGE_PAYE','AUTORISATION','CONGE_MATERNITE','INJUSTIFIEE') NOT NULL,
    motif          VARCHAR(120) NULL,
    CONSTRAINT fk_abs_emp FOREIGN KEY (employe_id) REFERENCES dim_employe(employe_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Formations
-- ------------------------------------------------------------
CREATE TABLE fact_formation (
    formation_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
    employe_id     INT NOT NULL,
    date_formation DATE NOT NULL,
    theme          VARCHAR(120) NOT NULL,
    type           ENUM('INTERNE','EXTERNE','E_LEARNING') NOT NULL,
    duree_heures   INT NOT NULL,
    cout           DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_form_emp FOREIGN KEY (employe_id) REFERENCES dim_employe(employe_id)
) ENGINE=InnoDB;

CREATE INDEX idx_paie_ym   ON fact_paie(annee, mois);
CREATE INDEX idx_abs_date  ON fact_absence(date_debut);
CREATE INDEX idx_form_date ON fact_formation(date_formation);

-- ============================================================
--  DONNÉES
-- ============================================================

-- Départements
INSERT INTO dim_departement (nom_departement, directeur, localisation, budget_annuel) VALUES
('Direction Générale',      'Jean-Marc Kabila',    'Kinshasa',   2500000),
('Finance & Comptabilité',  'Marie Ilunga',        'Kinshasa',   3800000),
('Ventes & Marketing',      'Patrick Tshiala',     'Kinshasa',   4200000),
('Ressources Humaines',     'Sarah Mwamba',        'Lubumbashi', 1800000),
('Production',              'Alain Bisimwa',       'Goma',       5100000),
('Logistique',              'Chantal Mbala',       'Matadi',     2900000),
('Informatique (IT)',       'Fabrice Muhindo',     'Kinshasa',   2200000),
('Support Client',          'Esther Uwimana',      'Bukavu',     1600000),
('Recherche & Développement','Olivier Kongo',      'Kinshasa',   3500000),
('Juridique',               'Béatrice Luzolo',     'Kinshasa',   1500000);

-- Employés (120)
DROP PROCEDURE IF EXISTS gen_employes;
DELIMITER //
CREATE PROCEDURE gen_employes()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_dept INT;
    DECLARE v_genre ENUM('M','F');
    DECLARE v_contrat ENUM('CDI','CDD','STAGE','CONSULTANT');
    DECLARE v_poste VARCHAR(80);
    DECLARE v_salaire DECIMAL(12,2);
    DECLARE v_embauche DATE;
    DECLARE v_naissance DATE;
    DECLARE v_nom VARCHAR(50);
    DECLARE v_prenom VARCHAR(50);
    DECLARE v_statut ENUM('ACTIF','CONGE_MATERNITE','CONGE_LONGUE_DUREE','DEPART');

    TRUNCATE fact_absence;
    TRUNCATE fact_formation;
    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE dim_employe;
    SET FOREIGN_KEY_CHECKS = 1;
    WHILE i <= 120 DO
        SET v_dept    = 1 + FLOOR(RAND()*10);
        SET v_genre   = IF(RAND() < 0.45, 'F', 'M');
        SET v_contrat = ELT(1+FLOOR(RAND()*12), 'CDI','CDI','CDI','CDI','CDI','CDI','CDI','CDI','CDD','CDD','STAGE','CONSULTANT');
        SET v_poste   = ELT(1+FLOOR(RAND()*10),
            'Agent administratif','Comptable','Commercial','Analyste',
            'Technicien','Superviseur','Chef de projet','Développeur',
            'Responsable qualité','Assistant de direction');
        -- salaire selon poste
        SET v_salaire = CASE FLOOR(1+RAND()*10)
            WHEN 1 THEN 600 + RAND()*600      -- agent administratif
            WHEN 2 THEN 900 + RAND()*900      -- comptable
            WHEN 3 THEN 700 + RAND()*1100     -- commercial
            WHEN 4 THEN 1300 + RAND()*1500    -- analyste
            WHEN 5 THEN 800 + RAND()*700      -- technicien
            WHEN 6 THEN 1500 + RAND()*1200    -- superviseur
            WHEN 7 THEN 2500 + RAND()*2500    -- chef de projet
            WHEN 8 THEN 1800 + RAND()*2200    -- développeur
            WHEN 9 THEN 1400 + RAND()*1300    -- responsable qualité
            ELSE 1000 + RAND()*1200 END;      -- assistant
        SET v_salaire = ROUND(v_salaire, 2);
        SET v_embauche = DATE_ADD('2018-01-01', INTERVAL FLOOR(RAND()*3000) DAY);
        IF v_embauche > '2027-12-31' THEN SET v_embauche = '2027-12-31'; END IF;
        SET v_naissance = DATE_ADD('1965-01-01', INTERVAL FLOOR(RAND()*12000) DAY);
        SET v_nom = ELT(1+FLOOR(RAND()*20),
            'Kabila','Ilunga','Tshiala','Mwamba','Nkulu','Bisimwa','Uwimana','Muhindo',
            'Mbala','Kongo','Luzolo','Mbuyi','Kasongo','Lukusa','Ntumba','Kalala',
            'Mukendi','Tshibanda','Banza','Mpoyi');
        SET v_prenom = ELT(1+FLOOR(RAND()*20),
            'Jean','Marie','Patrick','Sarah','Grace','Alain','Esther','Fabrice',
            'Chantal','Olivier','Béatrice','Dieudonné','Clarisse','Paul','Anne',
            'Emmanuel','Josué','Laetitia','Michaël','Ruth');
        SET v_statut = ELT(1+FLOOR(RAND()*25), 'DEPART','CONGE_LONGUE_DUREE','CONGE_MATERNITE',
                          'ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF',
                          'ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF',
                          'ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF','ACTIF');
        IF v_statut = 'DEPART' AND v_embauche > '2024-01-01' THEN SET v_statut = 'ACTIF'; END IF;

        INSERT INTO dim_employe (nom, prenom, genre, date_naissance, date_embauche,
                                 departement_id, poste, contrat, salaire_base, statut)
        VALUES (v_nom, v_prenom, v_genre, v_naissance, v_embauche,
                v_dept, v_poste, v_contrat, v_salaire, v_statut);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
CALL gen_employes();

-- Paie mensuelle (01/2024 -> 12/2027)
DROP PROCEDURE IF EXISTS gen_paie;
DELIMITER //
CREATE PROCEDURE gen_paie()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    DECLARE v_emp INT DEFAULT 1;
    DECLARE v_salaire DECIMAL(12,2);
    DECLARE v_prime DECIMAL(12,2);
    DECLARE v_brut DECIMAL(12,2);
    DECLARE v_impot DECIMAL(12,2);
    DECLARE v_cot DECIMAL(12,2);
    TRUNCATE fact_paie;
    WHILE d <= '2027-12-01' DO
        SET v_emp = 1;
        WHILE v_emp <= 120 DO
            SELECT salaire_base, statut INTO v_salaire, @st FROM dim_employe WHERE employe_id = v_emp;
            IF @st <> 'DEPART' AND (v_emp % 5) <> 0 THEN
                SET v_prime = CASE FLOOR(RAND()*6) WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE v_salaire * (0.05 + RAND()*0.15) END;
                SET v_brut  = v_salaire + v_prime;
                SET v_impot = v_brut * (0.10 + RAND()*0.15);
                SET v_cot   = v_brut * 0.09;
                INSERT INTO fact_paie (employe_id, annee, mois, salaire_brut, primes, impots, cotisations, salaire_net)
                VALUES (v_emp, YEAR(d), MONTH(d), ROUND(v_brut,2), ROUND(v_prime,2),
                        ROUND(v_impot,2), ROUND(v_cot,2), ROUND(v_brut - v_impot - v_cot, 2));
            END IF;
            SET v_emp = v_emp + 1;
        END WHILE;
        SET d = DATE_ADD(d, INTERVAL 1 MONTH);
    END WHILE;
END //
DELIMITER ;
CALL gen_paie();

-- Absences
DROP PROCEDURE IF EXISTS gen_absences;
DELIMITER //
CREATE PROCEDURE gen_absences()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    DECLARE i INT;
    DECLARE v_emp INT;
    DECLARE v_type ENUM('MALADIE','CONGE_PAYE','AUTORISATION','CONGE_MATERNITE','INJUSTIFIEE');
    DECLARE v_duree INT;
    DECLARE v_debut DATE;
    TRUNCATE fact_absence;
    WHILE d <= '2027-12-31' DO
        IF FLOOR(RAND()*5) = 0 THEN
            SET v_emp   = 1 + FLOOR(RAND()*120);
            SET v_type  = ELT(1+FLOOR(RAND()*10), 'MALADIE','MALADIE','CONGE_PAYE','CONGE_PAYE',
                              'CONGE_PAYE','AUTORISATION','AUTORISATION','CONGE_MATERNITE','INJUSTIFIEE','INJUSTIFIEE');
            SET v_duree = CASE v_type
                WHEN 'MALADIE' THEN 1 + FLOOR(RAND()*10)
                WHEN 'CONGE_PAYE' THEN 2 + FLOOR(RAND()*12)
                WHEN 'AUTORISATION' THEN 1 + FLOOR(RAND()*2)
                WHEN 'CONGE_MATERNITE' THEN 60 + FLOOR(RAND()*30)
                ELSE 1 END;
            SET v_debut = d;
            INSERT INTO fact_absence (employe_id, date_debut, date_fin, type_absence, motif)
            VALUES (v_emp, v_debut, DATE_ADD(v_debut, INTERVAL v_duree-1 DAY), v_type, NULL);
        END IF;
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
CALL gen_absences();

-- Formations
DROP PROCEDURE IF EXISTS gen_formations;
DELIMITER //
CREATE PROCEDURE gen_formations()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    DECLARE i INT DEFAULT 0;
    DECLARE v_emp INT;
    DECLARE v_type ENUM('INTERNE','EXTERNE','E_LEARNING');
    DECLARE v_theme VARCHAR(120);
    DECLARE v_duree INT;
    DECLARE v_cout DECIMAL(10,2);
    TRUNCATE fact_formation;
    WHILE d <= '2027-12-31' DO
        SET i = 0;
        WHILE i < 2 DO
            SET v_emp   = 1 + FLOOR(RAND()*120);
            SET v_type  = ELT(1+FLOOR(RAND()*3), 'INTERNE','EXTERNE','E_LEARNING');
            SET v_theme = ELT(1+FLOOR(RAND()*8),
                'Excel avancé pour la finance','Leadership et management',
                'Power BI et analyse de données','Sécurité au travail',
                'Service client de qualité','Gestion de projet agile',
                'Comptabilité analytique','Négociation commerciale');
            SET v_duree = 4 + FLOOR(RAND()*30);
            SET v_cout  = CASE v_type
                WHEN 'INTERNE' THEN 100 + RAND()*800
                WHEN 'EXTERNE' THEN 500 + RAND()*2500
                ELSE 50 + RAND()*300 END;
            INSERT INTO fact_formation (employe_id, date_formation, theme, type, duree_heures, cout)
            VALUES (v_emp, d, v_theme, v_type, v_duree, ROUND(v_cout,2));
            SET i = i + 1;
        END WHILE;
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
CALL gen_formations();

-- ============================================================
--  VUES ANALYTIQUES POUR POWER BI
-- ============================================================

-- Effectif par département
CREATE OR REPLACE VIEW v_effectif AS
SELECT
    e.employe_id,
    CONCAT(e.prenom, ' ', e.nom) AS employe,
    e.genre,
    e.poste,
    e.contrat,
    e.salaire_base,
    e.statut,
    e.date_embauche,
    TIMESTAMPDIFF(YEAR, e.date_embauche, '2027-12-31') AS anciennete_annees,
    d.nom_departement AS departement,
    d.directeur,
    d.localisation
FROM dim_employe e
JOIN dim_departement d ON d.departement_id = e.departement_id;

-- Masse salariale mensuelle
CREATE OR REPLACE VIEW v_paie_mensuelle AS
SELECT p.annee, p.mois,
       d.nom_departement AS departement,
       COUNT(*) AS nb_employes_payes,
       SUM(p.salaire_brut) AS masse_salariale_brute,
       SUM(p.primes)       AS total_primes,
       SUM(p.impots)       AS total_impots,
       SUM(p.cotisations)  AS total_cotisations,
       SUM(p.salaire_net)  AS masse_salariale_nette
FROM fact_paie p
JOIN dim_employe e ON e.employe_id = p.employe_id
JOIN dim_departement d ON d.departement_id = e.departement_id
GROUP BY p.annee, p.mois, d.nom_departement;

-- Absences par mois
CREATE OR REPLACE VIEW v_absences_mensuelles AS
SELECT
    YEAR(a.date_debut) AS annee,
    MONTH(a.date_debut) AS mois,
    a.type_absence,
    d.nom_departement AS departement,
    COUNT(*) AS nb_absences,
    SUM(DATEDIFF(a.date_fin, a.date_debut) + 1) AS jours_perdus
FROM fact_absence a
JOIN dim_employe e ON e.employe_id = a.employe_id
JOIN dim_departement d ON d.departement_id = e.departement_id
GROUP BY YEAR(a.date_debut), MONTH(a.date_debut), a.type_absence, d.nom_departement;

-- Formations
CREATE OR REPLACE VIEW v_formations AS
SELECT
    f.formation_id,
    f.date_formation,
    YEAR(f.date_formation) AS annee,
    MONTH(f.date_formation) AS mois,
    CONCAT(e.prenom, ' ', e.nom) AS employe,
    d.nom_departement AS departement,
    f.theme,
    f.type,
    f.duree_heures,
    f.cout
FROM fact_formation f
JOIN dim_employe e ON e.employe_id = f.employe_id
JOIN dim_departement d ON d.departement_id = e.departement_id;

-- Budget RH vs réalisé
CREATE OR REPLACE VIEW v_budget_rh_vs_reel AS
SELECT
    d.departement_id,
    d.nom_departement,
    d.budget_annuel,
    YEAR(p.annee) AS annee,
    SUM(p.masse_salariale_brute) AS realise
FROM dim_departement d
JOIN v_paie_mensuelle p ON p.departement = d.nom_departement
GROUP BY d.departement_id, d.nom_departement, d.budget_annuel, YEAR(p.annee);

-- Statistiques
SELECT '=== STATISTIQUES RH ===' AS info;
SELECT CONCAT('Employés : ', COUNT(*)) AS stats FROM dim_employe;
SELECT CONCAT('Lignes de paie : ', COUNT(*)) AS stats FROM fact_paie;
SELECT CONCAT('Absences : ', COUNT(*)) AS stats FROM fact_absence;
SELECT CONCAT('Formations : ', COUNT(*)) AS stats FROM fact_formation;
SELECT CONCAT('Masse salariale brute totale : ', FORMAT(SUM(salaire_brut),2), ' USD') AS stats FROM fact_paie;