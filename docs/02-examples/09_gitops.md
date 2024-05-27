# GitOps

So far we have seen that the device configurations that are derived from the network configs are directly transacted to the respective devices. However many people have expressed the need to validate and check the derived configurations before they can be applied to the network. This is where the package server comes in.

The philiosphy in this exercise is like this. We have a set of catalog (templates) configuration people use to configure network constructs. Lets use the overlay's as an example. We have a system (git) in which these blueprints are maintained and we want to instantiate them to the network using the flow that we saw in the previous exercises. However there is 1 big difference, rather than transacting the specific device config directly, we want to check them in into git and someone ( a human or a ci system can validate them before they get applied to the network). If this workflow is relevant for you, this is an exercise you shoudl execute.

First we register the repository in which the blueprints are maintained. This repo is public and uses a bridged network blueprint.

```
kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/main/pkg/repo/repo-catalog.yaml
```

After the repo is registered, the package server discovers the blueprint package from git. You can see the result using the following comman.

```
kubectl get packagerevisions.pkg.pkgserver.dev 
```

We discovered the blueprint package and we can access it using the kubernetes API.

```
NAME                                     READY   REPOSITORY     TARGET    REALM     PACKAGE   REVISION   WORKSPACE   LIFECYCLE
catalog.repo-catalog.network.bridge.v1   True    repo-catalog   catalog   network   bridge    v1         v1          published
```

You could also look at the content, like this

```
kubectl describe packagerevisionresourceses.pkg.pkgserver.dev catalog.repo-catalog.network.bridge.v1 
```

```
Name:         catalog.repo-catalog.network.bridge.v1
Namespace:    default
Labels:       <none>
Annotations:  pkg.pkgserver.dev/DiscoveredPkgRev: true
API Version:  pkg.pkgserver.dev/v1alpha1
Kind:         PackageRevisionResources
Metadata:
  Creation Timestamp:  2024-05-26T19:00:26Z
  Finalizers:
    packagerevision.pkg.pkgserver.dev/finalizer
    packagediscovery.pkg.pkgserver.dev/finalizer
  Resource Version:  17693
  UID:               a7d29fc6-80ef-4e84-9f7d-42bf7e3ea284
Spec:
  Package Rev ID:
    Package:     bridge
    Realm:       network
    Repository:  repo-catalog
    Revision:    v1
    Target:      catalog
    Workspace:   v1
  Resources:
    README.md:  # vpc1

This examples show a bridged network, which leverages the SRE parameters setup by the SRE on which parameters are used for your particular environemnt.

it should be used with a topology setup using the identifiers specified.

topology: topo3nodesrl
nodes: edge01, edge02
    artifacts.yaml:  apiVersion: network.app.kuid.dev/v1alpha1
kind: Network
metadata:
  name: topo3nodesrl.vpc100
  namespace: default
  annotations:
    kform.dev/block-type: resource
    kform.dev/resource-type: kubernetes_manifest 
    kform.dev/resource-id: vpc100
spec:
  topology: topo3nodesrl
  bridgeDomains:
  - name: br100
    networkID: 100
    interfaces:
    - endpoint: e1-1
      node: edge01
      region: region1
      site: site1
    - endpoint: e1-1
      node: edge02
      region: region1
      site: site1
  
---
apiVersion: kubernetes.provider.kform.dev/v1alpha1
kind: ProviderConfig
metadata:
  name: kubernetes
  namespace: default
  annotations:
    kform.dev/block-type: provider
Status:
Events:  <none>
```

To continue with this exercise you should now setup your own repository, which is used to store the derived device specific configuration. We need to provide write access to the package server. As such you should setup 2 things.

1. A git repository
2. A token to access the git repository 

I am using my own git repo to show the exercise, but this repo should be replaced with your own. [Here][pkgserver-repo] is some detail how this can be achieved.

```
kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/main/pkg/repo/repo-target.yaml
```

After this repo is registered the following show the respective information

```
kubectl get repositories.config.pkg.pkgserver.dev
```

```
NAME           READY   DEPLOYMENT   TYPE   ADDRESS
repo-catalog   True                 git    https://github.com/kubenet-dev/examples.git
repo-target    True    true         git    https://github.com/kubenet-dev/demo.git
```

Once this is configured, lets install the blueprint. This can be done using the package variant resource/API.

```
kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/main/pkg/pvar/pvar-bridge.yaml
```

A packagevariant is a way to instantiate a variant of the package revision. The package variant has an upstream reference (blueprint) and a downstream reference (the repo in which the final device configurations will be stored). On top you could also supply input variant information to customize the specific parameters for the environment. We dont use this in this excersize, but no we hope you understand where the name is coming from (Creating a variant of a blueprint package with specific parameters).

Once the package variant is instantiated a new package revision is created in the downstream repo (the repo you created) with LifecycleStatus = Draft.

```
kubectl get packagerevisions.pkg.pkgserver.dev 
```

```
NAME                                                          READY   REPOSITORY     TARGET         REALM     PACKAGE   REVISION   WORKSPACE             LIFECYCLE
catalog.repo-catalog.network.bridge.v1                        True    repo-catalog   catalog        network   bridge    v1         v1                    published
topo3nodesrl.repo-target.network.bridge.pv-077eb8d077b36655   True    repo-target    topo3nodesrl   network   bridge               pv-077eb8d077b36655   draft
```

Once the pipeline completes you should see the resulting configuration in the package revision with the final device configuration derived from the blueprint content you instantiated through the package variant.

```
kubectl describe packagerevisionresourceses.pkg.pkgserver.dev topo3nodesrl.repo-target.network.bridge.pv-077eb8d077b36655 
```

