<?php
include_once("AccessBDD.php");

/**
 * Classe de construction des requêtes SQL
 * hérite de AccessBDD qui contient les requêtes de base
 * Pour ajouter une requête :
 * - créer la fonction qui crée une requête (prendre modèle sur les fonctions 
 *   existantes qui ne commencent pas par 'traitement')
 * - ajouter un 'case' dans un des switch des fonctions redéfinies 
 * - appeler la nouvelle fonction dans ce 'case'
 */
class MyAccessBDD extends AccessBDD {
	    
    /**
     * constructeur qui appelle celui de la classe mère
     */
    public function __construct(){
        try{
            parent::__construct();
        }catch(\Exception $e){
            throw $e;
        }
    }

    /**
     * demande de recherche
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return array|null tuples du résultat de la requête ou null si erreur
     * @override
     */	
    protected function traitementSelect(string $table, ?array $champs) : ?array{
        switch($table){  
            case "livre" :
                return $this->selectAllLivres();
            case "dvd" :
                return $this->selectAllDvd();
            case "revue" :
                return $this->selectAllRevues();
            case "exemplaire" :
                return $this->selectExemplairesRevue($champs);                        
            case "commande":
                return $this->selectAllCommandes();
            case "users":
                if(empty($champs)){
                    return $this->selectAllUsers();                
                }else{
                    return $this->selectUserAuthentifie($champs);
                }     
            case "commandedocument":
                return $this->selectCommandesDocument($champs);
            case "abonnement":
                if(empty($champs)){
                    return $this->selectAbonnementFinProche();
                }else{
                    return $this->selectAbonnementRevue($champs);
                }                
            case "genre" :
            case "public" :
            case "rayon" :
            case "etat" :
            case "suivi":
                // select portant sur une table contenant juste id et libelle
                return $this->selectTableSimple($table);
            case "" :
                // return $this->uneFonction(parametres);
            default:
                // cas général
                return $this->selectTuplesOneTable($table, $champs);
        }	
    }

    /**
     * demande d'ajout (insert)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples ajoutés ou null si erreur
     * @override
     */	
    protected function traitementInsert(string $table, ?array $champs) : ?int{
        switch($table){
            case "commandedocument":
                return $this->insertCommandeDocument($champs);
            case "abonnement":
                return $this->insertAbonnementRevue($champs);
            case "" :
                // return $this->uneFonction(parametres);
            default:                    
                // cas général
                return $this->insertOneTupleOneTable($table, $champs);	
        }
    }
    
    /**
     * demande de modification (update)
     * @param string $table
     * @param string|null $id
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples modifiés ou null si erreur
     * @override
     */	
    protected function traitementUpdate(string $table, ?string $id, ?array $champs) : ?int{
        switch($table){
            case "commandedocument" :
                return $this->updateCommandeDocument($id, $champs);
            case "" :
                // return $this->uneFonction(parametres);            
            default:                    
                // cas général
                return $this->updateOneTupleOneTable($table, $id, $champs);
        }	
    }  
    
    /**
     * demande de suppression (delete)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples supprimés ou null si erreur
     * @override
     */	
    protected function traitementDelete(string $table, ?array $champs) : ?int{
        switch($table){            
            case "" :
                // return $this->uneFonction(parametres);
            default:                    
                // cas général
                return $this->deleteTuplesOneTable($table, $champs);	
        }
    }	    
        
    /**
     * récupère les tuples d'une seule table
     * @param string $table
     * @param array|null $champs
     * @return array|null 
     */
    private function selectTuplesOneTable(string $table, ?array $champs) : ?array{
        if(empty($champs)){
            // tous les tuples d'une table
            $requete = "select * from $table;";
            return $this->conn->queryBDD($requete);  
        }else{
            // tuples spécifiques d'une table
            $requete = "select * from $table where ";
            foreach ($champs as $key => $value){
                $requete .= "$key=:$key and ";
            }
            // (enlève le dernier and)
            $requete = substr($requete, 0, strlen($requete)-5);	          
            return $this->conn->queryBDD($requete, $champs);
        }
    }	

