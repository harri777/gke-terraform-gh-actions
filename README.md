<h1 align="center">Create GKE Cluster with Terraform and CI/CD Github Actions</h1>

This is a simple Flask application with a request counter using Redis. Requests must contain an authorization token and its value is defined through the environment variable `AUTH_TOKEN`.

## Tools / providers
- Google cloud
- ISTIO service mesh
- Terraform cloud


## Dependencies
- [Valid account GCP](https://cloud.google.com/)
- [Account DockerHub](https://hub.docker.com/)
- [Account Terraform Cloud](https://app.terraform.io/session)

To use the project, follow the **4 step** below:

## 1. Google cloud*
- Make sure you have a valid provider account.
- Create a project.
- Select the project from the top menu.
- Copy the project ID to a safe area, we will use it in the next steps.
<img width="761" alt="Captura de Tela 2021-09-30 às 08 42 24" src="https://user-images.githubusercontent.com/16891662/135449055-ff015a8d-0bc4-4fd2-8486-8670f80382f1.png">

- Go to the menu on the right `IAM e ADMIN` > `Service Account` and create a service account for the project with the roles:

  - `Kubernetes Engine Admin`
  - `Compute Storage Admin`
  - `Service Account User`
  - `Compute Network Admin`
  - `Service Usage Admin`
  - `Compute Admin`

- After the service account created, on the same screen go to `actions` > `Manage keys`
<img width="244" alt="Captura de Tela 2021-09-29 às 12 59 20" src="https://user-images.githubusercontent.com/16891662/135305783-35b0e008-b7c8-4f34-be9d-5f9661adfcf8.png">

- Then go to `ADD KEY` > `CREATE NEW KEY` > `JSON` generate a new key and download it - Keep it in a safe place, we will use it in the next steps.


## 2. Terraform Cloud*
Terraform Cloud is being used for versioning the `tfstate`.
- Make sure you have a valid account on [Terraform Cloud](https://app.terraform.io/session)
- Create a `organization`.
- Create a `workspace` with the name you want with the type `API-Driver Workflow`.
- Click on `Variables` and `Environment Variables` add the secrets:

- `TF_VAR_project`       -> project id GCP
- `TF_VAR_google_sa_key` -> service account key .json (Donwload made in the GCP step, open the file, copy and paste the content)
  - PS: If you have trouble adding ess secret in terraform cloud, as it is JSON, use the command `tr -d '\n' < arquivo.json` to convert from multi line to single line.
  - Mark as sensitive.
- `TF_VAR_cluster_name`  -> Name you want for your cluster (this name will also be used in GH Actions)(*)


- Then we will generate the token for use in Github Actions
  - Click on settings in the top menu > `API Tokens`in the left side menu > click on `create a user API token.`
  ![Captura de Tela 2021-09-29 às 13 39 55](https://user-images.githubusercontent.com/16891662/135312184-0ab0057d-065f-465b-9774-5ca547c3649c.png)

  - Copy the token to a safe place (after closing the modal it will not be possible to see it again)

## 3. Github Actions*
- Github Actions is being used for CI and CD. It is necessary to create the environment variables.
- In your repository, go to `settings` > `secrets` > `New repository secret` then create the following secrets like `Actions secrets`:
```
- DOCKER_USER      -> Docker hub user
- DOCKER_PWD       -> Docker hub password
- TF_API_TOKEN     -> Token copied from Terraform Cloud
- GKE_CLUSTER_NAME -> Name you want (same name placed in terraform cloud)
- GKE_ZONE         -> us-central1-c
- GKE_PROJECT      -> project id GCP
- GKE_SA_KEY       -> service account key .json from GCP
- AUTH_TOKEN       -> 123456 (test token for app authorization)
```

## 4. Remote state configuration*
- Terraform does not allow the use of environment variables in the remote state config, so it is necessary to change it.
- Change file `terraform/remote-state.tf`
```
terraform {
  backend "remote" {
    organization = <organization name created in terraform cloud>

    workspaces {
      name = <workspace name created in terraform cloud>
    }
  }
}
```
### Make a commit and push to the master branch
- The terraform apply pipeline will be triggered.

### Configuration test
- Run the terraform-check.yml pipeline manually to verify the configuration is correct.

### See the IP assigned to the ingress
- Go to the google cloud console > then click on `Kubernetes Engine` > Click under your cluster name
- Click on `Services e Ingress` in the side menu
<img width="478" alt="Captura de Tela 2021-09-29 às 22 19 13" src="https://user-images.githubusercontent.com/16891662/135370733-9653bdbe-abcb-4090-a57f-e9d5b9e172f5.png">

- See Ip `Endpoints` with type `LoadBalancer`
<img width="629" alt="Captura de Tela 2021-09-29 às 22 19 39" src="https://user-images.githubusercontent.com/16891662/135370813-20b1e62b-bf08-49d6-8a49-41e0d8df8dc2.png">

### To test:
```
$ curl -H "Authorization: Token 123456" http://<IP INGRESS>
```


<br /><br />

## Detailing

### Creating the k8s cluster and installing ISTIO with terraform
- Cluster creation as well as service mesh installation is linked to the CI/CD flow.
- The trigger is fired **when something inside the `path` `/terraform`** is changed and **merged into the `master` branch**.

### Deployment ISTIO Gateway
- ISTIO Gateway deployment has been separated and linked to the CI/CD flow.
- The trigger is fired **when something inside the `path` `./k8s/istio`** is changed and **merged into the `master` branch**.

### Deployment REDIS
- The redis deployment has been separated and linked to the CI/CD flow.
- The trigger is fired **when something inside the `path` `./k8s/redis`** is changed and **merged into the `master`** branch.
- An SSD volume is used in the cloud provider to provide the persistent volume.

### Deployment APP
- The app deployment has been separated and linked to the CI/CD flow.
- The trigger is always fired.

## Observability proposal
- To visualize Istio's configuration, application traffic and metrics I would use `Kiali`, it is an easy to visualize tool if well configured and it is already integrated with the service mesh used in the challenge.
- For cluster monitoring: Prometheus and Grafana.


## To use the local application
```shell
$ docker-compose up -d
$ curl -H "Authorization: Token 123456" http://localhost:8000
```
### To use local terraform
- Make sure you have terraform installed.

```shell
$ cd/terraform
$ terraform init
$ terraform apply
```

### To deploy the local app
```shell
$ cat k8s/api/api-deployment.yml | envsubst | kubectl apply -f -
```

## Author
- harrisson.biaggio@owasp.org
