#!/bin/bash
echo "=== Arrêt sécurisé de geth ==="

# Arrêter le service
sudo systemctl stop geth

# Attendre que le process ait vraiment disparu
echo "Attente de l'arrêt complet…"
while pgrep -u mirje -x geth > /dev/null; do
    sleep 2
    echo "… toujours en cours d'arrêt"
done

# Synchroniser toutes les écritures disque (flush)
echo "Synchronisation en cours…"
sync

# Sauvegarde du dossier blockchain daté
BACKUP_DIR="/home/mirje/classic/.ethereum"
DEST="/home/mirje/backup_blockchain"
mkdir -p "$DEST"
tar czf "$DEST/blockchain_backup_$(date +%F_%H-%M-%S).tar.gz" -C "$BACKUP_DIR" .

echo "✅ Geth arrêté proprement et blockchain sauvegardée."
