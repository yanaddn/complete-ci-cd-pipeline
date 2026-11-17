## Repository branches (latest to oldest)
- [terraform](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/terraform) – Complete Jenkins pipeline: builds the Java Maven app, pushes the Docker image to Docker Hub, provisions an EC2 server with Terraform and deploys the app there with Docker Compose
- [aws-docker-compose](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/aws-docker-compose) – Deploying the app to EC2 with Docker Compose
- [app-versioning](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/app-versioning) – Incrementing the app version automatically in the Jenkins pipeline
- [aws-integration](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/aws-integration) – Deploying the app container to EC2 from Jenkins over SSH
- [jenkins-shared-lib](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/jenkins-shared-lib) – Using a Jenkins Shared Library
- [full-pipeline](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/full-pipeline) – Building the app and pushing the image to Docker Hub
- [jenkins-jobs](https://github.com/yanaddn/jenkins-pipeline-docker-aws/tree/jenkins-jobs) – Installing Jenkins and creating the first jobs

## Multi-branch pipeline on Jenkins 
<img width="1239" height="758" alt="Screenshot 2026-09-25 at 11 14 29" src="https://github.com/user-attachments/assets/421601f4-b355-432f-9ba8-0d374794ce1d" />

## Infrastructure with Terraform

```mermaid
flowchart TB
    dev["Developer"] -->|git push| gh["GitHub repo"]
    gh -->|checkout| jenkins

    subgraph jenkinsHost["Jenkins host - EC2"]
        jenkins["Jenkins in Docker"]
    end

    jenkins -->|push image| hub[("Docker Hub<br/>yanadidun/java-maven-app")]
    jenkins -->|terraform apply| vpc
    jenkins <-->|state + lock| s3[("S3 bucket<br/>myapp/state.tfstate")]
    jenkins -->|"ssh / scp :22"| ec2

    subgraph aws["AWS eu-west-3"]
        subgraph vpc["VPC 10.0.0.0/16"]
            igw["Internet Gateway"]
            rtb["Route table<br/>0.0.0.0/0 to IGW"]
            subgraph subnet["Subnet 10.0.1.0/24 - eu-west-3a"]
                ec2["EC2 t3.micro - Amazon Linux 2<br/>Docker + docker-compose<br/>java-maven-app :8080<br/>postgres :5432"]
            end
            sg["Security group<br/>22: my IP + Jenkins IP<br/>8080: anywhere"]
        end
    end

    ec2 -->|pull image| hub
    user["Browser"] -->|"http :8080"| igw
    igw --> ec2
    sg -.-> ec2
    rtb -.-> subnet
```
