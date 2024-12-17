#!/bin/bash

set -e

echo "Add labels to namespace"
kubectl label namespace bestrong-api cert-manager.io/disable-validation=true --overwrite

echo "Add helm repo for cert-manager"
helm repo add jetstack https://charts.jetstack.io

echo "Update helm repo"
helm repo update

echo "Setting CRDs for cert-manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

echo "Install cert-manager"
helm install cert-manager jetstack/cert-manager \
  --namespace bestrong-api \
  --version v1.11.0

echo "Successfully installed cert-manager!"