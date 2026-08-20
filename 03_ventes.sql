-- ============================================================
--  BI VENTES - Schéma + données fictives
--  Entreprise : "Mudecorp International SA"
--  Base : bi_ventes | Période : 01/01/2024 -> 31/12/2027
--  Contenu : produits, vendeurs, commandes, lignes de vente, stock
-- ============================================================

DROP DATABASE IF EXISTS bi_ventes;
CREATE DATABASE bi_ventes CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bi_ventes;

-- ------------------------------------------------------------
-- 1. Produits
-- ------------------------------------------------------------
CREATE TABLE dim_produit (
    produit_id     INT PRIMARY KEY AUTO_INCREMENT,
    code_produit   VARCHAR(20) NOT NULL,
    nom_produit    VARCHAR(100) NOT NULL,
    categorie      VARCHAR(50) NOT NULL,
    sous_categorie VARCHAR(50) NOT NULL,
    prix_unitaire  DECIMAL(10,2) NOT NULL,
    cout_unitaire  DECIMAL(10,2) NOT NULL,
    fournisseur    VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Vendeurs
-- ------------------------------------------------------------
CREATE TABLE dim_vendeur (
    vendeur_id    INT PRIMARY KEY AUTO_INCREMENT,
    nom_vendeur   VARCHAR(80) NOT NULL,
    region        VARCHAR(50) NOT NULL,
    ville         VARCHAR(50) NOT NULL,
    date_embauche DATE NOT NULL,
    equipe        VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Clients
-- ------------------------------------------------------------
CREATE TABLE dim_client (
    client_id    INT PRIMARY KEY AUTO_INCREMENT,
    nom_client   VARCHAR(100) NOT NULL,
    secteur      VARCHAR(50) NOT NULL,
    region       VARCHAR(50) NOT NULL,
    ville        VARCHAR(50) NOT NULL,
    segment      VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Commandes (en-tête)
-- ------------------------------------------------------------
CREATE TABLE fact_commande (
    commande_id   INT PRIMARY KEY AUTO_INCREMENT,
    date_commande DATE NOT NULL,
    client_id     INT NOT NULL,
    vendeur_id    INT NOT NULL,
    canal         ENUM('DIRECT','EN_LIGNE','GROSSISTE','PARTENAIRE') NOT NULL,
    statut        ENUM('LIVREE','EXPEDIEE','EN_ATTENTE','ANNULEE') NOT NULL,
    montant_total DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_cmd_client  FOREIGN KEY (client_id)  REFERENCES dim_client(client_id),
    CONSTRAINT fk_cmd_vendeur FOREIGN KEY (vendeur_id) REFERENCES dim_vendeur(vendeur_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Lignes de commande (détail)
-- ------------------------------------------------------------
CREATE TABLE fact_ligne_commande (
    ligne_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
    commande_id  INT NOT NULL,
    produit_id   INT NOT NULL,
    quantite     INT NOT NULL,
    prix_unitaire_vente DECIMAL(10,2) NOT NULL,
    remise_pct   DECIMAL(5,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_lc_cmd     FOREIGN KEY (commande_id) REFERENCES fact_commande(commande_id),
    CONSTRAINT fk_lc_produit FOREIGN KEY (produit_id)  REFERENCES dim_produit(produit_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. Stock (mouvements)
-- ------------------------------------------------------------
CREATE TABLE fact_stock (
    mouvement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    produit_id   INT NOT NULL,
    date_mouvement DATE NOT NULL,
    type         ENUM('ENTREE','SORTIE','AJUSTEMENT') NOT NULL,
    quantite     INT NOT NULL,
    CONSTRAINT fk_stk_produit FOREIGN KEY (produit_id) REFERENCES dim_produit(produit_id)
) ENGINE=InnoDB;

CREATE INDEX idx_cmd_date    ON fact_commande(date_commande);
CREATE INDEX idx_cmd_client  ON fact_commande(client_id);
CREATE INDEX idx_lc_produit  ON fact_ligne_commande(produit_id);
CREATE INDEX idx_stk_date    ON fact_stock(date_mouvement);

-- ============================================================
--  DONNÉES
-- ============================================================

-- Produits
INSERT INTO dim_produit (code_produit, nom_produit, categorie, sous_categorie, prix_unitaire, cout_unitaire, fournisseur) VALUES
('ELC-001','Smartphone Neo X1',      'Électronique','Téléphones',      499.00, 310.00,'Shenzhen Tech'),
('ELC-002','Ordinateur PortPro 14',  'Électronique','Ordinateurs',     899.00, 590.00,'Taiwan Computing'),
('ELC-003','Tablette TabMini',       'Électronique','Tablettes',       249.00, 150.00,'Shenzhen Tech'),
('ELC-004','Casque AudioMax',        'Électronique','Audio',           129.00, 72.00,'Vietnam Audio'),
('ELC-005','Écran ViewPro 27"',      'Électronique','Écrans',          349.00, 220.00,'Taiwan Computing'),
('ELE-001','Réfrigérateur FrostFree', 'Électroménager','Froid',         699.00, 430.00,'Korea Appliances'),
('ELE-002','Lave-linge TurboClean',   'Électroménager','Lavage',        549.00, 340.00,'Korea Appliances'),
('ELE-003','Cuisinière GazPro 4',     'Électroménager','Cuisson',       389.00, 240.00,'Turkey Home'),
('ELE-004','Micro-ondes QuickHeat',   'Électroménager','Cuisson',       149.00, 88.00,'Turkey Home'),
('ELE-005','Climatiseur CoolAir 2.5', 'Électroménager','Climatisation', 799.00, 500.00,'China Climate'),
('MOB-001','Canapé 3 places Milano', 'Mobilier','Salon',               899.00, 520.00,'Local Artisan'),
('MOB-002','Table à manger 6 pers.',  'Mobilier','Salle à manger',      459.00, 270.00,'Local Artisan'),
('MOB-003','Lit double BoisMassif',   'Mobilier','Chambre',             649.00, 380.00,'Local Artisan'),
('MOB-004','Armoire 4 portes',        'Mobilier','Chambre',             549.00, 330.00,'Local Artisan'),
('MOB-005','Bureau executive',        'Mobilier','Bureau',              379.00, 220.00,'Local Artisan'),
('TXT-001','Pagne wax 6 yards',       'Textile','Pagnes',                45.00, 22.00,'Africa Textiles'),
('TXT-002','Costume homme coupe',     'Textile','Vêtements',            189.00, 95.00,'Africa Textiles'),
('TXT-003','Chaussures cuir femme',   'Textile','Chaussures',            89.00, 45.00,'Ethiopia Leather'),
('TXT-004','Sac à main cousu main',   'Textile','Accessoires',            69.00, 32.00,'Local Artisan'),
('TXT-005','Tapis traditionnel 3m',   'Textile','Décoration',           159.00, 85.00,'Rwanda Crafts'),
('AGD-001','Sac riz 50kg',            'Agroalimentaire','Céréales',      58.00, 40.00,'FarmCo Congo'),
('AGD-002','Huile de palme 20L',      'Agroalimentaire','Huiles',        75.00, 52.00,'AgriPalme'),
('AGD-003','Café arabica 1kg',        'Agroalimentaire','Boissons',      22.00, 11.00,'Coop Kivu'),
('AGD-004','Cacao pur 5kg',           'Agroalimentaire','Cacao',         95.00, 62.00,'Coop Kivu'),
('AGD-005','Sucre de canne 25kg',     'Agroalimentaire','Sucres',        42.00, 28.00,'Sucrerie Kongo'),
('BTP-001','Ciment CPJ 42,5 (sac)',   'BTP','Matériaux',                 12.00, 8.00,'Cimenterie Kimpese'),
('BTP-002','Fer à béton 12mm (6m)',   'BTP','Matériaux',                 18.00, 12.00,'Aciérie Katanga'),
('BTP-003','Peinture acrylique 20L',  'BTP','Peintures',                120.00, 75.00,'Chimie Congo'),
('BTP-004','Carrelage 60x60 m²',      'BTP','Revêtements',               32.00, 20.00,'Ceramic Italia'),
('BTP-005','Tôle bac acier',          'BTP','Couverture',                27.00, 17.00,'Aciérie Katanga'),
('JOU-001','Poupée traditionnelle',   'Jouets','Poupées',                15.00, 6.00,'Local Artisan'),
('JOU-002','Voiture télécommandée',   'Jouets','Voitures',               45.00, 24.00,'Shenzhen Tech'),
('JOU-003','Lego City 500 pièces',    'Jouets','Construction',           65.00, 34.00,'Denmark Toys'),
('JOU-004','Ballon de foot officiel', 'Jouets','Sports',                 35.00, 16.00,'Pakistan Sports'),
('JOU-005','Trottinette enfant',      'Jouets','Mobilité',               79.00, 42.00,'Shenzhen Tech');

-- Vendeurs
INSERT INTO dim_vendeur (nom_vendeur, region, ville, date_embauche, equipe) VALUES
('Jean Kabila',    'Kinshasa',   'Kinshasa',   '2020-01-15','Équipe Kinshasa'),
('Marie Ilunga',   'Kinshasa',   'Kinshasa',   '2020-03-02','Équipe Kinshasa'),
('Patrick Tshiala','Kinshasa',   'Kinshasa',   '2021-06-10','Équipe Kinshasa'),
('Sarah Mwamba',   'Lubumbashi', 'Lubumbashi', '2020-09-22','Équipe Katanga'),
('Dieu-Merci K.',  'Lubumbashi', 'Lubumbashi', '2021-02-14','Équipe Katanga'),
('Grace Nkulu',    'Lubumbashi', 'Kolwezi',    '2022-04-05','Équipe Katanga'),
('Alain Bisimwa',  'Nord-Kivu',  'Goma',       '2020-11-18','Équipe Est'),
('Esther Uwimana', 'Sud-Kivu',   'Bukavu',     '2021-08-30','Équipe Est'),
('Fabrice Muhindo','Nord-Kivu',  'Goma',       '2022-01-25','Équipe Est'),
('Chantal Mbala',  'Bas-Congo',  'Matadi',     '2020-05-11','Équipe Ouest'),
('Olivier Kongo',  'Bas-Congo',  'Matadi',     '2021-10-07','Équipe Ouest'),
('Béatrice Luzolo','Kinshasa',   'Kinshasa',   '2023-03-16','Équipe Kinshasa');

-- Clients
INSERT INTO dim_client (nom_client, secteur, region, ville, segment) VALUES
('Congo Telecom SA','Telecom','Kinshasa','Kinshasa','Grand Compte'),
('Banque Baobab','Finance','Kinshasa','Kinshasa','Grand Compte'),
('Minoterie du Kongo','Industrie','Bas-Congo','Matadi','Grand Compte'),
('SuperMarché Tropicana','Commerce','Lubumbashi','Lubumbashi','PME'),
('Hotel Lumumba Palace','Hotellerie','Kinshasa','Kinshasa','Grand Compte'),
('Clinique MediPlus','Sante','Lubumbashi','Lubumbashi','PME'),
('Brewery Virunga','Industrie','Nord-Kivu','Goma','Grand Compte'),
('Université CEPROMAD','Education','Kinshasa','Kinshasa','Grand Compte'),
('École La Fontaine','Education','Kinshasa','Kinshasa','PME'),
('Ferme de la Nsele','Agro','Kinshasa','Kinshasa','PME'),
('Construction Bati-Congo','BTP','Kinshasa','Kinshasa','Grand Compte'),
('Cimenterie Kimpese','Industrie','Bas-Congo','Kikwit','Grand Compte'),
('Pharmacie Uzima','Sante','Sud-Kivu','Bukavu','PME'),
('TransKivu Logistique','Transport','Nord-Kivu','Goma','Grand Compte'),
('Agence Media7','Media','Kinshasa','Kinshasa','PME'),
('Cabinet JurisLex','Services','Kinshasa','Kinshasa','PME'),
('EcoCarburant SARL','Energie','Kinshasa','Kinshasa','Grand Compte'),
('Supermarché CityMarket','Commerce','Kinshasa','Kinshasa','PME'),
('Microfinance SIKA','Finance','Kinshasa','Kinshasa','PME'),
('Clinique Mère-Enfant','Sante','Kinshasa','Kinshasa','PME'),
('Distillerie du Fleuve','Industrie','Kinshasa','Kinshasa','Grand Compte'),
('Compagnie Aérienne DCong','Transport','Kinshasa','Kinshasa','Grand Compte'),
('Groupe Presse Lumière','Media','Lubumbashi','Lubumbashi','PME'),
('Réseau Pharmacies Congo','Sante','Kinshasa','Kinshasa','Grand Compte'),
('Université Saint Augustin','Education','Lubumbashi','Lubumbashi','PME'),
('Hôtel Bel Air','Hotellerie','Kinshasa','Kinshasa','PME'),
('Ferme Avicole Étoile','Agro','Kinshasa','Kinshasa','PME'),
('Société BTP Matadi','BTP','Bas-Congo','Matadi','PME'),
('Hôtel Riviera Goma','Hotellerie','Nord-Kivu','Goma','PME'),
('Safari Lodge Virunga','Tourisme','Nord-Kivu','Goma','PME'),
('Poissonnerie du Lac','Agro','Sud-Kivu','Bukavu','PME'),
('Brasserie du Kasaï','Industrie','Kinshasa','Mbuji-Mayi','PME'),
('Mines d''Étain Kamituga','Industrie','Sud-Kivu','Bukavu','Grand Compte'),
('Coopérative Café Kivu','Agro','Sud-Kivu','Bukavu','PME'),
('Hôtel Karibu Lubumbashi','Hotellerie','Lubumbashi','Lubumbashi','PME'),
('Gaz & Pétrole Congo','Energie','Kinshasa','Kinshasa','Grand Compte'),
('Cabinet d''Architecture','BTP','Kinshasa','Kinshasa','PME'),
('Ferme Laitière Kiwa','Agro','Sud-Kivu','Bukavu','PME'),
('Papeterie EcolePlus','Commerce','Kinshasa','Kinshasa','PME'),
('Kiosque Numérique KIN','Telecom','Kinshasa','Kinshasa','PME');

-- ============================================================
--  GÉNÉRATION : commandes + lignes + stock
-- ============================================================
DROP PROCEDURE IF EXISTS gen_ventes;
DELIMITER //
CREATE PROCEDURE gen_ventes()
BEGIN
    DECLARE d DATE DEFAULT '2024-01-01';
    DECLARE n_cmd INT;
    DECLARE i INT;
    DECLARE j INT;
    DECLARE v_client INT;
    DECLARE v_vendeur INT;
    DECLARE v_canal ENUM('DIRECT','EN_LIGNE','GROSSISTE','PARTENAIRE');
    DECLARE v_statut ENUM('LIVREE','EXPEDIEE','EN_ATTENTE','ANNULEE');
    DECLARE v_cmd_id INT;
    DECLARE v_produit INT;
    DECLARE v_qte INT;
    DECLARE v_remise DECIMAL(5,2);
    DECLARE v_prix DECIMAL(10,2);
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_nb_lignes INT;

    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE fact_ligne_commande;
    TRUNCATE fact_commande;
    TRUNCATE fact_stock;
    SET FOREIGN_KEY_CHECKS = 1;

    -- Stock initial (entrées)
    SET v_produit = 1;
    WHILE v_produit <= 35 DO
        INSERT INTO fact_stock (produit_id, date_mouvement, type, quantite)
        VALUES (v_produit, '2023-12-15', 'ENTREE', 200 + FLOOR(RAND()*800));
        SET v_produit = v_produit + 1;
    END WHILE;

    WHILE d <= '2027-12-31' DO
        -- 2 à 8 commandes par jour
        SET n_cmd = 2 + FLOOR(RAND()*7);
        SET i = 0;
        WHILE i < n_cmd DO
            SET v_client  = 1 + FLOOR(RAND()*40);
            SET v_vendeur = 1 + FLOOR(RAND()*12);
            SET v_canal   = ELT(1+FLOOR(RAND()*4), 'DIRECT','EN_LIGNE','GROSSISTE','PARTENAIRE');
            SET v_statut  = ELT(1+FLOOR(RAND()*15), 'ANNULEE','EN_ATTENTE','LIVREE','LIVREE','LIVREE',
                                                   'LIVREE','LIVREE','LIVREE','LIVREE','LIVREE',
                                                   'LIVREE','LIVREE','LIVREE','EXPEDIEE','EXPEDIEE');
            INSERT INTO fact_commande (date_commande, client_id, vendeur_id, canal, statut, montant_total)
            VALUES (d, v_client, v_vendeur, v_canal, v_statut, 0);
            SET v_cmd_id = LAST_INSERT_ID();

            -- 1 à 5 lignes par commande
            SET v_nb_lignes = 1 + FLOOR(RAND()*5);
            SET v_total = 0;
            SET j = 0;
            WHILE j < v_nb_lignes DO
                SET v_produit = 1 + FLOOR(RAND()*35);
                SET v_qte     = 1 + FLOOR(RAND()*30);
                SET v_remise  = ELT(1+FLOOR(RAND()*5), 0, 0, 0, 5, 10);
                SELECT prix_unitaire INTO v_prix FROM dim_produit WHERE produit_id = v_produit;
                INSERT INTO fact_ligne_commande (commande_id, produit_id, quantite, prix_unitaire_vente, remise_pct)
                VALUES (v_cmd_id, v_produit, v_qte, v_prix, v_remise);
                SET v_total = v_total + v_qte * v_prix * (1 - v_remise/100);

                -- mouvement de stock sortie
                IF v_statut <> 'ANNULEE' THEN
                    INSERT INTO fact_stock (produit_id, date_mouvement, type, quantite)
                    VALUES (v_produit, d, 'SORTIE', v_qte);
                END IF;
                SET j = j + 1;
            END WHILE;

            IF v_statut = 'ANNULEE' THEN SET v_total = 0; END IF;
            UPDATE fact_commande SET montant_total = ROUND(v_total,2) WHERE commande_id = v_cmd_id;
            SET i = i + 1;
        END WHILE;

        -- réapprovisionnement aléatoire
        IF FLOOR(RAND()*3) = 0 THEN
            SET v_produit = 1 + FLOOR(RAND()*35);
            INSERT INTO fact_stock (produit_id, date_mouvement, type, quantite)
            VALUES (v_produit, d, 'ENTREE', 100 + FLOOR(RAND()*400));
        END IF;
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
CALL gen_ventes();

-- ============================================================
--  VUES ANALYTIQUES POUR POWER BI
-- ============================================================

-- Ventes par ligne (détail)
CREATE OR REPLACE VIEW v_ventes_detail AS
SELECT
    l.ligne_id,
    c.commande_id,
    c.date_commande,
    YEAR(c.date_commande)  AS annee,
    MONTH(c.date_commande) AS mois,
    c.canal,
    c.statut,
    cl.nom_client AS client,
    cl.secteur    AS secteur_client,
    cl.region     AS region_client,
    v.nom_vendeur AS vendeur,
    v.region      AS region_vendeur,
    v.ville       AS ville_vendeur,
    p.code_produit,
    p.nom_produit AS produit,
    p.categorie,
    p.sous_categorie,
    l.quantite,
    l.prix_unitaire_vente,
    l.remise_pct,
    ROUND(l.quantite * l.prix_unitaire_vente * (1 - l.remise_pct/100), 2) AS montant_ligne,
    ROUND(l.quantite * (l.prix_unitaire_vente - p.cout_unitaire), 2)      AS marge_brute
FROM fact_ligne_commande l
JOIN fact_commande c   ON c.commande_id = l.commande_id
JOIN dim_produit p     ON p.produit_id  = l.produit_id
JOIN dim_client cl     ON cl.client_id  = c.client_id
JOIN dim_vendeur v     ON v.vendeur_id  = c.vendeur_id
WHERE c.statut <> 'ANNULEE';

-- Ventes agrégées par mois
CREATE OR REPLACE VIEW v_ventes_mensuelles AS
SELECT annee, mois, categorie,
       COUNT(DISTINCT commande_id) AS nb_commandes,
       SUM(quantite)               AS nb_articles,
       SUM(montant_ligne)          AS chiffre_affaires,
       SUM(marge_brute)            AS marge_brute
FROM v_ventes_detail
GROUP BY annee, mois, categorie;

-- Top produits
CREATE OR REPLACE VIEW v_ventes_produits AS
SELECT code_produit, produit, categorie, sous_categorie,
       SUM(quantite) AS quantite_vendue,
       SUM(montant_ligne) AS chiffre_affaires,
       SUM(marge_brute)   AS marge_brute
FROM v_ventes_detail
GROUP BY code_produit, produit, categorie, sous_categorie;

-- Performance vendeurs
CREATE OR REPLACE VIEW v_performance_vendeurs AS
SELECT vendeur, region_vendeur, ville_vendeur,
       COUNT(DISTINCT commande_id) AS nb_commandes,
       SUM(montant_ligne)          AS chiffre_affaires,
       SUM(marge_brute)            AS marge_brute
FROM v_ventes_detail
GROUP BY vendeur, region_vendeur, ville_vendeur;

-- Stock (état par produit)
CREATE OR REPLACE VIEW v_stock_actuel AS
SELECT p.produit_id, p.code_produit, p.nom_produit AS produit, p.categorie,
       COALESCE(SUM(CASE WHEN s.type='ENTREE' THEN s.quantite WHEN s.type='SORTIE' THEN -s.quantite ELSE 0 END),0) AS stock_disponible,
       COALESCE((SELECT SUM(vd.quantite) FROM v_ventes_detail vd WHERE vd.code_produit = p.code_produit),0) AS quantite_vendue
FROM dim_produit p
LEFT JOIN fact_stock s ON s.produit_id = p.produit_id
GROUP BY p.produit_id, p.code_produit, p.nom_produit, p.categorie;

-- Statistiques
SELECT '=== STATISTIQUES VENTES ===' AS info;
SELECT CONCAT('Commandes : ', COUNT(*)) AS stats FROM fact_commande;
SELECT CONCAT('Lignes de vente : ', COUNT(*)) AS stats FROM fact_ligne_commande;
SELECT CONCAT('CA total (validé) : ', FORMAT(SUM(montant_ligne),2), ' USD') AS stats FROM v_ventes_detail;
SELECT CONCAT('Marge brute : ', FORMAT(SUM(marge_brute),2), ' USD') AS stats FROM v_ventes_detail;