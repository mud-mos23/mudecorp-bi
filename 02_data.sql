-- ============================================================
--  BI FINANCE - Génération de données fictives
--  Période : 01/01/2024 -> 31/12/2027 (48 mois)
--  ~2 800 transactions, 65 clients, budget mensuel par compte
-- ============================================================

USE bi_finance;

-- Réinitialisation (ordre FK)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE fact_transaction;
TRUNCATE fact_budget;
TRUNCATE dim_client;
TRUNCATE dim_compte;
TRUNCATE dim_date;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. Calendrier
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS gen_calendrier;
DELIMITER //
CREATE PROCEDURE gen_calendrier()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    TRUNCATE dim_date;
    WHILE d <= '2027-12-31' DO
        INSERT INTO dim_date (date_id, annee, mois, nom_mois, trimestre, jour_semaine, est_weekend)
        VALUES (d, YEAR(d), MONTH(d),
                ELT(MONTH(d),'Janvier','Février','Mars','Avril','Mai','Juin',
                              'Juillet','Août','Septembre','Octobre','Novembre','Décembre'),
                QUARTER(d),
                ELT(DAYOFWEEK(d),'Dimanche','Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'),
                IF(DAYOFWEEK(d) IN (1,7),1,0));
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
CALL gen_calendrier();

