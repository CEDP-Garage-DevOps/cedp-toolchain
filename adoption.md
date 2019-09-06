# Project adoption to the cedp-garage organization

## Prerequisites

Request access from the organization [admin](https://github.ibm.com/orgs/CEDP-Garage/teams/cedp-garage-admin/members).

## Create and clone the Repository

Create the repository under the CEDP-Garage organization and clone it to the local and add the folder structure as below
```.
   ├── Dockerfile
   ├── airflow
   │   ├── dag
   │   └── scripts
   ├── build.sbt
   ├── build.yaml
   ├── build.yml
   ├── project
   │   ├── build.properties
   │   └── plugins.sbt
   ├── scalastyle-config.xml
   └── src
       ├── main
       └── test
```
* [Dockerfile](https://github.ibm.com/CEDP-Garage/cedp-client360/blob/master/client360/Dockerfile) - import required spark base image from container registry and copy req certs and source code to root  container directory
* airflow  - it contains the dags and scripts which will help to deploy to the cluster
* build.sbt - this refers to the dependence of the project
* project - build.properties and required scala plugins
* build.yml - it contains the project name, build tool, scala version and path to the code, cluster name, path to airflow dag's, and airflow pod instance which uses to deploy in kubernetes

## Branching and Github Flow

The project repo is following [GitFlow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) based development

## Getting started with pipeline

Pipelines configuration can be found in GitHub repo [here](https://github.ibm.com/CEDP-Garage/cedp-toolchain)

In master branch you can find list of Buttons to create pipelines for different stages of template on DevOp Tool Chain.

![Buttons](https://media.github.ibm.com/user/192214/files/74d2e100-d002-11e9-8cb4-edd129c9eb7f)

After you click the button you will see something like below snippet on screen:

![ToolChain](https://media.github.ibm.com/user/192214/files/82896600-d004-11e9-85b3-0d86ea829681)

In the above snippet you can see in which branch you have the json template file and need to edit the name and choose correct region and resource group you want to have your pipeline

Next click on GitHub Enterprise. Click I understand and paste `http` url of your project git repository

![Github](https://media.github.ibm.com/user/192214/files/769ea380-d006-11e9-9dab-36621dae2486)

Next click on Delivery Pipeline. Fill in Parameters below:

![Delivery Pipeline](https://media.github.ibm.com/user/192214/files/09d7d900-d007-11e9-8b68-6f1c406a18af)

* IBM Cloud API Key - a unique code that is associated with the user's identity, that can be created [here](https://cloud.ibm.com/docs/iam?topic=iam-userapikey#create_user_key) in your profile or just you can create by using the `create` button on the screen.

* Git Input Branch -  branch in your GitHub that we use for the 

* Pipeline Image - DevOps Custom image, which uses as the base image for the pipeline, by default: us.icr.io/cedp-garage/toolchain:1.0 which is deployed in your container registry 

* Region - the region of Kubernetes cluster, that we use but it will be choosen directly when you add the `IBM Cloud API Key`

* Function UserName & Function Password - this helps us to login to the Jfrog-artifactory and IBM Cloud Container registry to push the image

* Docker Username & Docker Password - this will pull the base image of the pipeline from the IBM Container Registry

* Sonar DevOps Token - the sonar token which connects to sonarQube and generateds the security report. 

Optional: Click on More tools to configure the additional tools like slack. Fill in params below.

**Note**: You would need to create or use the Slack channel in CDO organization and integrate it with Incoming WebHook App.

1. Slack webhook - https://hooks.slack.com/services/<something like ABCDEFGHIJKLM/NOPQRSTUV>
1. Slack channel - from Chief Data Office Organization
1. Slack team name - chiefdataoffice.slack.com

Now click create and wait. Once done you will see toolchain screen

![image](https://media.github.ibm.com/user/192214/files/87aedb00-d02d-11e9-8619-0aafc6678331)

Click on Delivery Pipeline and you will see actual steps it will perform:

![image](https://media.github.ibm.com/user/192214/files/82538f80-d031-11e9-9831-6bf618821dab)


1. Setup – Cloning the git hub branch and `diff` the changed file

1. Quality – checking the quality of the code

1. Security - Code security check and validating is done through the SonarQube

1. PublishJar – publishing the Jar to Jfrog artifactory

1. DockerImage – building dockerimage and send to the container registry

1. AirflowDag - pushing the changed airflow dags to the airflow instance     
     