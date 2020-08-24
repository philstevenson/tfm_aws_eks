#!/usr/bin/env bash

set -e

KUBECONFIG=$1
VERSION=$2

# KNATIVE EVENTING UNINSTALL

kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found KnativeEventing knative-eventing -n knative-eventing
kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found namespace knative-eventing

# KNATIVE SERVING UNINSTALL

kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found KnativeServing knative-serving -n knative-serving
kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found namespace knative-serving

# KNATIVE OPERATOR UNINSTALL

kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found --wait -f https://github.com/knative/operator/releases/download/v${VERSION}/operator.yaml
