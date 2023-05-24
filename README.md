# Script API Hetzner

Ce script permet de déployer des serveurs sur le cloud hetzner en quelques secondes.

```mermaid
flowchart TD
    A[script.bash] -->|1| B(Ajouter un serveur)
    A --> |2|C(Supprimer un serveur) --> J(lis tous les fichiers server_output_SERVERID.json) --> |sélection de l'id|K(suppression du serveur dans le cloud) 
    K --> L(supprime le fichier server_output_SERVERID.json)
    L --> A
    A --> |3|D(Quitter)
    D --> E(FIN)
    B --> |requis|F(nom du serveur) --> |defaut cx11|G(type de serveur) --> |defaut ubuntu-22.04| H(image du serveur) -->|Créer un serveur dans le cloud| I(creation server_output_SERVERID.json)
    I --> A
```
## Prérequis

```bash
sudo apt update && sudo apt install -y jq
# Ajout de la variable d'environnement API_TOKEN
export API_TOKEN="API TOKEN HETZNER"
```

## Lancement du script

```bash
bash script.bash
```
