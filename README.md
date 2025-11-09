# This Repo

This repo contains code for:
- A project
- Workload Identity Federation setup for GitHub
- A GKE Clusters
- All the IAM setup for things to work so we can use GitHub Actions (in [another repo](https://github.com/ukanf/acm-atlantis-poc)) to:
  - Build and publish an OCI artifact to AR created here
  - (Optional) Deploy/update a new OCI artifact to be synced to the cluster. I actually didnt like this option that much because the TF file gets outdated - we could no reference a OCI image here, but still... not convinced I like it.. So we are managing the 

## GitOps

Best practices: [GitOps best practices](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/concepts/gitops-best-practices)

ACM:

- hierarchical: [hierarchical repo](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/concepts/hierarchical-repo)
- unstructured: [unstructured repo](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/how-to/unstructured-repo)
  - Googles recommendation to use unstructured: [link here](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/concepts/gitops-best-practices#use-unstructured-repo)

Fleets: [Fleets talk](https://www.youtube.com/watch?v=IUQZbUgCiWs)

## How to use DEV

First:
```
cd deployments/dev
terraform init
```

# Variables

create a `<name>.tfvars` file with:

```
billing_account_id = "....."
```

or just provide it when running `plan/apply`

So (choose one...):
1. `tf apply -var-file=<name>.tfvars`
2. `tf apply -var "billing_account_id=<my_billing_account_id>"`



# TODO
1. Add a dependency so WIF gets created before the clusters... so