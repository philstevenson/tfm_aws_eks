#!/usr/bin/env bash

set -e

KUBECONFIG=$1
VERSION=$2
CUSTOM_DOMAIN_NAME=$3
CLUSTER_ISSUER_NAME=$4

# KNATIVE OPERATOR INSTALL

kubectl --kubeconfig=${KUBECONFIG} apply --wait -f https://github.com/knative/operator/releases/download/v${VERSION}/operator.yaml

kubectl --kubeconfig=${KUBECONFIG} wait --timeout=5m --for condition=established --timeout=300s crd --all

sleep 3

# KNATIVE SERVING INSTALL

cat <<-EOF | kubectl --kubeconfig=${KUBECONFIG} apply -f -
apiVersion: v1
kind: Namespace
metadata:
 name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  knative-ingress-gateway:
    selector:
      istio: externalgateway
  config:
    network:
      autoTLS: Enabled
      httpProtocol: Redirected
    istio:
      gateway.knative-serving.knative-ingress-gateway: "istio-externalgateway.istio-system.svc.cluster.local"
    domain:
      ${CUSTOM_DOMAIN_NAME}: ""
EOF

sleep 2

kubectl apply --kubeconfig=${KUBECONFIG} --filename https://github.com/knative/net-certmanager/releases/download/v${VERSION}/release.yaml

kubectl apply --kubeconfig=${KUBECONFIG} --filename https://github.com/knative/serving/releases/download/v${VERSION}/serving-nscert.yaml

cat <<-EOF | kubectl --kubeconfig=${KUBECONFIG} apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-certmanager
  namespace: knative-serving
  labels:
    networking.knative.dev/certificate-provider: cert-manager
data:
  issuerRef: |
    kind: ClusterIssuer
    name: ${CLUSTER_ISSUER_NAME}
EOF

# KNATIVE EVENTING INSTALL

cat <<-EOF | kubectl --kubeconfig=${KUBECONFIG} apply -f -
apiVersion: v1
kind: Namespace
metadata:
 name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
EOF
