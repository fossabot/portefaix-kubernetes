#!/usr/bin/python3

# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

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

import diagrams
from diagrams.k8s import compute
from diagrams.k8s import network
from diagrams.k8s import others
from diagrams.k8s import podconfig
from diagrams.k8s import rbac
from diagrams.k8s import storage

import cloud


def k8s_rbac():
    sa = rbac.ServiceAccount()
    clusterRole = rbac.ClusterRole()
    clusterRoleBinding = rbac.ClusterRoleBinding()
    clusterRole << clusterRoleBinding >> sa
    role = rbac.Role()
    roleBinding = rbac.RoleBinding()
    role << roleBinding >> sa
    return sa

def architecture(cloud_provider, output, direction):
    with diagrams.Diagram("thanos_%s" % cloud_provider, direction="TB", show=False):
        with diagrams.Cluster("Cloud Platform"):

            sc = storage.StorageClass()
            sa = k8s_rbac()
            iam = cloud.iam(cloud_provider)
            bucket = cloud.bucket(cloud_provider)
            disk = cloud.disk(cloud_provider)

            compact_pvc = storage.PVC("compact")
            compact_pv = storage.PV("compact")
            sc << compact_pvc
            compact_pvc >> compact_pv

            store_pvc = storage.PVC("store")
            store_pv = storage.PV("store")
            sc << store_pvc
            store_pvc >> store_pv

            sc >> [store_pv, compact_pv]
            disk << [store_pv, compact_pv]

            with diagrams.Cluster("Kubernetes Cluster"):
                # sa = k8s_rbac()

                with diagrams.Cluster("monitoring"):
                    # secret = podconfig.Secret("storage")

                    compact_svc = network.Service("compact")
                    compact_sts = compute.StatefulSet("compact")
                    compact_pod = compute.Pod("compact")
                    compact_sm = others.CRD("servicemonitor")

                    compact_sts >> compact_pod >> iam #secret
                    compact_svc >> compact_pod
                    compact_pod >> compact_pv
                    compact_sm >> compact_svc

                    query_svc = network.Service("query")
                    query_deploy = compute.Deployment("query")
                    query_pod = compute.Pod("query")
                    query_sm = others.CRD("servicemonitor")

                    store_svc = network.Service("store")
                    store_sts = compute.StatefulSet("store")
                    store_pod = compute.Pod("store")
                    store_sm = others.CRD("servicemonitor")

                    query_deploy >> query_pod
                    query_svc >> query_pod
                    query_sm >> query_svc
                    query_pod >> store_svc

                    [store_sts, store_svc] >> store_pod
                    store_pod >> iam #secret
                    store_pod >> store_pv
                    store_sm >> store_svc

                    sa >> iam
                    compact_pod >> bucket
                    store_pod >> bucket

def main():
    architecture()


if __name__ == "__main__":
    main()
