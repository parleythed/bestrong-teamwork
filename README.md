## For a group assignment that is divided into three tasks, this was done: 
### Task 1: Created AKS Cluster(and other resources) using Terraform, Helm charts, made Bestrong API accesible by the Internet using cert-manager, create ClusterIssuer(for the certificate for our domain name), deployed "BeStrong" API to AKS via Azure DevOps using Helm charts and run instances of "BeStrong" API which running at the same time with blue-green deployment.
### Task 2: Set up Prometheus and Grafana in AKS cluster with Prometheus Alert when "BeStrong" API memory and CPU usage is > 70%, enabled HTTPS and FinOps insights with OpenCost.
### Task 3: Setup and configured FluentBit to collect "BeStrong" API logs and made the logs from FluentBit available in Grafana.

### In this table we describe the tools, that used for this tasks.
| №    | Name of the tool | Description                                                                      |
| :--- |  :-----:         | :----                                                                         |
| 1    | Azure Portal     | A web-based interface for managing, monitoring, and configuring Azure resources. |
| 2    | Terraform        | A tool for creating, managing, and automating infrastructure as code (IaC).      |
| 3    | Azure Kubernetes Service |A managed service for deploying, scaling, and managing containerized applications using Kubernetes. |
| 4    | Helm & Helm Charts | A package manager for Kubernetes that uses Charts to simplify the deployment of complex applications. |
| 5    | Bash Scripts | Scripts written to automate tasks and execute commands in Linux/Unix environments. |

### The diagram of the system, which was configured(for this tasks).
![Diagram of the system](/diagrams/bestorng-architecture.jpeg)

# Task №1 report

### View of our diagram of resources that interact with AKS
![AKS diagram](/screenshots/diagram1.png)

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
kubectl create namespace bestrong-api
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

### templates - folder with Kubernetes resource templates
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

### After that we apply our ClusterIssuer which is used by cert-manager to obtain or renew SSL/TLS certificates from Let`s Encrypt. 
### How it works:
### When a certificate request is made, cert manager uses the HTTP-01 challenge to prove ownership of the domain. It also creates a temporary Ingress to serve a token at a specific URL
### When the token is validated by Let`s Encrypt, our certificate is issued and stored in a K8S secret. 
```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: {{ .Values.clusterIssuer.name }}
  namespace: {{ .Values.clusterIssuer.namespace }}
spec:
  acme:
    server: {{ .Values.clusterIssuer.acme.server }}
    email: {{ .Values.clusterIssuer.acme.email }}
    privateKeySecretRef:
      name: {{ .Values.clusterIssuer.acme.privateKeySecretRefName }}
    solvers:
      - http01:
          ingress:
            class: {{ .Values.clusterIssuer.acme.solver.ingressClass }}
```
```
clusterIssuer:
  name: letsencrypt-prod
  namespace: bestrong-ingress
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: stephansnigur@gmail.com
    privateKeySecretName: letsencrypt-prod-issuer-key1
    solver:
      ingressClass: public

```

### After creating ClusterIssuer we created a Certificate resource to obtain an certificate for our domain bestrong-api.pp.ua.
### How it works: 
### We refer to our ClusterIssuer that cert-manager should use to request the certificate for our domain name. And when request is approved  that the issued certificate and its private key will be stored in secret named userapi-tls. In the future this secret will be used in Ingress resource to manage SSL certificate specified to our host.
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ .Values.certificate.name }}
  namespace: {{ .Values.certificate.namespace }}
spec:
  secretName: {{ .Values.certificate.secretName }}
  issuerRef:
    name: {{ .Values.certificate.issuerRef.name }}
    kind: {{ .Values.certificate.issuerRef.kind }}
  dnsNames:
    {{- range .Values.certificate.dnsNames }}
    - {{ . }}
    {{- end }}
  usages:
    {{- range .Values.certificate.usages }}
    - {{ . }}
    {{- end }}
certificate:
  name: ingress-nginx-tls1
  namespace: bestrong-ingress
  secretName: userapi-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - bestrong-api.pp.ua
  usages:
    - digital signature
    - key encipherment
    - server auth
```

## 4) Deploy "BeStrong" API to AKS via Azure DevOps using Helm charts. Helm charts should be versioned, packed and stored in Azure Container Registry.
### To accomplish this task, we have created a pipeline that deploys terraform architecture, do the Helm packaging and building, push the charm and deploys to AKS.
```
### CI/CD pipeline for deploying a Helm chart to AKS using Azure DevOps

trigger:
  branches:
    include:
      - '*'

pr:
  branches:
    include:
      - main

variables:
  - group: AllCredentials

