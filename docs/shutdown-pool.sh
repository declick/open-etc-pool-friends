#!/bin/bash
echo "Arrêt des services pool..."
sudo systemctl stop api
sudo systemctl stop nginx
echo "Attente de 1 minute avant extinction..."
sleep 60
echo "Extinction de la machine..."
sudo shutdown -h now

