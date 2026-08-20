// ============================================================
//  Power Query (M) — Chargement automatique du dashboard BI Finance
//  Usage dans Power BI Desktop :
//    Transformer les données -> Éditeur Power Query -> Nouvelle source
//    -> Requête vide -> Copier-coller ce script -> Utiliser
//  Paramétrer selon la source choisie (MySQL ou CSV) en bas du script.
// ============================================================

let
    // ---------- PARAMÈTRES ----------
    ModeSource        = "CSV",                      // "CSV" ou "MySQL"
    CheminCSV         = "D:\bi\csv\",               // dossier des CSV exportés
    ServeurMySQL      = "localhost:3306",
    BaseMySQL         = "bi_finance",
    UtilisateurMySQL  = "root",
    MotDePasseMySQL   = "",

    // ---------- CONNEXION MYSQL ----------
    ConnexionMySQL = (Requete as text) =>
        let
            Source = MySql.Database(ServeurMySQL, BaseMySQL,
                        [Query = Requete])
        in
            Source,

    // ---------- CHARGEMENT DES TABLES ----------
    Tables = if ModeSource = "CSV" then
        let
            Flux       = Csv.Document(File.Contents(CheminCSV & "v_flux_financier.csv"),
                          [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            FluxPromu  = Table.PromoteHeaders(Flux, [PromoteAllScalars = true]),

            Budget     = Csv.Document(File.Contents(CheminCSV & "v_budget_vs_reel.csv"),
                          [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            BudgetPromu = Table.PromoteHeaders(Budget, [PromoteAllScalars = true]),

            Revenus    = Csv.Document(File.Contents(CheminCSV & "v_revenus_mensuels.csv"),
                          [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            RevenusPromu = Table.PromoteHeaders(Revenus, [PromoteAllScalars = true]),

            Depenses   = Csv.Document(File.Contents(CheminCSV & "v_depenses_mensuelles.csv"),
                          [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            DepensesPromu = Table.PromoteHeaders(Depenses, [PromoteAllScalars = true])
        in
            [Flux = FluxPromu, Budget = BudgetPromu,
             Revenus = RevenusPromu, Depenses = DepensesPromu]
    else
        let
            Flux = ConnexionMySQL("SELECT * FROM v_flux_financier"),
            Budget = ConnexionMySQL("SELECT * FROM v_budget_vs_reel"),
            Revenus = ConnexionMySQL("SELECT * FROM v_revenus_mensuels"),
            Depenses = ConnexionMySQL("SELECT * FROM v_depenses_mensuelles")
        in
            [Flux = Flux, Budget = Budget, Revenus = Revenus, Depenses = Depenses],

    // ---------- NETTOYAGE DE LA TABLE PRINCIPALE ----------
    Flux = Tables[Flux],
    FluxNettoye = Table.TransformColumnTypes(Flux, {
        {"tx_id", Int64.Type},
        {"date_tx", type date},
        {"annee", Int64.Type},
        {"mois", Int64.Type},
        {"montant", type number},
        {"statut", type text}
    }),

    // ---------- RELATIONS (modélisation) ----------
    // Créer les relations dans Power BI :
    //   v_flux_financier[compte]  -> v_budget_vs_reel[compte]
    //   v_flux_financier[annee]   -> v_budget_vs_reel[annee]
    //   v_flux_financier[mois]    -> v_budget_vs_reel[mois]
    //   v_flux_financier[date_tx] -> table Calendrier (créée dans Power BI)

    // ---------- MESURES (à recréer dans Power BI) ----------
    // Total Revenus    = CALCULATE(SUM('v_flux_financier'[montant]),
    //                      'v_flux_financier'[type_flux] = "REVENU",
    //                      'v_flux_financier'[statut] = "VALIDE")
    // Total Dépenses   = CALCULATE(SUM('v_flux_financier'[montant]),
    //                      'v_flux_financier'[type_flux] = "DEPENSE",
    //                      'v_flux_financier'[statut] = "VALIDE")
    // Résultat Net     = [Total Revenus] - [Total Dépenses]
    // Marge Nette %    = DIVIDE([Résultat Net], [Total Revenus], 0)

    // ---------- SORTIES ----------
    SortieFlux      = FluxNettoye,
    SortieBudget    = Tables[Budget],
    SortieRevenus   = Tables[Revenus],
    SortieDepenses  = Tables[Depenses]
in
    SortieFlux