# OLM Integration

The document describes the automated flink-kubernetes-operator OLM bundle generation process for each release. For every release, we publish new bundle to two online catalogs. Each catalog has a Github repository that uses similar publishing process.
![image](https://user-images.githubusercontent.com/7155778/202823924-8d08561f-1b5f-4e96-9f87-adc171e699c9.png)
The [community-operators-prod catalog](https://github.com/redhat-openshift-ecosystem/community-operators-prod) comes with OCP (Openshift Container Platform) by default. The [community-operator catalog](https://github.com/k8s-operatorhub/community-operators) can be optionally installed on kubernetes clusters.

## Install Prereqs

The following steps ran on a fresh Ubuntu 22.04 VM. DO NOT run on an
existing OS or data lose may occur.
Clone the olm repo into the flink-kubernetes-operator repo:
```sh
git clone https://github.com/apache/flink-kubernetes-operator.git
cd  flink-kubernetes-operator
git clone https://github.com/tedhtchang/olm.git
cd olm
```
Optionally install the required packages for development for the first time:
```sh
./install-prereq.sh
```
## Test the bundle locally
Change the variables in `env.sh` if necessary.
```sh
. env.sh
```
Make sure you have logged in your container image registry. DockerHub example:
```sh
docker login docker.io -u <registry_org>
...
Login Succeeded
```
This will generate bundle, catalog images, and deploy the Operator from local catalog.
```sh
./AutomatedOLMBuildAndDeploy.sh
```
Deploy a Flink job to verify the operator:
```sh
kubectl create -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.2/examples/basic.yaml
```
After verifying, the bundle image and catalog image are no longer needed. We only need the bundle folder which has the following files:
```
1.3.0/
├── bundle.Dockerfile
├── manifests
│   ├── flink.apache.org_flinkdeployments.yaml
│   ├── flink.apache.org_flinksessionjobs.yaml
│   ├── flink-kubernetes-operator.clusterserviceversion.yaml
│   ├── flink-operator-config_v1_configmap.yaml
│   ├── flink-operator-webhook-secret_v1_secret.yaml
│   ├── flink_rbac.authorization.k8s.io_v1_role.yaml
│   ├── flink-role-binding_rbac.authorization.k8s.io_v1_rolebinding.yaml
│   └── flink_v1_serviceaccount.yaml
└── metadata
    └── annotations.yaml
```


## Run CI test suits before creating PR

Clone your forked community-operators repo
```sh
git clone https://github.com/tedhtchang/community-operators.git
```
The bundle(i.e. 1.3.0) folder is all we need to commit into the community-operators repo. Copy the new bundle into the forked community-operators repo
```sh
cp -r <flink-kubernetes-operator>/olm/1.3.0 <community-operators>/operators/flink-kubernetes-operator/
```

Run test suites
```sh
cd <community-operators>
OPP_PRODUCTION_TYPE=k8s  OPP_AUTO_PACKAGEMANIFEST_CLUSTER_VERSION_LABEL=1 bash <(curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh) all operators/flink-kubernetes-operator/1.3.0
```
The expected output:
```
...
Test 'kiwi' : [ OK ]
Test 'lemon_latest' : [ OK ]
Test 'orange_latest' : [ OK ]
```

After the tests pass, commit and push the new bundle to a branch to create a PR.

Repeat the same process for adding new bundle to the [community-operator-prod](https://github.com/redhat-openshift-ecosystem/community-operators-prod) repo. For this repo, run the CI test suits using:
```sh
cd <community-operators-prod>
OPP_PRODUCTION_TYPE=ocp  OPP_AUTO_PACKAGEMANIFEST_CLUSTER_VERSION_LABEL=1 bash <(curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh) all operators/flink-kubernetes-operator/1.3.0
```

See detail for running CI test suits [here](https://k8s-operatorhub.github.io/community-operators/operator-test-suite/).
