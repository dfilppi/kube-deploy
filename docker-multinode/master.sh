#!/bin/bash

# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

while [[ $# -gt 1 ]]
do
  case $1 in
    --k8s-version)
      export K8S_VERSION=$2
      shift
      ;;
    --etcd-version)
      export ETCD_VERSION=$2
      shift
      ;;
    --flannel-version)
      export FLANNEL_VERSION=$2
      shift
      ;;
    --flannel-network)
      export FLANNEL_NETWORK=$2
      shift
      ;;
    --flannel-ipmasq)
      export FLANNEL_IPMASQ=$2
      shift
      ;;
    --flannel-backend)
      export FLANNEL_BACKEND=$2
      shift
      ;;
    --restart-policy)
      export RESTART_POLICY=$2
      shift
      ;;
    --arch)
      export ARCH=$2
      shift
      ;;
    --net-interface)
      export NET_INTERFACE=$2
      shift
      ;;
    --etcd-name)
      export ETCD_NAME=$2
      shift
      ;;
    --etcd-initial-cluster)
      export ETCD_INITIAL_CLUSTER=$2
      shift
      ;;
    --etcd-initial-cluster-state)
      export ETCD_INITIAL_CLUSTER_STATE=$2
      shift
      ;;
    --etcd-initial-advertise-peer-urls)
      export ETCD_INITIAL_ADVERTISE_PEER_URLS=$2
      shift
      ;;
    --etcd-advertise-client-urls)
      export ETCD_ADVERTISE_CLIENT_URLS=$2
      shift
      ;;
    --etcd-listen-peer-urls)
      export ETCD_LISTEN_PEER_URLS=$2
      shift
      ;;
    --etcd-listen-client-urls)
      export ETCD_LISTEN_CLIENT_URLS=$2
  esac
  shift
done

# Source common.sh
source $(dirname "${BASH_SOURCE}")/common.sh

kube::log::status `env`

# Set MASTER_IP to localhost when deploying a master
MASTER_IP=localhost

kube::multinode::main

kube::multinode::log_variables

kube::multinode::turndown

if [[ ${USE_CNI} == "true" ]]; then
  kube::cni::ensure_docker_settings

  kube::multinode::start_etcd

  kube::multinode::start_flannel
else
  kube::bootstrap::bootstrap_daemon

  kube::multinode::start_etcd

  kube::multinode::start_flannel

  kube::bootstrap::restart_docker
fi

kube::multinode::start_k8s_master

kube::log::status "Done. It may take about a minute before apiserver is up."
