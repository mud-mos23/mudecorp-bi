-- ============================================================
--  BI FINANCE - Schéma de base de données
--  Entreprise fictive : "Mudecorp International SA"
--  Base : bi_finance | Moteur : MariaDB / MySQL
-- ============================================================

DROP DATABASE IF EXISTS bi_finance;
CREATE DATABASE bi_finance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bi_finance;

-- ------------------------------------------------------------
-- 1. Table Calendrier (dim_date)
-- ------------------------------------------------------------
CREATE TABLE dim_date (
    date_id        DATE PRIMARY KEY,
    annee          SMALLINT NOT NULL,
    mois           TINYINT  NOT NULL,
    nom_mois       VARCHAR(20) NOT NULL,
    trimestre      TINYINT  NOT NULL,
    jour_semaine   VARCHAR(15) NOT NULL,
    est_weekend    TINYINT  NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Clients (dim_client)
-- ------------------------------------------------------------
CREATE TABLE dim_client (
    client_id       INT PRIMARY KEY AUTO_INCREMENT,
    nom_client      VARCHAR(100) NOT NULL,
    secteur         VARCHAR(50) NOT NULL,
    region          VARCHAR(50) NOT NULL,
    ville           VARCHAR(50) NOT NULL,
    date_creation   DATE NOT NULL,
    segment         VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Plan comptable (dim_compte)
-- ------------------------------------------------------------
CREATE TABLE dim_compte (
    compte_id   INT PRIMARY KEY AUTO_INCREMENT,
    code        VARCHAR(10) NOT NULL,
    nom_compte  VARCHAR(80) NOT NULL,
    type        ENUM('REVENU','DEPENSE') NOT NULL,
    groupe      VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Transactions financières (fact_transaction)
-- ------------------------------------------------------------
CREATE TABLE fact_transaction (
    tx_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_tx        DATE NOT NULL,
    client_id      INT NULL,
    compte_id      INT NOT NULL,
    montant        DECIMAL(12,2) NOT NULL,
    mode_paiement  ENUM('VIREMENT','CARTE','ESPECES','MOBILE_MONEY','CHEQUE') NOT NULL,
    statut         ENUM('VALIDE','EN_ATTENTE','ANNULE') NOT NULL,
    description    VARCHAR(150) NULL,
    CONSTRAINT fk_tx_client FOREIGN KEY (client_id) REFERENCES dim_client(client_id),
    CONSTRAINT fk_tx_compte FOREIGN KEY (compte_id) REFERENCES dim_compte(compte_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Budget (fact_budget)
-- ------------------------------------------------------------
CREATE TABLE fact_budget (
    budget_id     INT PRIMARY KEY AUTO_INCREMENT,
    annee         SMALLINT NOT NULL,
    mois          TINYINT NOT NULL,
    compte_id     INT NOT NULL,
    montant_budget DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_budget_compte FOREIGN KEY (compte_id) REFERENCES dim_compte(compte_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Index pour les performances Power BI
-- ------------------------------------------------------------
CREATE INDEX idx_tx_date    ON fact_transaction(date_tx);
CREATE INDEX idx_tx_compte  ON fact_transaction(compte_id);
CREATE INDEX idx_tx_client  ON fact_transaction(client_id);
CREATE INDEX idx_budget_ym  ON fact_budget(annee, mois);