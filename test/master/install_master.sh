#!/bin/bash

# Mettre à jour les paquets et installer les dépendances nécessaires
echo "Mise à jour des paquets et installation des dépendances..."
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Ajouter la clé GPG officielle de Docker
echo "Ajout de la clé GPG officielle de Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg

# Ajouter le dépôt APT de Docker
echo "Ajout du dépôt APT de Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mettre à jour les paquets APT à nouveau
echo "Mise à jour des paquets APT..."
sudo apt-get update

# Installer containerd
echo "Installation de containerd..."
sudo apt-get install -y containerd.io

# Créer un fichier de configuration par défaut pour containerd
echo "Création d'un fichier de configuration par défaut pour containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Configurer containerd pour utiliser systemd comme pilote cgroup
echo "Configuration de containerd pour utiliser systemd comme pilote cgroup..."
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Redémarrer et activer containerd
echo "Redémarrage et activation de containerd..."
sudo systemctl restart containerd
sudo systemctl enable containerd

# Désactiver le swap
echo "Désactivation du swap..."
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Activer les modules de noyau nécessaires
echo "Activation des modules de noyau nécessaires..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Ajouter le dépôt APT de Kubernetes
echo "Ajout du dépôt APT de Kubernetes..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Mettre à jour les paquets APT et installer kubelet, kubeadm, kubectl
echo "Mise à jour des paquets APT et installation de kubelet, kubeadm, kubectl..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialiser le master Kubernetes
echo "Initialisation du master Kubernetes..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configurer kubectl pour l'utilisateur courant
echo "Configuration de kubectl pour l'utilisateur courant..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Déployer un réseau de pods (par exemple, Flannel)
echo "Déploiement d'un réseau de pods (Flannel)..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Installer cert-manager
echo "Installation de cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Générer un nouveau token et obtenir le hash du certificat CA
echo "Génération d'un nouveau token et obtention du hash du certificat CA..."
TOKEN=$(sudo kubeadm token create)
if [ -z "$TOKEN" ]; then
    echo "Erreur: Le token n'a pas été généré correctement."
    exit 1
fi
echo "Token généré: $TOKEN"

CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
if [ -z "$CA_CERT_HASH" ]; then
    echo "Erreur: Le hash du certificat CA n'a pas été généré correctement."
    exit 1
fi
echo "Hash du certificat CA: $CA_CERT_HASH"

# Construire la commande join
echo "Construction de la commande join..."
JOIN_COMMAND="sudo kubeadm join 10.0.1.4:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$CA_CERT_HASH"

# Enregistrer la commande join dans un fichier
echo "Enregistrement de la commande join dans un fichier..."
echo $JOIN_COMMAND > /tmp/join_command.txt

# Afficher la commande join pour référence
echo "Utilisez cette commande pour joindre les nœuds de travail au cluster:"
cat /tmp/join_command.txt

echo "Master setup completed successfully!"
