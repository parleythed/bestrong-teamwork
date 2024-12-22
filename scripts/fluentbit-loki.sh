#!/bin/bash

set -e


# Define public Kubernetes chart repository in the Helm configuration
echo "Adding a Helm repository for FluentBit and Loki"

helm helm repo add fluent https://fluent.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
# Update local repositories
helm repo update

# Create a namespace for FluentBit and Loki 
# kubectl create ns bestrong-api  # (already exists)

# Install resources using HELM
helm helm upgrade --install fluent-bit fluent/fluent-bit -n bestrong-api
helm upgrade --install loki grafana/loki-stack -n bestrong-api

echo "FluentBit and Loki have been successfully installed!"