-- ------------------------------------------------------------
-- 2. Clients
-- ------------------------------------------------------------
INSERT INTO dim_client (nom_client, secteur, region, ville, date_creation, segment) VALUES
('Congo Telecom SA',        'Telecom',        'Kinshasa',     'Kinshasa',     '2021-03-12', 'Grand Compte'),
('Banque Baobab',           'Finance',        'Kinshasa',     'Kinshasa',     '2020-01-20', 'Grand Compte'),
('AgriKivu Coop',           'Agro',           'Nord-Kivu',    'Goma',         '2022-05-08', 'PME'),
('Clinique MediPlus',       'Sante',          'Lubumbashi',   'Lubumbashi',   '2021-09-15', 'PME'),
('TransKivu Logistique',    'Transport',      'Nord-Kivu',    'Goma',         '2020-07-02', 'Grand Compte'),
('Ecole La Fontaine',       'Education',      'Kinshasa',     'Kinshasa',     '2023-01-10', 'PME'),
('Hotel Lumumba Palace',    'Hotellerie',     'Kinshasa',     'Kinshasa',     '2019-11-25', 'Grand Compte'),
('Minoterie du Kongo',      'Industrie',      'Bas-Congo',    'Matadi',       '2021-02-14', 'Grand Compte'),
('SuperMarché Tropicana',   'Commerce',       'Lubumbashi',   'Lubumbashi',   '2022-08-30', 'PME'),
('Agence Media7',           'Media',          'Kinshasa',     'Kinshasa',     '2020-04-18', 'PME'),
('Brewery Virunga',         'Industrie',      'Nord-Kivu',    'Goma',         '2018-06-22', 'Grand Compte'),
('Pharmacie Uzima',         'Sante',          'Sud-Kivu',     'Bukavu',       '2022-02-09', 'PME'),
('Ferme de la Nsele',       'Agro',           'Kinshasa',     'Kinshasa',     '2021-10-05', 'PME'),
('Université CEPROMAD',     'Education',      'Kinshasa',     'Kinshasa',     '2019-08-19', 'Grand Compte'),
('TaxiBus Green',           'Transport',      'Kinshasa',     'Kinshasa',     '2023-03-27', 'PME'),
('Imprimerie CongoPress',   'Media',          'Kinshasa',     'Kinshasa',     '2020-12-11', 'PME'),
('Construction Bati-Congo','BTP',            'Kinshasa',     'Kinshasa',     '2021-06-01', 'Grand Compte'),
('Cimenterie Kimpese',      'Industrie',      'Bas-Congo',    'Kikwit',       '2019-03-08', 'Grand Compte'),
('Cabinet JurisLex',        'Services',       'Kinshasa',     'Kinshasa',     '2022-04-26', 'PME'),
('EcoCarburant SARL',       'Energie',        'Kinshasa',     'Kinshasa',     '2020-09-13', 'Grand Compte'),
('Poissonnerie du Lac',     'Agro',           'Sud-Kivu',     'Bukavu',       '2023-02-16', 'PME'),
('Fabrique Textile Kivu',   'Industrie',      'Nord-Kivu',    'Goma',         '2021-11-07', 'PME'),
('Agence Immobilière KIN',  'Immobilier',     'Kinshasa',     'Kinshasa',     '2018-10-29', 'Grand Compte'),
('Clinique Dentaire Smile', 'Sante',          'Kinshasa',     'Kinshasa',     '2022-07-21', 'PME'),
('Logistique Port Matadi',  'Transport',      'Bas-Congo',    'Matadi',       '2020-02-06', 'Grand Compte'),
('Supermarché CityMarket',  'Commerce',       'Kinshasa',     'Kinshasa',     '2021-05-17', 'PME'),
('Microfinance SIKA',       'Finance',        'Kinshasa',     'Kinshasa',     '2020-08-24', 'PME'),
('Boulangerie du Matin',    'Commerce',       'Kinshasa',     'Kinshasa',     '2023-05-12', 'PME'),
('Electricité Kivu Power',  'Energie',        'Nord-Kivu',    'Goma',         '2019-12-03', 'Grand Compte'),
('École Technique Mabanga', 'Education',      'Lubumbashi',   'Lubumbashi',   '2022-09-28', 'PME'),
('Transport Katanga',       'Transport',      'Lubumbashi',   'Lubumbashi',   '2021-01-15', 'PME'),
('Société Minière Kazibaze','Industrie',      'Lubumbashi',   'Kolwezi',      '2018-05-04', 'Grand Compte'),
('Hôtel Bel Air',           'Hotellerie',     'Kinshasa',     'Kinshasa',     '2022-11-19', 'PME'),
('Safari Lodge Virunga',    'Tourisme',       'Nord-Kivu',    'Goma',         '2021-07-30', 'PME'),
('Restaurant Saveurs d''Af','Commerce',       'Kinshasa',     'Kinshasa',     '2023-04-03', 'PME'),
('Cabinet Audit KPM DRC',   'Services',       'Kinshasa',     'Kinshasa',     '2019-09-09', 'Grand Compte'),
('AgroTrading Bas-Congo',   'Agro',           'Bas-Congo',    'Matadi',       '2020-10-27', 'PME'),
('Clinique Mère-Enfant',    'Sante',          'Kinshasa',     'Kinshasa',     '2021-12-14', 'PME'),
('Usine Plastique KIN',     'Industrie',      'Kinshasa',     'Kinshasa',     '2019-02-11', 'Grand Compte'),
('Distillerie du Fleuve',   'Industrie',      'Kinshasa',     'Kinshasa',     '2018-08-07', 'Grand Compte'),
('Groupe Presse Lumière',   'Media',          'Lubumbashi',   'Lubumbashi',   '2020-06-23', 'PME'),
('Ferme Avicole Étoile',    'Agro',           'Kinshasa',     'Kinshasa',     '2022-03-31', 'PME'),
('Société BTP Matadi',      'BTP',            'Bas-Congo',    'Matadi',       '2021-08-09', 'PME'),
('Compagnie Aérienne DCong','Transport',      'Kinshasa',     'Kinshasa',     '2019-04-16', 'Grand Compte'),
('Banque Intérim',          'Finance',        'Kinshasa',     'Kinshasa',     '2020-11-02', 'Grand Compte'),
('Réseau Pharmacies Congo', 'Sante',          'Kinshasa',     'Kinshasa',     '2021-03-19', 'Grand Compte'),
('Supermarché Kongo Market','Commerce',       'Bas-Congo',    'Matadi',       '2022-01-25', 'PME'),
('Université Saint Augustin','Education',     'Lubumbashi',   'Lubumbashi',   '2019-07-07', 'PME'),
('Hôtel Riviera Goma',      'Hotellerie',     'Nord-Kivu',    'Goma',         '2020-05-05', 'PME'),
('Cabinet Fiscal Expertis', 'Services',       'Kinshasa',     'Kinshasa',     '2021-04-13', 'PME'),
('AgroSécurité Sarl',       'Agro',           'Sud-Kivu',     'Bukavu',       '2022-06-06', 'PME'),
('Câblerie du Congo',       'Industrie',      'Kinshasa',     'Kinshasa',     '2018-12-28', 'Grand Compte'),
('Pharma Express Bukavu',   'Sante',          'Sud-Kivu',     'Bukavu',       '2021-09-21', 'PME'),
('Transport Fleuve Congo',  'Transport',      'Kinshasa',     'Kinshasa',     '2020-03-09', 'PME'),
('Brasserie du Kasaï',      'Industrie',      'Kinshasa',     'Mbuji-Mayi',    '2019-10-30', 'PME'),
('École Internationale KIN','Education',      'Kinshasa',     'Kinshasa',     '2023-01-04', 'PME'),
('Mines d''Étain Kamituga', 'Industrie',      'Sud-Kivu',     'Bukavu',       '2018-09-17', 'Grand Compte'),
('Coopérative Café Kivu',   'Agro',           'Sud-Kivu',     'Bukavu',       '2021-06-28', 'PME'),
('Hôtel Karibu Lubumbashi', 'Hotellerie',     'Lubumbashi',   'Lubumbashi',   '2020-07-11', 'PME'),
('Papeterie EcolePlus',     'Commerce',       'Kinshasa',     'Kinshasa',     '2022-05-15', 'PME'),
('Gaz & Pétrole Congo',     'Energie',        'Kinshasa',     'Kinshasa',     '2019-05-20', 'Grand Compte'),
('Cabinet d''Architecture', 'BTP',            'Kinshasa',     'Kinshasa',     '2021-10-08', 'PME'),
('Ferme Laitière Kiwa',     'Agro',           'Sud-Kivu',     'Bukavu',       '2022-08-22', 'PME'),
('Société Pêche Maritime',  'Agro',           'Bas-Congo',    'Matadi',       '2021-11-16', 'PME'),
('Kiosque Numérique KIN',   'Telecom',        'Kinshasa',     'Kinshasa',     '2023-06-19', 'PME');

