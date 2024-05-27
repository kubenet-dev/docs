
# Getting Started

First check the [prerequisites](./02_prereq.md). Take special attention to the CPU and OS dependencies

## Setup environment

The first step is setting up the environment:

- A kubernetes cluster (we use [kind](kind) in the exercises)
- A network lab environment (we use [containerlab](containerlab) in the exercises)

Create a directory where the exercises will be executed. Some tools install files in this directory, so we dont want to mess with your environment.

```
mkdir -p kubenet; cd kubenet
```

Lets get started with setting up the environment. With the following command

- A kind kubernetes cluster is created
- An iprule is create to allow containerlab and the kind cluster to communicate
- A lab according to the following topology

/// details | clab topology

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/lab/3node.yaml
--8<--
```
///

/// tab | interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl setup
```

///

/// tab | automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically one after the other

```
kubenetctl setup -a
```

///

A similar output is expected

```
Setup kubenet Environment
=========================
# create k8s kind cluster [1/3]:

> kind create cluster --name kubenet
Creating cluster "kubenet" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kubenet"
You can now use your cluster with:

kubectl cluster-info --context kind-kubenet

Thanks for using kind! 😊

# Allow the kind cluster to communicate with the containerlab topology (clab will be created in a later step) [2/3]:

> sudo iptables -I DOCKER-USER -o br-$(docker network inspect -f '{{ printf "%.12s" .ID }}' kind) -j ACCEPT

# Deploy Containerlab topology [3/3]:

> sudo containerlab deploy -t https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/lab/3node.yaml --reconfigure
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: topo-3311532188.clab.yml 
INFO[0000] Removing /home/henderiw/test/kubenet/clab-topo3nodesrl directory... 
INFO[0000] Creating lab directory: /home/henderiw/test/kubenet/clab-topo3nodesrl 
INFO[0000] Creating container: "client1"                
INFO[0000] Creating container: "client2"                
INFO[0000] Creating container: "core01"                 
INFO[0000] Creating container: "edge01"                 
INFO[0000] Creating container: "edge02"                 
INFO[0001] Created link: client1:eth1 <--> edge01:e1-1  
INFO[0001] Running postdeploy actions for Nokia SR Linux 'edge01' node 
INFO[0001] Created link: client2:eth1 <--> edge02:e1-1  
INFO[0001] Running postdeploy actions for Nokia SR Linux 'edge02' node 
INFO[0001] Created link: edge01:e1-49 <--> core01:e1-1  
INFO[0001] Created link: edge02:e1-49 <--> core01:e1-2  
INFO[0001] Running postdeploy actions for Nokia SR Linux 'core01' node 
INFO[0017] Adding containerlab host entries to /etc/hosts file 
INFO[0017] Adding ssh config for containerlab nodes     
+---+---------------------------+--------------+---------------------------------+---------------+---------+---------------+--------------+
| # |           Name            | Container ID |              Image              |     Kind      |  State  | IPv4 Address  | IPv6 Address |
+---+---------------------------+--------------+---------------------------------+---------------+---------+---------------+--------------+
| 1 | clab-topo3nodesrl-client1 | fe49acb930b9 | ghcr.io/hellt/network-multitool | linux         | running | 172.21.0.6/16 | N/A          |
| 2 | clab-topo3nodesrl-client2 | dbb22872be06 | ghcr.io/hellt/network-multitool | linux         | running | 172.21.0.2/16 | N/A          |
| 3 | clab-topo3nodesrl-core01  | 60447c1b38e6 | ghcr.io/nokia/srlinux           | nokia_srlinux | running | 172.21.0.3/16 | N/A          |
| 4 | clab-topo3nodesrl-edge01  | 3ba50344c008 | ghcr.io/nokia/srlinux           | nokia_srlinux | running | 172.21.0.4/16 | N/A          |
| 5 | clab-topo3nodesrl-edge02  | 320a373157a9 | ghcr.io/nokia/srlinux           | nokia_srlinux | running | 172.21.0.5/16 | N/A          |
+---+---------------------------+--------------+---------------------------------+---------------+---------+---------------+--------------+
```

The following commands help to see the running containers. 

- A container for the kind cluster
- 3 [srlinux][srlinux] containers (2 for the edge and 1 for the core)
- 2 multitool test tools

```
docker ps
```

