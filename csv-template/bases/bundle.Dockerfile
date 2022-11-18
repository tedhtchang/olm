FROM scratch

ARG ARCH=multiarch
ARG USER=1001

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=flink-kubernetes-operator
LABEL operators.operatorframework.io.bundle.channels.v1=latest
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.23.0
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=unknown

USER ${USER}

# Copy files to locations specified by labels.
COPY ./manifests /manifests/
COPY ./metadata /metadata/
