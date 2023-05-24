#!/bin/bash

# Fonction pour créer un serveur sur Hetzner et enregistrer la sortie de l'API dans un fichier JSON
create_server() {
  read -p "Entrez le nom du serveur : " server_name
  read -p "Entrez le type de serveur (laissez vide pour utiliser 'cx11') : " server_type
  read -p "Entrez l'image du serveur (laissez vide pour utiliser 'ubuntu-22.04') : " server_image

  if [ -z "$server_type" ]; then
    server_type="cx11"
  fi

  if [ -z "$server_image" ]; then
    server_image="ubuntu-22.04"
  fi

  api_response=$(curl -s -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "'"$server_name"'",
      "server_type": "'"$server_type"'",
      "image": "'"$server_image"'",
      "start_after_create": true
    }' \
    "https://api.hetzner.cloud/v1/servers")

  echo $api_response >> api_response.txt

  status_code=$(echo "$api_response" | jq -r '.action.status')
  if [ "$status_code" = "running" ]; then
    server_id=$(echo "$api_response" | jq -r '.server.id')
    server_ip=$(echo "$api_response" | jq -r '.server.public_net.ipv4.ip')

    echo "$api_response" > "server_output_$server_id.json"
    echo "Le serveur a été créé avec succès. L'adresse IP du serveur est : $server_ip"
    echo "ID du serveur : $server_id"
    echo "La sortie de l'API a été enregistrée dans server_output_$server_id.json."
  else
    error_message=$(echo "$api_response" | jq -r '.error.message')
    echo "Erreur lors de la création du serveur : $error_message"
  fi
}

# Fonction pour supprimer un serveur sur Hetzner et supprimer le fichier JSON associé
delete_server() {
  files=$(ls server_output_*.json 2>/dev/null)

  if [ -z "$files" ]; then
    echo "Aucun serveur n'a été créé."
  else
    echo "Les serveurs suivants ont été créés :"

    for file in $files; do
      server_name=$(jq -r '.server.name' "$file")
      server_id=$(jq -r '.server.id' "$file")
      server_ip=$(jq -r '.server.public_net.ipv4.ip' "$file")
      echo " - $server_name (ID: $server_id, IP: $server_ip)"
    done

    read -p "Entrez l'ID du serveur que vous souhaitez supprimer : " server_id_to_delete

    for file in $files; do
      server_id=$(jq -r '.server.id' "$file")
      if [ "$server_id" = "$server_id_to_delete" ]; then
        api_response=$(curl -s -X DELETE \
          -H "Authorization: Bearer $API_TOKEN" \
          "https://api.hetzner.cloud/v1/servers/$server_id")
        echo $api_response >> api_response.txt
        status_code=$(echo "$api_response" | jq -r '.action.status')
        if [ "$status_code" = "running" ]; then
          rm "$file"
          echo "Le serveur avec l'ID $server_id a été supprimé avec succès."
        else
          error_message=$(echo "$api_response" | jq -r '.error.message')
          echo "Erreur lors de la suppression du serveur avec l'ID $server_id : $error_message"
        fi

        return
      fi
    done

    echo "Aucun serveur trouvé avec l'ID $server_id_to_delete."
  fi
}

# Menu principal
while true; do
  echo "----- MENU -----"
  echo "1. Ajouter un serveur"
  echo "2. Supprimer un serveur"
  echo "3. Quitter"

  read -p "Choisissez une option (1, 2 ou 3) : " choice

  case $choice in
    1)
      create_server
      ;;
    2)
      delete_server
      ;;
    3)
      echo "Au revoir !"
      exit 0
      ;;
    *)
      echo "Option invalide. Veuillez choisir une option valide."
      ;;
  esac

  echo
done


