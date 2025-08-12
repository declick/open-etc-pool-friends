#!/bin/bash

RPC_URL="http://127.0.0.1:8545"

# Conversion hexadécimal -> décimal
hex_to_dec() {
  printf "%d\n" "0x${1#0x}"
}

last_block=0
last_time=$(date +%s)

echo -e "\n--- Suivi Live de la synchronisation Core-geth ---\n"

while true; do
  datetime=$(date '+%Y-%m-%d %H:%M:%S')

  # Bloc courant
  current_block_hex=$(curl -sf -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $RPC_URL | jq -r '.result')

  # Si la réponse est vide ou erreur, affiche un message puis attend
  if [[ -z "$current_block_hex" || "$current_block_hex" == "null" ]]; then
    echo -e "[$datetime] \033[1;31mErreur : Impossible de joindre le RPC ($RPC_URL)\033[0m"
    sleep 10
    continue
  fi

  current_block=$(hex_to_dec $current_block_hex)

  # Vérifie si la node est en train de synchroniser
  syncing_json=$(curl -sf -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' $RPC_URL)
  syncing=$(echo "$syncing_json" | jq '.result')

  if [[ "$syncing" != "false" && "$syncing" != "null" ]]; then
    highest_block_hex=$(echo "$syncing_json" | jq -r '.result.highestBlock')
    highest_block=$(hex_to_dec $highest_block_hex)
  else
    highest_block=$current_block
  fi

  # Calcul du pourcentage de synchro
  if [ "$highest_block" -gt 0 ]; then
    percent_sync=$(awk "BEGIN {printf \"%.2f\", ($current_block / $highest_block) * 100}")
  else
    percent_sync="N/A"
  fi

  # Calcul vitesse et ETA
  now=$(date +%s)
  elapsed=$(( now - last_time ))
  if [ "$elapsed" -gt 0 ]; then
    blocks_diff=$(( current_block - last_block ))
    blocks_per_minute=$(( blocks_diff * 60 / elapsed ))
    remaining_blocks=$(( highest_block - current_block ))
    if [ "$blocks_per_minute" -gt 0 ]; then
      eta_min=$(( remaining_blocks / blocks_per_minute ))
      eta_h=$(( eta_min / 60 ))
      eta_min_rest=$(( eta_min % 60 ))
      eta_disp="~${eta_h}h${eta_min_rest}min"
    else
      eta_disp="N/A"
    fi
  else
    blocks_per_minute=0
    eta_disp="N/A"
  fi
  last_block=$current_block
  last_time=$now

  # Affichage
  if (( $(echo "$percent_sync >= 99.5" | bc -l) )); then
    echo -e "[$datetime] \033[1;32mSynchronisation terminée : $current_block / $highest_block ($percent_sync%)\033[0m"
    break
  else
    echo -e "[$datetime] Bloc sync : $current_block / $highest_block - \033[1;33m$percent_sync%\033[0m | Vitesse: $blocks_per_minute blocs/min | ETA: $eta_disp"
  fi

  sleep 15
done

echo -e "\n\033[1;32mTon nœud est synchronisé !\033[0m"