-- ------------------------------------------------------------
-- 3. Plan comptable
-- ------------------------------------------------------------
INSERT INTO dim_compte (code, nom_compte, type, groupe) VALUES
('701','Ventes de produits',          'REVENU',  'Ventes'),
('702','Prestations de services',     'REVENU',  'Services'),
('703','Abonnements et maintenance',  'REVENU',  'Abonnements'),
('704','Honoraires de conseil',       'REVENU',  'Services'),
('705','Ventes à l''export',          'REVENU',  'Ventes'),
('601','Salaires et charges sociales','DEPENSE', 'Personnel'),
('602','Loyers et immobilier',        'DEPENSE', 'Immobilier'),
('603','Marketing et publicité',      'DEPENSE', 'Marketing'),
('604','Fournitures et consommables', 'DEPENSE', 'Exploitation'),
('605','Énergie et eau',              'DEPENSE', 'Exploitation'),
('606','Transport et logistique',     'DEPENSE', 'Exploitation'),
('607','Assurances',                  'DEPENSE', 'Administration'),
('608','Impôts et taxes',             'DEPENSE', 'Administration'),
('609','Informatique et logiciels',   'DEPENSE', 'Exploitation'),
('610','Intérêts et frais bancaires', 'DEPENSE', 'Finance');