```
CONTAINER ID   IMAGE                             COMMAND                  CREATED         STATUS         PORTS                       NAMES
320a373157a9   ghcr.io/nokia/srlinux             "/tini -- fixuid -q …"   2 minutes ago   Up 2 minutes                               clab-topo3nodesrl-edge02
60447c1b38e6   ghcr.io/nokia/srlinux             "/tini -- fixuid -q …"   2 minutes ago   Up 2 minutes                               clab-topo3nodesrl-core01
dbb22872be06   ghcr.io/hellt/network-multitool   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp, 443/tcp             clab-topo3nodesrl-client2
3ba50344c008   ghcr.io/nokia/srlinux             "/tini -- fixuid -q …"   2 minutes ago   Up 2 minutes                               clab-topo3nodesrl-edge01
fe49acb930b9   ghcr.io/hellt/network-multitool   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp, 443/tcp             clab-topo3nodesrl-client1
f0fe7884d98d   kindest/node:v1.27.3              "/usr/local/bin/entr…"   3 minutes ago   Up 3 minutes   127.0.0.1:43347->6443/tcp   kubenet-control-plane
```

🎉 Yeah 🎉 you have a kubernetes cluster running. With the following command you can see the running pods. These are the base kubernetes building blocks

```
kubenctl get pods -A
```

```
NAMESPACE            NAME                                            READY   STATUS    RESTARTS   AGE
kube-system          coredns-5d78c9869d-pm2nc                        1/1     Running   0          10m
kube-system          coredns-5d78c9869d-t7jw6                        1/1     Running   0          10m
kube-system          etcd-kubenet-control-plane                      1/1     Running   0          10m
kube-system          kindnet-8g2cz                                   1/1     Running   0          10m
kube-system          kube-apiserver-kubenet-control-plane            1/1     Running   0          10m
kube-system          kube-controller-manager-kubenet-control-plane   1/1     Running   0          10m
kube-system          kube-proxy-8bwmb                                1/1     Running   0          10m
kube-system          kube-scheduler-kubenet-control-plane            1/1     Running   0          10m
local-path-storage   local-path-provisioner-6bc4bddd6b-tjmt2         1/1     Running   0          10m
```

## Install kubenet components

After the [kind][kind] cluster is up and running, proceed to install the Kubenet components. These software building blocks are essential for the exercises and will help you interact with Kubernetes, providing insights into how Kubernetes can be leveraged for network automation use cases.

- [pkgserver][pkgserver]: A SW component that provides 2 way git access to kubernetes: basically read and write to a repository.
- [sdc][sdc]: A SW component that maps a kubernetes manifest to a YANG based system.
- [kuid][kuid]: An inventory and identity system, which allows to create resources and claim identifier required for networking (e.g. IPAM, VLAN, AS, etc). Some people think of this as a source of truth.
- [kuidapps][kuid]: Application leveraging the kuid backend API and extend kuid with applications that are tailored for specific tasks. E.g, a specific kuid app is installed to interact with Nokia [SRLinux][srlinux] devices to translate the abstracted data-model of kuid to the specific implementation in [SRLinux][srlinux]. Another app is setup to map the [cointerlab][containerlab] topology into the [kuid][kuid] backend.


/// tab | Interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl install
```

///

/// tab | Automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically without human intervention

```
kubenetctl install -a
```

///

```shell
Install kubenet Components
==========================
# install package server: (tool to interact with git from k8s using packages (KRM manifests)) [1/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/artifacts/out/pkgserver.yaml
namespace/pkg-system created
customresourcedefinition.apiextensions.k8s.io/packagevariants.config.pkg.pkgserver.dev created
customresourcedefinition.apiextensions.k8s.io/repositories.config.pkg.pkgserver.dev created
apiservice.apiregistration.k8s.io/v1alpha1.pkg.pkgserver.dev created
deployment.apps/pkg-server created
clusterrole.rbac.authorization.k8s.io/pkg-server-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/package:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/pkg-server-clusterrolebinding created
role.rbac.authorization.k8s.io/pkg-server-role created
rolebinding.rbac.authorization.k8s.io/pkg-server-clusterrolebinding created
rolebinding.rbac.authorization.k8s.io/pkg-server-auth-reader created
secret/pkg-server created
service/pkg-server created
serviceaccount/pkg-server created

# install sdc: (tool to interact with yang devices from k8s) [2/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/artifacts/out/sdc.yaml
namespace/network-system created
customresourcedefinition.apiextensions.k8s.io/targetsyncprofiles.inv.sdcio.dev created
customresourcedefinition.apiextensions.k8s.io/targetconnectionprofiles.inv.sdcio.dev created
customresourcedefinition.apiextensions.k8s.io/schemas.inv.sdcio.dev created
customresourcedefinition.apiextensions.k8s.io/discoveryrules.inv.sdcio.dev created
customresourcedefinition.apiextensions.k8s.io/targets.inv.sdcio.dev created
apiservice.apiregistration.k8s.io/v1alpha1.config.sdcio.dev created
deployment.apps/config-server created
clusterrole.rbac.authorization.k8s.io/config-server-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/config-server-clusterrolebinding created
clusterrolebinding.rbac.authorization.k8s.io/config:system:auth-delegator created
role.rbac.authorization.k8s.io/aggregated-apiserver-role created
rolebinding.rbac.authorization.k8s.io/config-server-clusterrolebinding created
rolebinding.rbac.authorization.k8s.io/config-auth-reader created
configmap/data-server created
persistentvolumeclaim/pvc-config-store created
persistentvolumeclaim/pvc-schema-db created
persistentvolumeclaim/pvc-schema-store created
secret/config-server-cert created
service/config-server created
service/data-server created
serviceaccount/config-server created

