# Task report

## 1) Create an AKS cluster using Terraform (make a separate Github repo with documentation) 
### So, first, we created modules for the relevant resources(Azure Container Register, Azure Kubernetes Service, Resource Group, Storage Account, Virtual Network(VNet), Azure Container Resource). One module for a resource always has files as main.tf, outputs.tf and variables.tf. 
```
# Resource Group Module
module "resource_group" {
  source                          = "./modules/resource_group"
  azurerm_resource_group_name     = var.rg_name
  azurerm_resource_group_location = var.rg_location
}

#Storage Account Module
module "storage_account" {
  source               = "./modules/storage_account"
  resource_group_name  = var.rg_name
  location             = var.rg_location
  storage_account_name = var.storage_account_name
  container_name       = var.container_name
}


# VNet Module
module "vnet" {
  source                  = "./modules/vnet"
  vnet_name               = var.vnet_name
  resource_group_name     = var.rg_name
  resource_group_location = var.rg_location
  azurerm_subnet_name     = var.subnet_name

}

# AKS Cluster Module
module "aks" {
  source                  = "./modules/aks"
  resource_group_name     = var.rg_name
  resource_group_location = var.rg_location
  node_count              = var.node_count
  username                = var.ssh_username
}
```

## 2) Create Helm charts (use templates) for "BeStrong" API https://github.com/FabianGosebrink/ASPNETCore-WebAPI-Sample. 
### Helm is a package manager for Kubernetes that simplifies the process of creating, managing, deploying, and upgrading applications in a Kubernetes cluster.
### Helm Chart is a collection of files that describe the structure of a Kubernetes application. They contain YAML manifests, configuration variables, and templates for deploying Kubernetes resources (for example, Deployment, Service, Ingress, ConfigMap, etc.).
### In this task, we created helm charts (./helm-charts).
### First, nginx-ingress was installed:
```
# Create a namespace for ingress resources
kubectl create namespace bestrong-ingress
```
```
# Add the Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```
```
# Use Helm to deploy an NGINX ingress controller
helm upgrade --install ingress-nginx ingress-nginx \
 --repo https://kubernetes.github.io/ingress-nginx \
 --namespace bestrong-ingress \
 --set controller.config.http2=true \
 --set controller.config.http2-push="on" \
 --set controller.config.http2-push-preload="on" \
 --set controller.ingressClassByName=true \
 --set controller.ingressClassResource.controllerValue=k8s.io/ingress-nginx \
 --set controller.ingressClassResource.enabled=true \
 --set controller.ingressClassResource.name=public \
 --set controller.service.externalTrafficPolicy=Local \
 --set controller.setAsDefaultIngress=true
```
### Chart.yaml - the main metafile describing the chart.
```
apiVersion: v2
name: bestrong-chart
description: "A Helm chart for Blue-Green Deployment, monitoring and OpenCost"
type: application
version: 0.1.0
appVersion: "1.0.0"
```
### values.yaml - saves parameters used in templates.
```
namespace: bestrong-api

service:
  name: bestrong-api-svc
  selector:
    app: blue-green-dep
    color: blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP

ingress:
  name: default-ingress
  annotations:
    certManager: letsencrypt-prod
    proxySetHeaders: ingress-nginx-csp-headers
    # nginx.ingress.kubernetes.io/auth-type: "basic"
    # nginx.ingress.kubernetes.io/auth-secret: "prometheus-basic-auth"
    # nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
  ingressClassName: public # never touch this again
  tls:
    hosts:
      - bestandstrong.pp.ua
      - graf.bestandstrong.pp.ua
      - prom.bestandstrong.pp.ua
      - opencost.bestandstrong.pp.ua
    secretName: userapi-tls-monitoring
  rules:
    - host: bestandstrong.pp.ua
      paths:
        - path: /
          pathType: Prefix
          service:
            name: bestrong-api-svc
            port: 80
    - host: graf.bestandstrong.pp.ua
      paths:
        - path: /
          pathType: Prefix
          service:
            name: prometheus-grafana
            port: 80
    - host: prom.bestandstrong.pp.ua
      paths:
        - path: /
          pathType: Prefix
          service:
            name: prometheus-kube-prometheus-prometheus
            port: 9090
    - host: opencost.bestandstrong.pp.ua
      paths:
        - path: /
          pathType: Prefix
          service:
            name: opencost
            port: 9090
    # - host: fluent.bestandstrong.pp.ua
    #   paths:
    #     - path: /
    #       pathType: Prefix
    #       service:
    #         name: fluent-bit
    #         port: 2020

deploymentsBlue:
  - name: blue-dep
    replicas: 2
    labels:
      app: blue-green-dep
      color: blue
    container:
      name: bestrong-api-blue
      image: steeve05/bestr:blue
      imagePullPolicy: Always
      port: 80
      environment: "Development"

deploymentsGreen:
  - name: green-dep
    replicas: 2
    labels:
      app: blue-green-dep
      color: green
    container:
      name: bestrong-api-green
      image: steeve05/bestr:green
      imagePullPolicy: Always
      port: 80
      environment: "Development"

clusterIssuer:
  name: letsencrypt-prod
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: stefansnihur@gmail.com
    privateKeySecretName: letsencrypt-prod-issuer-key1
    solver:
      ingressClass: nginx #(pay attention (nginx))

certificate:
  name: ingress-nginx-tls-monitoring
  secretName: userapi-tls-monitoring
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - bestandstrong.pp.ua
  usages:
    - digital signature
    - key encipherment
    - server auth

csp:
  name: ingress-nginx-csp-headers
  policy: "script-src 'self' 'unsafe-eval'; object-src 'none';"
```

### k8s_manifests - folder with Kubernetes resource manifests
```
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  namespace: {{ .Values.service.namespace }}
spec:
  selector:
    app: {{ .Values.service.app }}
    color: {{ .Values.service.color }}
  ports:
    - protocol: {{ .Values.service.protocol }}
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
  type: {{ .Values.service.type }}
```
### Helm is an essential tool for efficient application management in Kubernetes that helps reduce complexity, provides scalability, and accelerates application development and maintenance.

## 3) "BeStrong" API should be accessible via public Internet using HTTPS. Please, use either self-signed certificate or Let's Encrypt (if you have a domain for testing). In both cases, you should use cert-manager.

## The first thing we did was installing cert-manager: 
![Installing cert-manager](/screenshots/installing_certmanager.png)

### By executing these commands we have installed: 
### Cert-manager (controller) which will monitor Certificate and ClusterIssuer(Issuer) resources and automate certificate issuance;
### Webhook which will validate cert-manager resources.