```
Name:         topo3nodesrl.repo-target.network.bridge.pv-077eb8d077b36655
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  pkg.pkgserver.dev/v1alpha1
Kind:         PackageRevisionResources
Metadata:
  Creation Timestamp:  2024-05-26T19:05:26Z
  Finalizers:
    packagerevision.pkg.pkgserver.dev/finalizer
    networkpackage.network.app.kuid.dev/finalizer
  Owner References:
    API Version:     config.pkg.pkgserver.dev/v1alpha1
    Controller:      true
    Kind:            PackageVariant
    Name:            pv-network-bridge
    UID:             90656874-0bab-44c9-b5e5-51f36120f053
  Resource Version:  18474
  UID:               ca87d87b-e468-4358-abbd-87719fe2b9d5
Spec:
  Package Rev ID:
    Package:     bridge
    Realm:       network
    Repository:  repo-target
    Target:      topo3nodesrl
    Workspace:   pv-077eb8d077b36655
  Resources:
    README.md:  # vpc1

This examples show a bridged network, which leverages the SRE parameters setup by the SRE on which parameters are used for your particular environemnt.

it should be used with a topology setup using the identifiers specified.

topology: topo3nodesrl
nodes: edge01, edge02
    artifacts.yaml:  apiVersion: network.app.kuid.dev/v1alpha1
kind: Network
metadata:
  name: topo3nodesrl.vpc100
  namespace: default
  annotations:
    kform.dev/block-type: resource
    kform.dev/resource-type: kubernetes_manifest 
    kform.dev/resource-id: vpc100
spec:
  topology: topo3nodesrl
  bridgeDomains:
  - name: br100
    networkID: 100
    interfaces:
    - endpoint: e1-1
      node: edge01
      region: region1
      site: site1
    - endpoint: e1-1
      node: edge02
      region: region1
      site: site1
  
---
apiVersion: kubernetes.provider.kform.dev/v1alpha1
kind: ProviderConfig
metadata:
  name: kubernetes
  namespace: default
  annotations:
    kform.dev/block-type: provider
    out/config.sdcio.dev_v1alpha1.Config.default.topo3nodesrl.vpc100.edge01.yaml:  apiVersion: config.sdcio.dev/v1alpha1
kind: Config
metadata:
  creationTimestamp: null
  labels:
    config.sdcio.dev/targetName: edge01
    config.sdcio.dev/targetNamespace: default
  name: topo3nodesrl.vpc100.edge01
  namespace: default
spec:
  config:
  - path: /
    value:
      interface:
      - admin-state: enable
        description: k8s-ethernet-1/1
        ethernet: {}
        name: ethernet-1/1
        subinterface:
        - admin-state: enable
          description: k8s-customer
          index: 100
          type: bridged
          vlan:
            encap:
              single-tagged:
                vlan-id: 100
        vlan-tagging: true
      network-instance:
      - admin-state: enable
        description: k8s-vpc100.br100
        interface:
        - name: ethernet-1/1.100
        name: vpc100.br100
        protocols:
          bgp-evpn:
            bgp-instance:
            - admin-state: enable
              encapsulation-type: vxlan
              evi: 100
              id: 1
              vxlan-interface: vxlan0.100
          bgp-vpn:
            bgp-instance:
            - id: 1
              route-target:
                export-rt: target:65535:100
                import-rt: target:65535:100
        type: mac-vrf
        vxlan-interface:
        - name: vxlan0.100
      tunnel-interface:
      - name: vxlan0
        vxlan-interface:
        - index: 100
          ingress:
            vni: 100
          type: bridged
  lifecycle: {}
  priority: 10
status: {}

    out/config.sdcio.dev_v1alpha1.Config.default.topo3nodesrl.vpc100.edge02.yaml:  apiVersion: config.sdcio.dev/v1alpha1
kind: Config
metadata:
  creationTimestamp: null
  labels:
    config.sdcio.dev/targetName: edge02
    config.sdcio.dev/targetNamespace: default
  name: topo3nodesrl.vpc100.edge02
  namespace: default
spec:
  config:
  - path: /
    value:
      interface:
      - admin-state: enable
        description: k8s-ethernet-1/1
        ethernet: {}
        name: ethernet-1/1
        subinterface:
        - admin-state: enable
          description: k8s-customer
          index: 100
          type: bridged
          vlan:
            encap:
              single-tagged:
                vlan-id: 100
        vlan-tagging: true
      network-instance:
      - admin-state: enable
        description: k8s-vpc100.br100
        interface:
        - name: ethernet-1/1.100
        name: vpc100.br100
        protocols:
          bgp-evpn:
            bgp-instance:
            - admin-state: enable
              encapsulation-type: vxlan
              evi: 100
              id: 1
              vxlan-interface: vxlan0.100
          bgp-vpn:
            bgp-instance:
            - id: 1
              route-target:
                export-rt: target:65535:100
                import-rt: target:65535:100
        type: mac-vrf
        vxlan-interface:
        - name: vxlan0.100
      tunnel-interface:
      - name: vxlan0
        vxlan-interface:
        - index: 100
          ingress:
            vni: 100
          type: bridged
  lifecycle: {}
  priority: 10
status: {}

Status:
Events:  <none>
```

Awesome, we hope you enjoyed and thanks for completing these exercises. If you have other ideas, suggestion or want to discuss this further join us [here]((https://discord.gg/Ed48vZcy))

[pkgserver-repo]: https://docs.pkgserver.dev/03-userguide/03_register_deployment_repo/