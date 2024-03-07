



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
* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
* [Malven's Grid Cheatsheet](https://grid.malven.co/)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search)

<p align="right">(<a href="#readme-top">back to top</a>)</p>