// ============================================================
//  Power Query (M) — Chargement du dashboard BI Ventes
//  Usage : Éditeur Power Query -> Requête vide -> copier-coller
//  Paramétrer ModeSource : "CSV" ou "MySQL"
// ============================================================

let
    // ---------- PARAMÈTRES ----------
    ModeSource        = "CSV",                        // "CSV" ou "MySQL"
    CheminCSV         = "D:\bi\csv\ventes\",          // dossier des CSV ventes
    ServeurMySQL      = "localhost:3306",
    BaseMySQL         = "bi_ventes",
    UtilisateurMySQL  = "root",
    MotDePasseMySQL   = "",

    // ---------- CONNEXION MYSQL ----------
    ConnexionMySQL = (Requete as text) =>
        MySql.Database(ServeurMySQL, BaseMySQL, [Query = Requete]),

    // ---------- CHARGEMENT ----------
    Tables = if ModeSource = "CSV" then
        let
            Detail  = Csv.Document(File.Contents(CheminCSV & "v_ventes_detail.csv"),
                       [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            DetailPromu = Table.PromoteHeaders(Detail, [PromoteAllScalars = true]),
            Mensuel = Csv.Document(File.Contents(CheminCSV & "v_ventes_mensuelles.csv"),
                       [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            MensuelPromu = Table.PromoteHeaders(Mensuel, [PromoteAllScalars = true]),
            Produits = Csv.Document(File.Contents(CheminCSV & "v_ventes_produits.csv"),
                       [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            ProduitsPromu = Table.PromoteHeaders(Produits, [PromoteAllScalars = true]),
            Vendeurs = Csv.Document(File.Contents(CheminCSV & "v_performance_vendeurs.csv"),
                       [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            VendeursPromu = Table.PromoteHeaders(Vendeurs, [PromoteAllScalars = true]),
            Stock = Csv.Document(File.Contents(CheminCSV & "v_stock_actuel.csv"),
                       [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            StockPromu = Table.PromoteHeaders(Stock, [PromoteAllScalars = true])
        in
            [Detail = DetailPromu, Mensuel = MensuelPromu, Produits = ProduitsPromu,
             Vendeurs = VendeursPromu, Stock = StockPromu]
    else
        let
            Detail  = ConnexionMySQL("SELECT * FROM v_ventes_detail"),
            Mensuel = ConnexionMySQL("SELECT * FROM v_ventes_mensuelles"),
            Produits = ConnexionMySQL("SELECT * FROM v_ventes_produits"),
            Vendeurs = ConnexionMySQL("SELECT * FROM v_performance_vendeurs"),
            Stock = ConnexionMySQL("SELECT * FROM v_stock_actuel")
        in
            [Detail = Detail, Mensuel = Mensuel, Produits = Produits,
             Vendeurs = Vendeurs, Stock = Stock],

    // ---------- NETTOYAGE ----------
    DetailNettoye = Table.TransformColumnTypes(Tables[Detail], {
        {"ligne_id", Int64.Type}, {"commande_id", Int64.Type},
        {"date_commande", type date}, {"annee", Int64.Type}, {"mois", Int64.Type},
        {"quantite", Int64.Type}, {"prix_unitaire_vente", type number},
        {"remise_pct", type number}, {"montant_ligne", type number},
        {"marge_brute", type number}
    }),

    // ---------- MESURES (à créer dans Power BI) ----------
    // Chiffre d'affaires = SUM('v_ventes_detail'[montant_ligne])
    // Marge brute       = SUM('v_ventes_detail'[marge_brute])
    // Taux de marge %   = DIVIDE([Marge brute], [Chiffre d'affaires], 0)
    // Nb commandes      = DISTINCTCOUNT('v_ventes_detail'[commande_id])
    // Panier moyen      = DIVIDE([Chiffre d'affaires], [Nb commandes])
    // Remise moyenne %  = AVERAGE('v_ventes_detail'[remise_pct])

    // ---------- SORTIES ----------
    SortieDetail    = DetailNettoye,
    SortieMensuel   = Tables[Mensuel],
    SortieProduits  = Tables[Produits],
    SortieVendeurs  = Tables[Vendeurs],
    SortieStock     = Tables[Stock]
in
    SortieDetail