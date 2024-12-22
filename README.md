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
