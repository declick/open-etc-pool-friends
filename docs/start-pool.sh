#!/bin/bash

echo ">>> Rechargement des services..."
sudo systemctl daemon-reload

echo ">>> Redémarrage de geth..."
sudo systemctl restart geth

echo ">>> Redémarrage de l'API..."
sudo systemctl restart api

echo ">>> Redémarrage de nginx..."
sudo systemctl restart nginx

echo ">>> Tous les services ont été redémarrés avec succès."
