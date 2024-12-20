#!/bin/bash
 
 
set -e

# echo "Create a namespace"
# kubectl create namespace bestrong-api --dry-run=client -o yaml | kubectl apply -f -

echo "Adding a Helm repository for ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

echo "Update a Helm repo"
helm repo update

echo "Install the NGINX Ingress Controller"
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace bestrong-api \
  --set controller.config.http2=true \
  --set controller.config.http2-push="on" \
  --set controller.config.http2-push-preload="on" \
  --set controller.ingressClassByName=true \
  --set controller.ingressClassResource.controllerValue=k8s.io/ingress-nginx \
  --set controller.ingressClassResource.enabled=true \
  --set controller.ingressClassResource.name=public \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.setAsDefaultIngress=true

echo "NGINX Ingress Controller has been successfully installed!"