-- ------------------------------------------------------------
-- 4. Transactions (procédure de génération)
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS gen_transactions;
DELIMITER //
CREATE PROCEDURE gen_transactions()
BEGIN
    DECLARE d DATE;
    DECLARE n INT;
    DECLARE i INT;
    DECLARE v_client INT;
    DECLARE v_compte INT;
    DECLARE v_montant DECIMAL(12,2);
    DECLARE v_date DATE;
    DECLARE v_mode ENUM('VIREMENT','CARTE','ESPECES','MOBILE_MONEY','CHEQUE');
    DECLARE v_statut ENUM('VALIDE','EN_ATTENTE','ANNULE');
    DECLARE v_desc VARCHAR(150);

    TRUNCATE fact_transaction;
    SET d = '2024-01-01';

    WHILE d <= '2027-12-31' DO
        -- REVENUS : 3 à 8 transactions par jour
        SET n = 3 + FLOOR(RAND()*6);
        SET i = 0;
        WHILE i < n DO
            SET v_compte = 1 + FLOOR(RAND()*5);           -- comptes 701..705
            SET v_client = 1 + FLOOR(RAND()*65);
            -- montant selon le type de revenu
            SET v_montant = CASE v_compte
                WHEN 1 THEN 500  + RAND()*7000         -- produits
                WHEN 2 THEN 200  + RAND()*2000         -- services
                WHEN 3 THEN 50   + RAND()*400          -- abonnements
                WHEN 4 THEN 200  + RAND()*1000         -- conseil
                ELSE 300  + RAND()*1200 END;           -- export
            SET v_montant = ROUND(v_montant, 2);
            SET v_date = DATE_ADD(d, INTERVAL FLOOR(RAND()*86400) SECOND);
            SET v_mode = ELT(1+FLOOR(RAND()*5), 'VIREMENT','CARTE','ESPECES','MOBILE_MONEY','CHEQUE');
            SET v_statut = ELT(1+FLOOR(RAND()*20), 'ANNULE','EN_ATTENTE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE');
            IF v_statut <> 'ANNULE' THEN
                INSERT INTO fact_transaction (date_tx, client_id, compte_id, montant, mode_paiement, statut, description)
                VALUES (v_date, v_client, v_compte, v_montant, v_mode, v_statut,
                        CONCAT('Facture F-', YEAR(v_date), '-', LPAD(FLOOR(RAND()*99999)+1,5,'0')));
            END IF;
            SET i = i + 1;
        END WHILE;

        -- DEPENSES : 1 à 4 transactions par jour
        SET n = 1 + FLOOR(RAND()*4);
        SET i = 0;
        WHILE i < n DO
            SET v_compte = 6 + FLOOR(RAND()*10);          -- comptes 601..610
            SET v_montant = CASE v_compte
                WHEN 6  THEN 1200 + RAND()*20000         -- salaires
                WHEN 7  THEN 250  + RAND()*4500          -- loyers
                WHEN 8  THEN 100  + RAND()*8000          -- marketing
                WHEN 9  THEN 50   + RAND()*2500          -- fournitures
                WHEN 10 THEN 80   + RAND()*2000          -- énergie
                WHEN 11 THEN 150  + RAND()*6000          -- transport
                WHEN 12 THEN 100  + RAND()*3000          -- assurance
                WHEN 13 THEN 200  + RAND()*5000          -- impôts
                WHEN 14 THEN 150  + RAND()*4500          -- informatique
                ELSE 20 + RAND()*800 END;                -- banques
            SET v_montant = ROUND(v_montant, 2);
            SET v_date = DATE_ADD(d, INTERVAL FLOOR(RAND()*86400) SECOND);
            SET v_mode = ELT(1+FLOOR(RAND()*4), 'VIREMENT','CARTE','ESPECES','MOBILE_MONEY');
            SET v_statut = ELT(1+FLOOR(RAND()*20), 'ANNULE','EN_ATTENTE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE',
                                                  'VALIDE','VALIDE','VALIDE','VALIDE','VALIDE');
            IF v_statut <> 'ANNULE' THEN
                INSERT INTO fact_transaction (date_tx, client_id, compte_id, montant, mode_paiement, statut, description)
                VALUES (v_date, NULL, v_compte, v_montant, v_mode, v_statut,
                        CONCAT('Dépense ', (SELECT nom_compte FROM dim_compte WHERE compte_id = v_compte)));
            END IF;
            SET i = i + 1;
        END WHILE;
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
CALL gen_transactions();

-- ------------------------------------------------------------
-- 5. Budget mensuel par compte (2024 -> 2027)
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS gen_budget;
DELIMITER //
CREATE PROCEDURE gen_budget()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    DECLARE v_compte INT DEFAULT 1;
    DECLARE v_montant DECIMAL(12,2);
    TRUNCATE fact_budget;
    WHILE d <= '2027-12-01' DO
        SET v_compte = 1;
        WHILE v_compte <= 15 DO
            SET v_montant = CASE v_compte
                WHEN 1  THEN 600000 WHEN 2 THEN 200000 WHEN 3 THEN 40000
                WHEN 4  THEN 120000 WHEN 5 THEN 150000 WHEN 6 THEN 85000
                WHEN 7  THEN 20000  WHEN 8 THEN 35000  WHEN 9 THEN 18000
                WHEN 10 THEN 12000  WHEN 11 THEN 25000 WHEN 12 THEN 10000
                WHEN 13 THEN 22000  WHEN 14 THEN 16000 WHEN 15 THEN 5000
            END;
            -- petite variation saisonnière +/- 15%
            SET v_montant = v_montant * (0.85 + RAND()*0.30);
            INSERT INTO fact_budget (annee, mois, compte_id, montant_budget)
            VALUES (YEAR(d), MONTH(d), v_compte, ROUND(v_montant,2));
            SET v_compte = v_compte + 1;
        END WHILE;
        SET d = DATE_ADD(d, INTERVAL 1 MONTH);
    END WHILE;
