# OLM Integration

The document describe the automated flink-kubernetes-operator OLM bundle development process for each release.


## Install Prereqs

The following steps ran on Ubuntu 22.04.
Clone the olm into the flink-kubernetes-operator repo:
```sh
git clone //github.com/apache/flink-kubernetes-operator.git
cd  flink-kubernetes-operator
git clone https://github.com/tedhtchang/olm.git
cd olm
```
Optionally install the required packages for development for the first time:
```sh
./install-prereq.sh
```
## Test the bundle locally
This will generate bundle, catalog images, and deploy the Operator from local catalog.
Change the variables in `env.sh` if necessary.
```sh
. env.sh
./AutomatedOLMBuildAndDeploy.sh
```
Deploy a Flink job to verify the operator:
```sh
kubectl create -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.2/examples/basic.yam
```

## Run CI test suits before creating PR

Clone your forked community-operators repo
```sh
git clone https://github.com/tedhtchang/community-operators.git
```
The ${BUNDLE} folder is all we need to commit for a release. Copy the new bundle into the forked community-operators repo
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

Repeat the same process for adding new bundle to the [community-operator-prod](https://github.com/redhat-openshift-ecosystem/community-operators-prod) repo which is the the catalog available by default on Openshift Container platform.
```sh
cd <community-operators-prod>
OPP_PRODUCTION_TYPE=ocp  OPP_AUTO_PACKAGEMANIFEST_CLUSTER_VERSION_LABEL=1 bash <(curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh) all operators/flink-kubernetes-operator/1.3.0
```

See detail for running CI test suits [here](https://k8s-operatorhub.github.io/community-operators/operator-test-suite/).
