



<div align="center">

  <h1 align="center">ECS Training</h3>

</div>

<!-- ABOUT THE PROJECT -->
## Preparing Cloud 9

1. Go to https://console.aws.amazon.com/cloud9/.
2. Choose Create environment.
3. Provide a name and leave the default options as default  
4. In the list of environments chose the option Open 
5. To install terraform run the following commands

 ``` 
 wget https://releases.hashicorp.com/terraform/1.7.4/terraform_1.7.4_linux_amd64.zip
 unzip terraform_1.7.4_linux_amd64.zip
 sudo mv terraform /usr/local/bin
 ```

 6. Install session manager plugin
 ```
 sudo curl --silent --location "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
 sudo yum install session-manager-plugin.rpm
 ```

<!-- ABOUT THE PROJECT -->
## Push and Pull and Image to ECR

### Create the repository
1. Open the Amazon ECR console at https://console.aws.amazon.com/ecr/.
2. Choose Get Started.
3. For Visibility settings, choose Private.
4. For Repository name, specify a name for the repository hello_app.
5. For Tag immutability, choose the tag mutability setting for the repository.

### push the image
1. Create a Folder hello_app
2. Inside the folder create a python script hello_world.py with the following content
```
print("Hello World")
```    
3. In the Same Folder create a dockerfile with the following content
```
# Use an official Python runtime as a parent image
FROM python:3.8

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app

COPY ./hello_world.py /app

# Set the entry point to run the scripts
ENTRYPOINT ["python", "hello_world.py"]
```
4. Build the image 
docker build -t my-hello-world .
5. Select the repository and click the button view push commands
* Authenticate with the repository
   
 ```
 aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <account_number>.dkr.ecr.<region>.amazonaws.com
 ```  
   * Tag the image
```
docker tag my-hello-world <account_number>.dkr.ecr.<region>.amazonaws.com/hello_app:latest

```

   * Push the image
```
docker tag my-hello-world <account_number>.dkr.ecr.<region>.amazonaws.com/hello_app:latest

```
## Create networking, cluster and ECS service

1. Clone the training repository.

```
git clone https://github.com/dianibar/ecs-training.git
```
2. Open the file ecs-training/ecs-cluster/complete/main.tf and replace <user> 
the string with your own name

```
name   = "<user>-${basename(path.cwd)}"
container_cw_log_group = "/aws/ecs/<user>/ecsdemo-frontend"
```
2. Apply the terraform template.
```
cd ecs-training/ecs-cluster
terraform init
terraform apply
```
3. Explore the cluster and the resources created.

## Access the container using ECS Exec

Open the file ecs-training/ecs-cluster/complete/main.tf and do the following 
modifications:

1. Modify the cluster to configure the CloudWatch log group where the exec 
   will be logged
    ```
   ...
   cluster_name = local.name

   cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/ecs-exec-demo"
      }
    }
  }
  
  services = {
  ... 
  ```
2. In the container enable ecs-exec using 'enable_execute_command = true'

```
    ecsdemo-frontend = {
      enable_execute_command = true
      cpu    = 1024
```

3. Add permissions to the service task to access ssm and CloudWatch Logs:

```
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        },
        {
          actions   = ["logs:CreateLogStream", 
            "logs:PutLogEvents", 
            "logs:DescribeLogStreams"]
          resources = ["*"]
        },
        {
          actions   = ["ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"]
          resources = ["*"]
        }

      ]
```
4. Apply the changes

```
terraform apply
```
5. Access the container

```
 aws ecs execute-command \
  --region ap-southeast-2 \
  --cluster <clustername> \
  --task <taskid> \
  --container <containername> \
  --command "/bin/bash" \
  --interactive
```

## Add Fargate Spot instances

1. Add the capacity provider to the cluster

```
...
 cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/ecs-exec-demo"
      }
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }

  services = {
...
```
2. Open the file ecs-training/ecs-cluster/complete/main.tf and add the capacity provider to the service:

```
  services = {
    ecsdemo-frontend = {
      capacity_provider_strategy = {
        fargate = {
          capacity_provider = "FARGATE"
          weight            = 1
          base              = 1
        }
        spot = {
          capacity_provider = "FARGATE_SPOT"
          weight            = 1
        }
      }
```
2. Apply the changes

``` 
terraform apply
```

3. Modify the desired_count to four
```
    ecsdemo-frontend = {
    
      capacityProviderStrategy = {
          "capacityProvider": "FARGATE_SPOT",
          "weight": 1,
          "base": 0
      }
      capacityProviderStrategy = {
          "capacityProvider": "FARGATE",
          "weight": 1,
          "base": 1
      }
      
      enable_execute_command = true
      
      desired_count          = 4
      cpu                    = 1024

5. Apply the changes
``` 
terraform apply
```
## Create a scheduled task in the EventBridge Scheduler console

1. Open the Amazon EventBridge Scheduler console at https://console.aws.amazon.com/scheduler/home.

2. On the Schedules page, choose Create schedule.

3. On the Specify schedule detail page, in the Schedule name and description section.
For Schedule group choose default.

4. Choose your schedule options. https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html#cron-based

5. Choose Next.

6. On the Select target page, do the following:

    * Choose All APIs, and then in the search box enter ECS.

    * Select Amazon ECS.

    * In the search box, enter RunTask, and then choose RunTask.

    * For ECS cluster, choose the cluster.

   * For ECS task, choose the task definition to use for the task.

   * To use a launch type, expand Compute options, and then select Launch type. Then, choose the launch type FARGATE.

   * Leave Platform version empty. If there is no platform specified, the LATEST platform version is used.

   * For Subnets, choose one of the public subnets 

   * For Security groups, enter the security group IDs for the VPC the one with the port  80 open to everywhere.

   * Enable Auto-assign public IP

   * Leave the default for the other options

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Getting started with Cloud 9](https://aws-quickstart.github.io/workshop-terraform-modules/40_setup_cloud9_ide/40_start_cloud9.html)
* [Running a Batch job using AWS Batch and Docker Image](https://sivachandanc.medium.com)
* [Using Amazon ECS Exec for debugging](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html)


<p align="right">(<a href="#readme-top">back to top</a>)</p>