END //
DELIMITER ;
CALL gen_budget();

-- ============================================================
-- 6. VUES ANALYTIQUES POUR POWER BI
-- ============================================================

-- Vue flux financiers complets (revenus + dépenses)
CREATE OR REPLACE VIEW v_flux_financier AS
SELECT
    t.tx_id,
    t.date_tx,
    dd.annee,
    dd.mois,
    dd.nom_mois,
    dd.trimestre,
    c.code           AS code_compte,
    c.nom_compte     AS compte,
    c.groupe         AS groupe,
    c.type           AS type_flux,
    cl.nom_client    AS client,
    cl.secteur       AS secteur,
    cl.region        AS region,
    cl.ville         AS ville,
    cl.segment       AS segment,
    t.montant,
    t.mode_paiement,
    t.statut,
    t.description
FROM fact_transaction t
JOIN dim_date dd     ON dd.date_id = DATE(t.date_tx)
JOIN dim_compte c    ON c.compte_id = t.compte_id
LEFT JOIN dim_client cl ON cl.client_id = t.client_id;

-- Vue revenus mensuels
CREATE OR REPLACE VIEW v_revenus_mensuels AS
SELECT annee, mois, nom_mois, groupe, compte,
       COUNT(*) AS nb_transactions, SUM(montant) AS total
FROM v_flux_financier
WHERE type_flux = 'REVENU' AND statut = 'VALIDE'
GROUP BY annee, mois, nom_mois, groupe, compte;

-- Vue dépenses mensuelles
CREATE OR REPLACE VIEW v_depenses_mensuelles AS
SELECT annee, mois, nom_mois, groupe, compte,
       COUNT(*) AS nb_transactions, SUM(montant) AS total
FROM v_flux_financier
WHERE type_flux = 'DEPENSE' AND statut = 'VALIDE'
GROUP BY annee, mois, nom_mois, groupe, compte;

-- Vue budget vs réalisé
CREATE OR REPLACE VIEW v_budget_vs_reel AS
SELECT
    b.annee, b.mois,
    c.nom_compte AS compte, c.groupe, c.type AS type_flux,
    SUM(b.montant_budget) AS budget,
    COALESCE(SUM(CASE WHEN t.statut = 'VALIDE' THEN t.montant END), 0) AS realise
FROM fact_budget b
JOIN dim_compte c ON c.compte_id = b.compte_id
LEFT JOIN fact_transaction t
       ON t.compte_id = b.compte_id
      AND YEAR(t.date_tx) = b.annee AND MONTH(t.date_tx) = b.mois
GROUP BY b.annee, b.mois, c.nom_compte, c.groupe, c.type;

-- Tables matérialisées pour Power BI (le connecteur MySQL lit mal les vues et types ENUM de MariaDB)
DROP TABLE IF EXISTS mv_flux_financier;
CREATE TABLE mv_flux_financier AS
SELECT
    tx_id, date_tx, annee, mois, nom_mois, trimestre,
    code_compte, compte, groupe,
    CAST(type_flux AS CHAR) AS type_flux,
    client, secteur, region, ville, segment,
    montant,
    CAST(mode_paiement AS CHAR) AS mode_paiement,
    CAST(statut AS CHAR) AS statut,
    description
FROM v_flux_financier;

DROP TABLE IF EXISTS mv_budget_vs_reel;
CREATE TABLE mv_budget_vs_reel AS
SELECT
    annee, mois, compte, groupe,
    CAST(type_flux AS CHAR) AS type_flux,
    CAST(budget AS DECIMAL(18,2)) AS budget,
    CAST(realise AS DECIMAL(18,2)) AS realise
FROM v_budget_vs_reel;

-- Statistiques globales
SELECT '=== STATISTIQUES DE LA BASE ===' AS info;
SELECT CONCAT('Transactions : ', COUNT(*)) AS stats FROM fact_transaction;
SELECT CONCAT('Clients : ', COUNT(*)) AS stats FROM dim_client;
SELECT CONCAT('Revenus totaux : ', FORMAT(SUM(CASE WHEN type_flux='REVENU' AND statut='VALIDE' THEN montant END),2), ' USD') AS stats FROM v_flux_financier;
SELECT CONCAT('Dépenses totales : ', FORMAT(SUM(CASE WHEN type_flux='DEPENSE' AND statut='VALIDE' THEN montant END),2), ' USD') AS stats FROM v_flux_financier;