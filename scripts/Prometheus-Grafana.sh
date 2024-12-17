# Define public Kubernetes chart repository in the Helm configuration
echo "Adding a Helm repository for Prometheus-Grafana"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update local repositories
helm repo update

# Create a namespace for Prometheus and Grafana resources
# kubectl create ns bestrong-api  # (already exists)

# Install Prometheus using HELM
helm install prometheus prometheus-community/kube-prometheus-stack -n bestrong-api

echo "Prometheus and Grafana have been successfully installed!"
