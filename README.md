# Jenkins Fargate agent
Provisioning AWS infrastructure to run a Jenkins controller with ECS Fargate containers for job execution.


## Usage
### 📦 Requirements

- OpenTofu >= 1.12
- Ansible

### Infrastructure Provisioning
#### AWS Login
In order to run the playbook, we have to be logged in on our AWS account. We can either log in via the awscli or by setting the following environmental variables:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

#### OpenTofu Initialization 
Make sure you have `versions.tf` file locally with **hashicorp/aws** and **hashicorp/local** providers and run the following command to install them:
```bash
tofu init
```

Make sure to add the list of task definitions that you want in the `task_definitions` variable. A list with a single task definition,for a jenkins agent that will be used to in building and pushing container images job executions, can look like this:
```tf
task_definitions = [
      {
            name_tag = "kaniko-builder"
            family_name = "image-builder"
            container = {
                  image = <container-registry>
                  cw_name = var.cloudwatch_name
            },
            cpu = "2048"
            memory = "4096"
      }
  ]
```
with a container imge like:
```Dockerfile
FROM gcr.io/kaniko-project/executor AS kaniko
FROM jenkins/inbound-agent

USER root
COPY --from=kaniko /kaniko /kaniko
```

#### Apply .tf Files
Make sure you have the `main.tf` before running the following command to start the provisioning procedure:
```bash
tofu apply
```
This command will list all the resources to be provisioned, take a look and if everything looks fine, type yes.

If you do not want open tofu to list the resources and wait for you input, you can add the -auto-approve flag:
```bash
tofu apply -auto-approve
```

### Setting up a Jenkins controller
Make sure that you modify the `hosts.yml` file to make `jenkins_controller` host point to your EC2 instance with the right private ssh key. Then you can ran:
```bash
ansible-playbook playbooks/register.yml --tags controller
```

#### Creating admin credentials
Visit jenkins UI on port 8080 and follow the instructions until you are asked to enter a username and a password, create this credentials and store them securely.

### Registering Jenkins agents
#### Installing plugins
Before we can register any agent, we need to install two plugins:
- **Amazon Elastic Container Service (ECS) / Fargate (ID: amazon-ecs)**: Allows jenkins controller to communicate with our AWS ECS cluster to start and destroy tasks.
- **Configuration as Code (ID: configuration-as-code)**: Allows us to configure the jenkins controller with the use of yaml files, without having to use the UI. This will make the registration of ECS agents really easy.

We can install these plugins by running the playbook:
```bash
ansible-playbook playbooks/plugins.yml
```

#### Adding agents
All the agents should be in `group_vars/all.yml` under the agents list.

```bash
ansible-playbook playbooks/register.yml --tags agent
```