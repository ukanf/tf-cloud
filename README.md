# This Repo

This repo contains code for a autopilot GKE cluster setup using Terraform.

We create the VPC -> Subnet

## GitOps

Best practices: [GitOps best practices](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/concepts/gitops-best-practices)

ACM:

- hierarchical: [hierarchical repo](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/concepts/hierarchical-repo)
- unstructured: [unstructured repo](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/how-to/unstructured-repo)

Fleets: [Fleets talk](https://www.youtube.com/watch?v=IUQZbUgCiWs)

## How to use DEV

First:
```
cd deployments/dev
terraform init
```

Double check the variables

### TODO now

create key for SA
link key to repo so the workflow that deploys works
