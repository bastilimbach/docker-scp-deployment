# Docker SAP Cloud Platform Deployment
At the moment the process to deploy an UI5 app to the SAP Cloud Platform is pretty painful.
First you need to package/build your app using the MTA Builder from SAP which generates an `.mtar` file which can than be uploaded to the SCP using the SAP Neo Java Web SDK.
To simplify this deployment process I created a Dockerfile which contains a working version of both the Neo Java Web SDK as well as the MTA Builder so you can use this Docker image inside your CI/CD system.

## Installation
Due to the reason that the MTA Builder is only downloadable thru the SAP Software Download Center with a valid S-User I'm pretty sure that I'm not allowed to include the builder inside this Repository so you need to manually download the software and build the Docker image yourself as following:

1. Download the MTA Builder from the [SAP Software Download Center](https://launchpad.support.sap.com/#/softwarecenter/template/products/_APP=00200682500000001943&_EVENT=NEXT&HEADER=Y&FUNCTIONBAR=Y&EVENT=TREE&NE=NAVIGATE&ENR=73554900100800000903&V=MAINT&TA=ACTUAL/MULTITRG%20APP%20ARCHIVE%20BUILDER)
2. Clone this repository using `git clone https://github.com/bastilimbach/docker-scp-deployment.git`
3. Move the MTA Builder inside the previously cloned folder and rename the file to `mta_builder.jar`
4. Build the Docker image using `docker build --pull --compress --no-cache -t scp-deployment .`
5. *(Optional)* Tag the image to upload it to your private Docker Registry using `docker tag scp-deployment yourRegistry.com/scp-deployment`
6. *(Optional)* Upload the image to your private Docker Registry using `docker push yourRegistry.com/scp-deployment`

> You may need to log yourself into your private registry before pushing the image using `docker login`

## Usage
To deploy your UI5 application you first need to build/package your application using the MTA Builder and the corresponding [mta.yaml descriptor file](https://help.sap.com/viewer/4505d0bdaf4948449b7f7379d24d0f0d/1.0.12/en-US/ebb42efc880c4276a5f2294063fae0c3.html). To build the `.mtar` file, simply run the following inside the container:
```bash
$ mta-builder --mtar yourAppName.mtar --build-target=NEO build
```

After a successful build you need to deploy the `.mtar` file using the following command inside the Docker container:
```bash
$ neo deploy-mta --user YOUR_SCP_USER --host YOUR_SCP_HOST --source yourAppName.mtar --account YOUR_SCP_SUBACCOUNT --password YOUR_SCP_PASSWORD --synchronous
```

To get more information on the MTA Builder or the Neo Java Web SDK and there corresponding flag options go to the SAP Help Portal:
- [MTA Builder](https://help.sap.com/viewer/58746c584026430a890170ac4d87d03b/Cloud/en-US/9f778dba93934a80a51166da3ec64a05.html)
- [Neo Java Web SDK](https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/8900b22376f84c609ee9baf5bf67130a.html)

# Examples
## Gitlab CI
```yaml
# mta.yaml

ID: sap.ui.app.yourappname
version: 1.0.0
_schema-version: 2.0.0

parameters:
   hcp-deployer-version: 1.2.0

modules:
  - name: scp-dockerdeployment
    type: html5
    path: .
    parameters:
      display-name: Your App Name
      version: 1.0.0--${timestamp}
    build-parameters:
      builder: grunt
      build-result: dist
```

```yaml
# .gitlab-ci.yml

image: yourRegistry/scp-deployment
stages:
  - build
  - deploy

build-mta:
  stage: build
  artifacts:
    expire_in: 1 week
    paths:
      - ui5app.mtar
  before_script:
    - sed -ie "s/\${timestamp}/`date +%d.%m.%Y-%H%M%S`/g" mta.yaml
  script:
    - mta-builder --mtar ui5app.mtar --build-target=NEO build
  tags:
    - build

deploy-mta:
  stage: deploy
  dependencies:
    - build-mta
  script:
    - neo deploy-mta --user YOUR_SCP_USER --host YOUR_SCP_HOST --source yourAppName.mtar --account YOUR_SCP_SUBACCOUNT --password YOUR_SCP_PASSWORD --synchronous
  only:
    - master
  tags:
    - deploy
```

# Contribution
Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bastilimbach/docker-scp-deployment/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

# License
[MIT](https://github.com/bastilimbach/docker-scp-deployment/blob/master/LICENSE) :heart:
