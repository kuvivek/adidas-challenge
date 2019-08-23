
Adidas Challenge
================

The current approach to solve the issue of Continous Integration, Packaging, Unit Test and scaling it on the Production can be achieved via multiple tools: 

 - Docker image creation, which also performs the fresh git clone from the git repository within the container. 
 - Setting up a deployment plan in Kubernetes, So that scalability can be addressed.
 - Automation via Forge.

Kubernetes has all the required feature. However, it does not run any source code directly. It only performs orchestration of the containers. Before we go further it is important to understand what container is: 

A container contains 
 - a compiled version of a source code 
 - any/all runtime dependences necessary to run the source code.

I will be using a simple web application as mentioned in the Github link: [adidas challenge](https://github.com/paulvassu/adidasChallenge), In order to package this webapp in a Docker container, a Dockerfile need to be created.

For implementing build of the source code I have written a Dockerfile which implements multistage builds. 

It starts with the base image of alpine linux, with git installed on it. Then changing the workdir to /app. This creates the /app folder and then execute the git clone command to download the source code. So the first stage is completed with the source code download from the github repository.
 
The second stage is a builder stage wherein, the source code downloaded from the clone stage is build. This builder stage starts with the official gradle docker image for java 8 jdk. Then copy the source code downloaded from the previous stage to the new image and executing the gradlew build command in the builder stage as suggested by the [README.md](https://github.com/paulvassu/adidasChallenge/blob/master/README.md)  file. Next is to execute the unit test cases.

The third stage is based on the offical OpenJDK 8 image. Here only JRE is required because the application is already built. I have used the recently introduced jre-slim Docker image provided by OpenJDK. and then exposing the port 8080, followed creating an /app directory in the openjdk with only jre image and copying the build artifact to the /app folder. And Lastly start the java web app service to run on port 8080.

Building the image is done using a plain Docker build command:

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$  sudo docker build -t adidas-demo:v1 . 
    Sending build context to Docker daemon  14.34kB
    Step 1/13 : FROM alpine/git as clone
    latest: Pulling from alpine/git
    6c40cc604d8e: Pulling fs layer
    d838eb6031fe: Pulling fs layer
    3e552758964b: Pulling fs layer
    3e552758964b: Verifying Checksum
    3e552758964b: Download complete
    6c40cc604d8e: Verifying Checksum
    6c40cc604d8e: Download complete
    d838eb6031fe: Verifying Checksum
    d838eb6031fe: Download complete
    6c40cc604d8e: Pull complete
    d838eb6031fe: Pull complete
    3e552758964b: Pull complete
    Digest: sha256:8f5659025d83a60e9d140123bb1b27f3c334578aef10d002da4e5848580f1a6c
    Status: Downloaded newer image for alpine/git:latest
     ---> a1d22e4b51ad
    Step 2/13 : WORKDIR /app
     ---> Running in 70c8dcc05ccf
    Removing intermediate container 70c8dcc05ccf
     ---> ee1be17518b5
    Step 3/13 : RUN git clone https://github.com/paulvassu/adidasChallenge
     ---> Running in c529796794d1
    Cloning into 'adidasChallenge'...
    Removing intermediate container c529796794d1
     ---> c3cc1cc16834
    Step 4/13 : FROM gradle:5.6.0-jdk8 as builder
    5.6.0-jdk8: Pulling from library/gradle
    35c102085707: Pulling fs layer
    251f5509d51d: Pulling fs layer
    8e829fe70a46: Pulling fs layer
    6001e1789921: Pulling fs layer
    4dfc4d19ec09: Pulling fs layer
    0ad170d59552: Pulling fs layer
    e1c744996d22: Pulling fs layer
    961d51c93833: Pulling fs layer
    96b98c11759d: Pulling fs layer
    6001e1789921: Waiting
    4dfc4d19ec09: Waiting
    0ad170d59552: Waiting
    e1c744996d22: Waiting
    961d51c93833: Waiting
    96b98c11759d: Waiting
    8e829fe70a46: Download complete
    251f5509d51d: Verifying Checksum
    251f5509d51d: Download complete
    6001e1789921: Verifying Checksum
    6001e1789921: Download complete
    4dfc4d19ec09: Verifying Checksum
    4dfc4d19ec09: Download complete
    e1c744996d22: Verifying Checksum
    e1c744996d22: Download complete
    35c102085707: Verifying Checksum
    35c102085707: Download complete
    35c102085707: Pull complete
    251f5509d51d: Pull complete
    8e829fe70a46: Pull complete
    6001e1789921: Pull complete
    4dfc4d19ec09: Pull complete
    961d51c93833: Verifying Checksum
    961d51c93833: Download complete
    96b98c11759d: Verifying Checksum
    96b98c11759d: Download complete
    0ad170d59552: Verifying Checksum
    0ad170d59552: Download complete
    0ad170d59552: Pull complete
    e1c744996d22: Pull complete
    961d51c93833: Pull complete
    96b98c11759d: Pull complete
    Digest: sha256:625aa7e2aed7ea67aa93229037463c12bfb8fe745ec14f80152394b494947564
    Status: Downloaded newer image for gradle:5.6.0-jdk8
     ---> 574bfd4bb73f
    Step 5/13 : COPY --from=clone --chown=gradle:gradle ./app/adidasChallenge /home/gradle/src
     ---> 4b076e753974
    Step 6/13 : WORKDIR /home/gradle/src
     ---> Running in 767982cc3919
    Removing intermediate container 767982cc3919
     ---> 97e36516fe7c
    Step 7/13 : RUN ./gradlew build
     ---> Running in 4658b0e3cf34
    Downloading https://services.gradle.org/distributions/gradle-5.4.1-bin.zip
    ...................................................................................
    
    Welcome to Gradle 5.4.1!
    
    Here are the highlights of this release:
     - Run builds with JDK12
     - New API for Incremental Tasks
     - Updates to native projects, including Swift 5 support
    
    For more details see https://docs.gradle.org/5.4.1/release-notes.html
    
    Starting a Gradle Daemon (subsequent builds will be faster)
    > Task :compileJava
    > Task :processResources
    > Task :classes
    > Task :bootJar
    > Task :jar SKIPPED
    > Task :assemble
    > Task :compileTestJava
    > Task :processTestResources NO-SOURCE
    > Task :testClasses
    
    > Task :test
    2019-08-23 15:21:17.706  INFO 78 --- [       Thread-6] o.s.s.concurrent.ThreadPoolTaskExecutor  : Shutting down ExecutorService 'applicationTaskExecutor'
    
    > Task :check
    > Task :build
    
    BUILD SUCCESSFUL in 2m 0s
    5 actionable tasks: 5 executed
    Removing intermediate container 4658b0e3cf34
     ---> 9241999e8910
    Step 8/13 : RUN gradle test
     ---> Running in 60fbc339d6c6
    
    Welcome to Gradle 5.6!
    
    Here are the highlights of this release:
     - Incremental Groovy compilation
     - Groovy compile avoidance
     - Test fixtures for Java projects
     - Manage plugin versions via settings script
    
    For more details see https://docs.gradle.org/5.6/release-notes.html
    
    Starting a Gradle Daemon (subsequent builds will be faster)
    > Task :compileJava
    > Task :processResources
    > Task :classes
    > Task :compileTestJava
    > Task :processTestResources NO-SOURCE
    > Task :testClasses
    
    > Task :test
    2019-08-23 15:22:40.380  INFO 78 --- [       Thread-6] o.s.s.concurrent.ThreadPoolTaskExecutor  : Shutting down ExecutorService 'applicationTaskExecutor'
    
    BUILD SUCCESSFUL in 1m 19s
    4 actionable tasks: 4 executed
    Removing intermediate container 60fbc339d6c6
     ---> 5d98eff19a0a
    Step 9/13 : FROM openjdk:8u222-jre-slim
    8u222-jre-slim: Pulling from library/openjdk
    1ab2bdfe9778: Pulling fs layer
    7aaf9a088d61: Pulling fs layer
    80a55c9c9fe8: Pulling fs layer
    a0086b0e6eec: Pulling fs layer
    a0086b0e6eec: Waiting
    80a55c9c9fe8: Verifying Checksum
    80a55c9c9fe8: Download complete
    7aaf9a088d61: Verifying Checksum
    7aaf9a088d61: Download complete
    1ab2bdfe9778: Verifying Checksum
    1ab2bdfe9778: Download complete
    a0086b0e6eec: Verifying Checksum
    a0086b0e6eec: Download complete
    1ab2bdfe9778: Pull complete
    7aaf9a088d61: Pull complete
    80a55c9c9fe8: Pull complete
    a0086b0e6eec: Pull complete
    Digest: sha256:8489e5a8e8a144ae7c41cbc2b95de8a7618cc31c7ae3ecb9db8d4b667ee84ff1
    Status: Downloaded newer image for openjdk:8u222-jre-slim
     ---> 624624f99e2f
    Step 10/13 : EXPOSE 8080
     ---> Running in 7e9f5f15db7b
    Removing intermediate container 7e9f5f15db7b
     ---> b95195a1889e
    Step 11/13 : WORKDIR /app
     ---> Running in b358fe7409cf
    Removing intermediate container b358fe7409cf
     ---> 2a87aae59760
    Step 12/13 : COPY --from=builder /home/gradle/src/build/libs/challenge-0.0.1.jar /app
     ---> 3d9aa800384e
    Step 13/13 : CMD java -jar challenge-0.0.1.jar
     ---> Running in 834abd2be5c6
    Removing intermediate container 834abd2be5c6
     ---> a5b1e0e40840
    Successfully built a5b1e0e40840
    Successfully tagged adidas_demo:v1
    [kuvivek@vivekcentos adidas]$
    [kuvivek@vivekcentos adidas]$

The docker build command reads the Dockerfile present under current working directory, also represented via  dot ( . ),  and then builds a binary image that contains everything necessary for the webapp to run.

Running your containerized service
============================
The webapp is successfully encapsulated and everything needed to run the webapp container, on the operating system (Alpine Linux) to the runtime environment (Java) to the actual app (hello world).

Command to run the container:

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ sudo docker run -d -p 80:8080 --name webapp adidas_demo:v1
    88ee61e973a25017b69b7942fdb6b3c412c6cae86a2f5642676eff00bb256f52
    [kuvivek@vivekcentos adidas]$

(This command runs the container, with the name webapp and maps the container's port 8080 to the hosts port 80.) 
This can verified using the below command:

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ sudo docker ps -a
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
    88ee61e973a2        adidas_demo:v1      "/bin/sh -c 'java -j…"   53 seconds ago      Up 52 seconds       0.0.0.0:80->8080/tcp   webapp
    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ curl http://localhost:80/greeting/?name=Vivek
    Hello, Vivek![kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$

(This sends an HTTP request to port 80 on localhost, which then maps to the 8080 in the container.)

The next step is to run the services on Kubernetes. Kubernetes takes care of all the details of running a container: which VM/server to run the container on. It also ensures that the container has the right amount of memory/CPU/etc.. and so forth.

For Kubernetes to know how to run any container, Kubernetes manifest file is required.

Kubernetes and manifests
=========================
I have created a Kubernetes manifest file for the webapp service.

![Deployment_YAML](file:///home/kuvivek/Pictures/deployment_YAML.png)

The manifest file is written in YAML, and contains some key bits of information about your service, including a pointer to the Docker image, memory/CPU limits,
and ports exposed.

So now Two things are ready 

 - The code to be run, in a container
 - The runtime configuration of how to run the code, in the Kubernetes manifest.

Another important component before running the container is -- a container registry.

The Container Registry
======================

In order to run an image in Kubernetes cluster, it needs to get a copy of the image.

This is typically done through a container registry: a central service that hosts images. There are dozens of options for container registries, for both on-premise
and cloud-only use cases.

For the time being I am pushing the built image in the dockerhub website. Setting the URL for the Registry as an environment variable with the command:

Login to the dockerhub repository.

    [kuvivek@vivekcentos adidas]$ sudo docker login --username=kuvivek
    Password: 
    WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store
    
    Login Succeeded
    [kuvivek@vivekcentos adidas]$ 

Fetch the imageid of the adidas_demo image.

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ sudo docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    adidas_demo         v1                  a5b1e0e40840        3 hours ago         202MB
    <none>              <none>              5d98eff19a0a        3 hours ago         584MB
    <none>              <none>              c3cc1cc16834        3 hours ago         27.7MB
    centos              latest              67fa590cfc1c        2 days ago          202MB
    ni_final_web        latest              960b38b1cb55        7 days ago          909MB
    gradle              5.6.0-jdk8          574bfd4bb73f        7 days ago          545MB
    python              2.7                 d75b4eed9ada        9 days ago          886MB
    openjdk             8u222-jre-slim      624624f99e2f        9 days ago          184MB
    alpine/git          latest              a1d22e4b51ad        5 months ago        27.5MB
    hello-world         latest              fce289e99eb9        7 months ago        1.84kB
    [kuvivek@vivekcentos adidas]$ 


Then Docker Image need to be pushed to the registry, For this lets create a tag for the Docker image that contains our Docker repository name.

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ sudo docker tag a5b1e0e40840 kuvivek/adidas_demo:v1
    [kuvivek@vivekcentos adidas]$ 

Then, I pushed the image created to the Docker Registry:

    [kuvivek@vivekcentos adidas]$ 
    [kuvivek@vivekcentos adidas]$ sudo docker push kuvivek/adidas_demo
    The push refers to repository [docker.io/kuvivek/adidas_demo]
    9b4c8872565a: Pushed 
    8f0ff6e9d90a: Pushed 
    e54bd3566d9e: Mounted from library/openjdk 
    eb25e0278d41: Mounted from library/openjdk 
    2bf534399aca: Mounted from library/openjdk 
    1c95c77433e8: Mounted from library/openjdk 
    v1: digest: sha256:28834a890bccdfbb20dd38afbac38087df0f2ba86fe94929b89951508c8b7ff9 size: 1578
    [kuvivek@vivekcentos adidas]$ 

[Now, Its time to get the service running in Kubernetes.

Running the service in Kubernetes
=================================

In the deployment.yaml file IMAGE_URL need to be updated. I have kept the templated deployment file with the variable IMAGE_URL, which can be then instantiate with a sed command:

    sed -i -e 's;IMAGE_URL;'kuvivek/adidas_demo:v1';' deployment.yaml


Now, Deploying the service on the hosted kubernetes:

    kubectl apply -f deployment.yaml
![deployment_apply](file:///home/kuvivek/Pictures/kubernetes_deployment_apply.png)

Here I am telling Kubernetes to actually process the information in the manifest.

We can see the services running:

> kubectl get services

or 

> kubectl get svc

Now, we want to send an HTTP request to the service. Most Kubernetes services are not exposed to the Internet, for obvious reasons. So we need to be able to access services that are running in the cluster directly.

> kubectl get pods

 or  

> kubectl get po

When the service was deployed, a dynamic NodePort was assigned to the Pod. This can be accessed via 

> kubectl get svc

Store the port assigned as a variable for later use.

    export PORT=$(kubectl get svc hello-webapp -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')

We can now send an HTTP request to the service:

    curl http://localhost:$PORT/greeting/?name=Vivek

And I can see the below message "Hello, Vivek".


The four pieces required for deployment
Following four main things performed 
1) created a container 
2) created the Kubernetes manifest 
3) pushed the container to a registry and 
4) finally told Kubernetes all about these pieces with an updated manifest.

So, this was a bunch of steps, and if you have to do this over-and-over again (as you would for development), this would quickly grow tedious. 
Lets take a quick look at how we might script these steps so we could create a more useable workflow.


Now rebuild the image, push it to the registry, and editing the deployment, but these still involves multiple commands, which people often forget.

Luckily, [Forge](http://forge.sh) is an open source tool for deploying services onto Kubernetes, and it already does the automation (and then some!). Let's try using Forge to do this deployment. We need to do a quick setup of Forge: is an open source tool for deploying services onto Kubernetes, and it already does the automation (and then some!). 
Let's try using Forge to do this deployment. We need to do a quick setup of Forge:

    forge setup

To setup Forge, 

Enter the URL for your in house Docker Registry:
Enter the username for the Registry
Enter root for the password.
Finally,  Enter the organization, again root.

With Forge configured, type:

    forge deploy

Forge will automatically build your Docker container (based on your Dockerfile), push the container to the Docker registry of our choice, 
build a deployment.yaml file for us that points to my image, and then deploy the container into Kubernetes.

This process will take a few moments as Kubernetes terminates the existing container and swaps in the new code. I will need to set up a 
new port forward command. Lets get the pod status again:

    kubectl get pods

As previously, obtain the NodePort assigned to our deployment.

    export PORT=$(kubectl get svc hello-webapp -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')

And then check out the new welcome message, using the curl command as mentioned above.