# install kuid-server: (tool for inventory and identity (IPAM/VLAN/AS/etc) using k8s api [3/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/artifacts/out/kuid-server.yaml
namespace/kuid-system created
apiservice.apiregistration.k8s.io/v1alpha1.as.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.extcomm.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.genid.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.infra.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.ipam.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.vlan.be.kuid.dev created
apiservice.apiregistration.k8s.io/v1alpha1.vxlan.be.kuid.dev created
deployment.apps/kuid-server created
clusterrole.rbac.authorization.k8s.io/kuid-server-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kuid:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/kuid-server-clusterrolebinding created
role.rbac.authorization.k8s.io/kuid-server-apiserver-role created
rolebinding.rbac.authorization.k8s.io/kuid-server-clusterrolebinding created
rolebinding.rbac.authorization.k8s.io/kuid-server-auth-reader created
persistentvolumeclaim/pvc-config-store created
secret/kuid-server created
service/kuid-server created
serviceaccount/kuid-server created

# install kuid-apps: (apps leveraging kuid-server focussed on networking [4/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/artifacts/out/kuidapps.yaml
customresourcedefinition.apiextensions.k8s.io/networkconfigs.network.app.kuid.dev created
customresourcedefinition.apiextensions.k8s.io/networkdevices.network.app.kuid.dev created
customresourcedefinition.apiextensions.k8s.io/networks.network.app.kuid.dev created
customresourcedefinition.apiextensions.k8s.io/topologies.topo.app.kuid.dev created
deployment.apps/kuidapps created
clusterrole.rbac.authorization.k8s.io/kuidapps-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kuidapps-clusterrole-binding created
role.rbac.authorization.k8s.io/kuidapps-leader-election-role created
rolebinding.rbac.authorization.k8s.io/kuidapps-leader-election-role-binding created
serviceaccount/kuidapps created

# install kuid-nokia-srl: (vendor specific app for specific nokia srl artifacts  [5/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/artifacts/out/kuid-nokia-srl.yaml
customresourcedefinition.apiextensions.k8s.io/nodemodels.srl.nokia.app.kuid.dev created
deployment.apps/kuid-nokia-srl created
clusterrole.rbac.authorization.k8s.io/kuid-nokia-srl-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kuid-nokia-srl-clusterrole-binding created
role.rbac.authorization.k8s.io/kuid-nokia-srl-leader-election-role created
rolebinding.rbac.authorization.k8s.io/kuid-nokia-srl-leader-election-role-binding created
configmap/gotemplates-srl created
serviceaccount/kuid-nokia-srl created
```

```
kubectl get pods -A
```

```
NAMESPACE            NAME                                            READY   STATUS    RESTARTS   AGE
kube-system          coredns-5d78c9869d-pm2nc                        1/1     Running   0          22m
kube-system          coredns-5d78c9869d-t7jw6                        1/1     Running   0          22m
kube-system          etcd-kubenet-control-plane                      1/1     Running   0          23m
kube-system          kindnet-8g2cz                                   1/1     Running   0          22m
kube-system          kube-apiserver-kubenet-control-plane            1/1     Running   0          23m
kube-system          kube-controller-manager-kubenet-control-plane   1/1     Running   0          23m
kube-system          kube-proxy-8bwmb                                1/1     Running   0          22m
kube-system          kube-scheduler-kubenet-control-plane            1/1     Running   0          23m
kuid-system          kuid-nokia-srl-68d7956db8-2c89h                 1/1     Running   0          11m
kuid-system          kuid-server-74597d956b-rjkt6                    1/1     Running   0          11m
kuid-system          kuidapps-5867fbfcbf-ztrn4                       1/1     Running   0          11m
local-path-storage   local-path-provisioner-6bc4bddd6b-tjmt2         1/1     Running   0          22m
network-system       config-server-6ffb4bdcc8-wjnbw                  2/2     Running   0          11m
pkg-system           pkg-server-5444f74b69-px88b                     1/1     Running   0          11m
```

Hoera, the kubenet components are running. 🥳

Up to the next exercise [discover devices](../02-examples/02_discovery.md). Lets connect to the [srlinux][srlinux] devices, that were deployed by [containerlab][containerlab]

[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