stages:
  - stage: Build
    displayName: Build, Init, Validate and Apply Terraform
    jobs:
      - job: HelmPackageAndTerraformValidate
        displayName: Helm Packaging and Terraform Validation
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            displayName: Install Terraform
            inputs:
              terraformVersion: '1.9.8'

          - task: HelmInstaller@1
            displayName: Install Helm
            inputs:
              helmVersion: 'latest'

          - task: AzureCLI@2
            displayName: Azure Login
            inputs:
              azureSubscription: '$(ARM_SERVICE_CONNECTION)'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                set -e
                echo "Logging in to Azure..."
                az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID)
                az account set --subscription $(ARM_SUBSCRIPTION_ID)
                az account show
                
          - task: TerraformTaskV4@4
            displayName: 'Terraform Init'
            inputs:
              provider: 'azurerm'
              command: 'init'
              environmentServiceNameAzureRM: '$(ARM_SERVICE_CONNECTION)'
              workingDirectory: './terraform'
              backendServiceArm: 'bestrongserv'
              backendAzureRmResourceGroupName: 'bestrong-aks'
              backendAzureRmStorageAccountName: 'bestrongsaapi'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'terraform.tfstate'

          - task: TerraformTaskV4@4
            displayName: 'Terraform Validate'
            inputs:
              provider: 'azurerm'
              command: 'validate'
              environmentServiceNameAzureRM: '$(ARM_SERVICE_CONNECTION)'
              workingDirectory: './terraform'

          - task: TerraformTaskV4@4
            displayName: 'Terraform Apply'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              environmentServiceNameAzureRM: '$(ARM_SERVICE_CONNECTION)'
              workingDirectory: './terraform'

          - task: Bash@3
            displayName: Package Helm Chart
            inputs:
              targetType: 'inline'
              script: |
                set -e
                cd ./helm-charts
                helm lint
                helm package .


  - stage: BuildAndPush
    displayName: Build and Push Artifacts
    jobs:
      - job: HelmChartAndContainerBuild
        displayName: Build Helm Chart and Push to ACR
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: AzureCLI@2
            displayName: Azure Login
            inputs:
              azureSubscription: '$(ARM_SERVICE_CONNECTION)'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                set -e
                echo "Logging in to Azure..."
                az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID)
                az account set --subscription $(ARM_SUBSCRIPTION_ID)
                az acr login -n $(ACR_NAME)

          - task: Bash@3
            displayName: Push Helm Chart to ACR
            inputs:
              targetType: 'inline'
              script: |
                set -e
                cd ./helm-charts
                helm lint
                helm package .
                helm push $(HELM_CHART_NAME)-*.tgz oci://$(ACR_NAME).azurecr.io/helm

  - stage: DeployToProduction
    displayName: Deploy to Production
    dependsOn:
      - Build
      - BuildAndPush
    condition: succeeded()
    jobs:
      - deployment: DeployToAKS
        displayName: Deploy to AKS
        pool:
          vmImage: 'ubuntu-latest'
        environment: 'Production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureCLI@2
                  displayName: Azure Login and AKS Deployment
                  inputs:
                    azureSubscription: '$(ARM_SERVICE_CONNECTION)'
                    scriptType: bash
                    scriptLocation: inlineScript
                    inlineScript: |
                      set -e
                      echo "Logging in to Azure..."
                      az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID)
                      az account set --subscription $(ARM_SUBSCRIPTION_ID)
                      az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_NAME)
                    
                      echo "Logging in to ACR..."
                      az acr login --name $(ACR_NAME)

                      helm registry login $(ACR_NAME).azurecr.io \
                        -u $(ARM_CLIENT_ID) \
                        -p $(ARM_CLIENT_SECRET)

                      echo "Pulling Helm chart..."
                      helm pull oci://$(ACR_NAME).azurecr.io/helm/$(HELM_CHART_NAME) --version 0.1.0