    /**
     * demande d'ajout (insert) d'un tuple dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples ajoutés (0 ou 1) ou null si erreur
     */	
    private function insertOneTupleOneTable(string $table, ?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        // construction de la requête
        $requete = "insert into $table (";
        foreach ($champs as $key => $value){
            $requete .= "$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);
        $requete .= ") values (";
        foreach ($champs as $key => $value){
            $requete .= ":$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);
        $requete .= ");";
        return $this->conn->updateBDD($requete, $champs);
    }

    /**
     * demande de modification (update) d'un tuple dans une table
     * @param string $table
     * @param string\null $id
     * @param array|null $champs 
     * @return int|null nombre de tuples modifiés (0 ou 1) ou null si erreur
     */	
    private function updateOneTupleOneTable(string $table, ?string $id, ?array $champs) : ?int {
        if(empty($champs)){
            return null;
        }
        if(is_null($id)){
            return null;
        }
        // construction de la requête
        $requete = "update $table set ";
        foreach ($champs as $key => $value){
            $requete .= "$key=:$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);				
        $champs["id"] = $id;
        $requete .= " where id=:id;";		
        return $this->conn->updateBDD($requete, $champs);	        
    }
    
    /**
     * demande de suppression (delete) d'un ou plusieurs tuples dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples supprimés ou null si erreur
     */
    private function deleteTuplesOneTable(string $table, ?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        // construction de la requête
        $requete = "delete from $table where ";
        foreach ($champs as $key => $value){
            $requete .= "$key=:$key and ";
        }
        // (enlève le dernier and)
        $requete = substr($requete, 0, strlen($requete)-5);   
        return $this->conn->updateBDD($requete, $champs);	        
    }
 
    /**
     * récupère toutes les lignes d'une table simple (qui contient juste id et libelle)
     * @param string $table
     * @return array|null
     */
    private function selectTableSimple(string $table) : ?array{
        $requete = "select * from $table order by libelle;";		
        return $this->conn->queryBDD($requete);	    
    }
    
    /**
     * récupère toutes les lignes de la table Livre et les tables associées
     * @return array|null
     */
    private function selectAllLivres() : ?array{
        $requete = "Select l.id, l.ISBN, l.auteur, d.titre, d.image, l.collection, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from livre l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";		
        return $this->conn->queryBDD($requete);
    }	

    /**
     * récupère toutes les lignes de la table DVD et les tables associées
     * @return array|null
     */
    private function selectAllDvd() : ?array{
        $requete = "Select l.id, l.duree, l.realisateur, d.titre, d.image, l.synopsis, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from dvd l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";	
        return $this->conn->queryBDD($requete);
    }	

    /**
     * récupère toutes les lignes de la table Revue et les tables associées
     * @return array|null
     */
    private function selectAllRevues() : ?array{
        $requete = "Select l.id, l.periodicite, d.titre, d.image, l.delaiMiseADispo, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from revue l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";
        return $this->conn->queryBDD($requete);
    }	

    /**
     * récupère tous les exemplaires d'une revue
     * @param array|null $champs 
     * @return array|null
     */
    private function selectExemplairesRevue(?array $champs) : ?array{
        if(empty($champs)){
            return null;
        }
        if(!array_key_exists('id', $champs)){
            return null;
        }
        $champNecessaire['id'] = $champs['id'];
        $requete = "Select e.id, e.numero, e.dateAchat, e.photo, e.idEtat ";
        $requete .= "from exemplaire e join document d on e.id=d.id ";
        $requete .= "where e.id = :id ";
        $requete .= "order by e.dateAchat DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * récupère toutes les lignes de la table commande
     * @return array|null
     */
    private function selectAllCommandes(): ?array{
        $requete = "Select *";
        $requete .= " from commande c";
        $requete .= " order by c.dateCommande";
        return $this->conn->queryBDD($requete);
    }
    
    /**
     * récupère toutes les commandes d'un document
     * @param array|null $champs
     * @return array|null
     */
    private function selectCommandesDocument(?array $champs): ?array{
        if(empty($champs)){
            return null;
        }
        if(!array_key_exists('idLivreDvd', $champs)){
            return null;
        }
        $champNecessaire['idLivreDvd'] = $champs['idLivreDvd'];
        $requete = "Select cd.id, cd.nbExemplaire, cd.idSuivi, cd.idLivreDvd, c.dateCommande, c.montant, s.libelle as suivi";
        $requete .= " from commandedocument cd join commande c on cd.id=c.id";
        $requete .= " join suivi s on cd.idSuivi=s.id";
        $requete .= " join livres_dvd ld on cd.idLivreDvd=ld.id";
        $requete .= " where cd.idLivreDvd= :idLivreDvd";
        $requete .= " order by c.dateCommande DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * demande d'ajout d'une commande à un document
     * @param array|null $champs
     * @return int|null nombre de tuples insérés en base de données
     */
    private function insertCommandeDocument(?array $champs): ?int
    {          
        if(empty($champs)){            
            return null;
        }
        $champsNecessaire = [
            'id' => $champs['Id'],
            'dateCommande' => $champs['DateCommande'],
            'montant' => $champs['Montant'],
            'nbExemplaire' => $champs['NbExemplaire'],
            'idLivreDvd' => $champs['IdLivreDvd'],
            'idSuivi' => $champs['IdSuivi']            
        ];
        $req = "CALL insertCommande(:id, :dateCommande, :montant, :nbExemplaire, :idLivreDvd, :idSuivi)";
              
        return $this->conn->updateBDD($req, $champsNecessaire);        
    }    
        
    /**
     * modification du statut d'une commande d'un document
     * @param string $id
     * @param array|null $champs
     * @return int|null     
     */
    private function updateCommandeDocument(string $id, ?array $champs): ?int
    {
        if(empty($champs)){
            return null;
        }
        if(is_null($id)){
            return null;
        }
        
        $champsNecessaires = [
            'id' => $id,
            'idSuivi' => $champs['IdSuivi']
        ];
        // construction de la requête
        $requete = "update commandedocument ";        
        $requete .= "set idSuivi = :idSuivi ";        
        $requete .= " where id=:id;";		
        return $this->conn->updateBDD($requete, $champsNecessaires);
    }
    
    /**
     * récupère tous les abonnements d'une revue
     * @param array|null $champs
     * @return array|null
     */
    private function selectAbonnementRevue(?array $champs) : ?array {
        if(empty($champs)){
            return null;
        }
        if(!array_key_exists('idRevue', $champs)){
            return null;
        }
        $champNecessaire['idRevue'] = $champs['idRevue'];
        $requete = "Select a.id, a.dateFinAbonnement, a.idRevue, c.dateCommande, c.montant";
        $requete .= " from abonnement a join commande c on a.id=c.id";
        $requete .= " join revue r on a.idRevue=r.id";
        $requete .= " where a.idRevue= :idRevue";
        $requete .= " order by c.dateCommande DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * demande d'ajout d'un abonnement à une revue
     * @param array|null $champs
     * @return int|null nombre de tuples insérés en base de données
     */
    private function insertAbonnementRevue(?array $champs) : ?int {
        if(empty($champs)){
            return null;
        }       
        $champsNecessaires = [
            'id' => $champs['Id'],
            'dateCommande' => $champs['DateCommande'],
            'montant' => $champs['Montant'],
            'dateFinAbonnement' => $champs['DateFinAbonnement'],
            'idRevue' => $champs['IdRevue']
        ];
        $requete = "CALL insertAbonnementRevue(:id, :dateCommande, :montant, :dateFinAbonnement, :idRevue)";
        return $this->conn->updateBDD($requete, $champsNecessaires);
    }
    
    /**
     * récupère tous les abonnements avec le titre de la revue associée
     * @return array|null
     */
    private function selectAbonnementFinProche() : ?array{
        $requete = "select a.dateFinAbonnement, a.idRevue, d.titre ";
        $requete .= "from abonnement a join revue r on a.idRevue = r.id ";
        $requete .= "join document d on r.id = d.id ";
        $requete .= "order by a.dateFinAbonnement ASC";
        return $this->conn->queryBDD($requete);
        
    }
    
    /**
     * récupère tous les users
     * @return array|null
     */
    private function selectAllUsers() : ?array{
        $requete = "Select u.id, u.login, u.pwd, u.idService, s.libelle from users u ";
        $requete .="join service s on u.idService = s.id";
        return $this->conn->queryBDD($requete);
    }
    
    /**
     * récupère les users concernés par les paramètres
     * @param type $champs
     * @return array|null
     */
    private function selectUserAuthentifie($champs) : ?array{
        if(empty($champs)){
            return null;
        }        
        $champsNecessaires = [
            'login' => $champs['login'],
            'pwd' => $champs['pwd']
        ];
        $requete = "Select u.id, u.login, u.pwd, u.idService from users u ";        
        $requete .= "where u.login =:login and u.pwd =SHA2(:pwd, 256)";        
        return $this->conn->queryBDD($requete, $champsNecessaires);
        
    }
}