```

![Build, Init, Validate and Apply](/screenshots/pipeline1.png)
![Build, Push and Deploy](/screenshots/pipeline2.png)

## 5) 2 instances of "BeStrong" API should be running at the same time.
### This is our implementation of blue-green deployment strategy. Here we created two separate, but identical environments. One environment (blue) is running the current application version and one environment (green) is running the new application version. Using this deployment strategy we have increased our application availability and reduced deployment risk by simplifying the rollback process if a deployment fails.
```
deployments
  - name: blue-dep
    namespace: bestrong-ingress
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
  - name: green-dep
    namespace: bestrong-ingress
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
```
```
{{- range .Values.deployments }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
spec:
  replicas: {{ .replicas }}
  selector:
    matchLabels:
      app: {{ .labels.app }}
      color: {{ .labels.color }}
  template:
    metadata:
      labels:
        app: {{ .labels.app }}
        color: {{ .labels.color }}
    spec:
      containers:
        - name: {{ .container.name }}
          image: {{ .container.image }}
          imagePullPolicy: {{ .container.imagePullPolicy }}
          ports:
            - containerPort: {{ .container.port }}
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: {{ .container.environment }}
{{- end }}
```
![Bestrong Blue Deployment](/screenshots/bestrong-blue.png)
![Bestong Green Deployment](/screenshots/bestrong-green.png)

### Deployment that uses images labeled as green
![Deployment that uses images labeled as green](/screenshots/images_green.png)

# Task №2 Report
## 1) Setup Prometheus and Grafana in your AKS cluster.
### Prometheus is a powerful tool for monitoring and alerting, but to get the most out of it, you need to understand how to use recording rules and alerting rules effectively. This blog will explore what these rules are, why they are necessary, how they benefit your Prometheus environment, and provide practical examples of setting them up.
![Prometheus Diagram](/screenshots/prom_diagram.png)
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```
![Services and Ingresses](/screenshots/services_ingresses.png)

### Retrieving credentials to login to the Grafana Dashboard
```
kubectl get secret -n monitoring prometheus-grafana -o=jsonpath='{.data.admin-user}' |base64 –d
kubectl get secret -n monitoring prometheus-grafana -o=jsonpath='{.data.admin-password}' |base64 –d
```


## 2) Setup Prometheus Alert when "BeStrong" API memory and CPU usage is > 70%
```
 Defining rules:
 	# High CPU Usage Alert
         - alert: BeStrongAPIHighCPUUsage
          expr: |
            (100 * avg(irate(container_cpu_usage_seconds_total{pod=~"blue-dep.*"}[2m]))) > 70
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage detected for BeStrong API"
            description: "The BeStrong API is using more than 70% of the allocated CPU for more than 2 minutes. Pod: {{ $labels.pod }}, Node: {{ $labels.node }}."
                   # High Memory Usage Alert
        - alert: BeStrongAPIHighMemoryUsage
          expr: |
              (100 * sum(container_memory_working_set_bytes{pod=~"blue-dep.*"}) / sum(machine_memory_bytes)) > 70
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "High memory usage detected for BeStrong API"
            description: "The BeStrong API is using more than 70% of the allocated memory for more than 2 minutes. Pod: {{ $labels.pod }}, Node: {{ $labels.node }}."
```

### Here, we set two rules that Prometheus will use to alert us when our API will use greater 70% of CPU and Memory longer than 2 minutes.

### Resources in inactive state:
![Resources in inactive state](/screenshots/inactive-status-resources.png)

### Resources in pending and alerting state:
![Resources in pending and alerting state](/screenshots/active-resources.png)

## 3) Make Grafana accessible from the Internet
### We made grafana accessible over the internet by using subdomain “graf”. We also requested a certificate so HTTPS is enabled
![ Make Grafana accessible from the Internet](/screenshots/grafana-overview.png)
```
 - host: graf.bestandstrong.pp.ua  #Our Grafana
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80 
```

## 4)  Enable HTTPS (you may use fake SSL certs from cert-manager, the same way as in the previous task)
```
  tls:
    - hosts:
      - bestandstrong.pp.ua
      - graf.bestandstrong.pp.ua
      secretName: userapi-tls-monitoring
```
![Certificate in Grafana](/screenshots/grafana-cert.png)


## 5) Enable some FinOps insights:
### 5.1) Setup OpenCost to monitor both your AKS cluster and your Azure subscription.
```
helm install prometheus --repo https://prometheus-community.github.io/helm-charts prometheus \
  --namespace bestrong-api --create-namespace \
  --set prometheus-pushgateway.enabled=false \
  --set alertmanager.enabled=false \
  -f https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/prometheus/extraScrapeConfigs.yaml
```
![OpenCost setup](/screenshots/opencost-cert.png)

### 5.2) Setup Ingress for OpenCost dashboard with basic authentication to protect your OpenCost Enable HTTPS (you may use fake SSL certs from cert-manager, the same way as in previous task)
```
    - host: opencost.bestandstrong.pp.ua  #Our OpenCost
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: opencost
              port:
                number: 90
  tls:
    - hosts:
        - bestandstrong.pp.ua
        - opencost.bestandstrong.pp.ua
      secretName: userapi-tls-monitoring

```

### 5.3) Configuration OpenCost
### Supply Azure Service Principal details to OpenCost
```
{
    "subscriptionId": "<Azure Subscription ID>",
    "serviceKey": {
        "appId": "<Azure AD App ID>",
        "displayName": "OpenCostAccess",
        "password": "<Azure AD Client Secret>",
        "tenant": "<Azure AD Tenant ID>"
    }
}
```
### Edit deployment.yaml file
#### A volumes object under spec.template.spec, with a service-key-secret volume referring to the azure-service-key secret:
```
     volumes:
        - name: service-key-secret
          secret:
            secretName: azure-service-key
```
### A volumeMounts object under the opencost container (at spec.template.spec.containers[0]) that mounts the service-key-secret volume:
```
          volumeMounts:
            - mountPath: /var/secrets
              name: service-key-secret
```
### Create cloud-integration.json file
```
{
  "azure": {
    "storage": [
      {
        "subscriptionID": "<SUBSCRIPTON_ID>",
        "account": "<STORAGE_ACCOUNT>",
        "container": "<STORAGE_CONTAINER>",
        "path": "<CONTAINER_PATH>",
        "cloud": "<CLOUD>",
        "authorizer": {
          "accessKey": "<STORAGE_ACCESS_KEY>",
          "account": "<STORAGE_ACCOUNT>",
          "authorizerType": "AzureAccessKey"
        }
      },
      }
    ]
  }
}
```

