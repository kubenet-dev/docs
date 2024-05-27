# Inventory

In this exercise, we will focus on inventory and identifiers for network automation, commonly referred to as a source of truth. The goal is to demonstrate how we can leverage the extendability and flexibility of Kubernetes, which allows customization of the API and the development of applications that utilize this API to build various constructs for different use cases.

Before configuring devices with IP, VLAN, BGP, and EVPN constructs, it is crucial to understand the topology these devices utilize. In this exercise, we have chosen to import the inventory used in the [containerlab][containerlab] setup. This approach highlights how discovery and provisioning methods can be leveraged and interworked together.

First, we create the device models for the [srlinux][srlinux] devices used in our environment. This exercise demonstrates how to use a device profile for a specific role in the network and the corresponding device configuration. Different profiles can be applied for various network roles, with this configuration serving as the source of truth. It also shows how to handle a multi-vendor environment and customize configurations for different vendors and roles in the deployment.

!!!note "This capability is enabled using [kuidapps][kuid], such as the Nokia-specific kuid app in this case. However, a specific vendor app can be installed for other vendors. In this exercise, we opted for a specific srlinux API (srl.nokia.app.kuid.dev/v1alpha1), but a vendor-agnostic API could also be used."

We used this approach because [containerlab][containerlab] will only connect and configure the interfaces used in the lab, but the automation might want to use other interfaces the device supports. You could also add specific information to each interface e.g. whether this interface is used for client/customer connectivity, etc

/// details | Specific vendor device model

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/inventory/srl/ixrd2.yaml
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/inventory/srl/ixrd3.yaml
--8<--
```
///

Afterwards you import the containerlab topology, which is used to populate the inventory in [kuid][kuid].

/// details | Topology

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/topo/3node-topology.yaml
--8<--
```
///

Execute the following command

/// tab | Interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl inventory
```

///

/// tab | Automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically one after the other

```
kubenetctl inventory -a
```

///


```shell
Configue the topology inventory
===============================
# apply the nodemodel configuration for ixrd2 srlinux device [1/3]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/inventory/srl/ixrd2.yaml
nodemodel.srl.nokia.app.kuid.dev/ixrd2.srlinux.nokia.com created

# apply the nodemodel configuration for ixrd3 srlinux device [2/3]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/inventory/srl/ixrd3.yaml
nodemodel.srl.nokia.app.kuid.dev/ixrd3.srlinux.nokia.com created

# import the containerlab topology in kubernetes [3/3]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/topo/3node-topology.yaml
topology.topo.app.kuid.dev/topo3nodesrl created
```

Lets check the inventory in [kuid][kuid].

We first see that the 3 nodes are populated in the inventory system

```
kubectl get nodes.infra.be.kuid.dev 
```

```
NAME                                READY   REGION    SITE    TOPOLOGY       PROVIDER
topo3nodesrl.region1.site1.core01   True    region1   site1   topo3nodesrl   srlinux.nokia.com
topo3nodesrl.region1.site1.edge01   True    region1   site1   topo3nodesrl   srlinux.nokia.com
topo3nodesrl.region1.site1.edge02   True    region1   site1   topo3nodesrl   srlinux.nokia.com
```

We can also check the links.

```
kubectl get links.infra.be.kuid.dev 
```

```
NAME                                                                             READY   EPA                                       EPB
topo3nodesrl.region1.site1.edge01.e1-49.topo3nodesrl.region1.site1.core01.e1-1   True    topo3nodesrl.region1.site1.edge01.e1-49   topo3nodesrl.region1.site1.core01.e1-1
topo3nodesrl.region1.site1.edge02.e1-49.topo3nodesrl.region1.site1.core01.e1-2   True    topo3nodesrl.region1.site1.edge02.e1-49   topo3nodesrl.region1.site1.core01.e1-2
```

And Lastly the endpoints

```
kubectl get endpoints.infra.be.kuid.dev 
```

!!!note "Dont mind the False ready condition in the endpoint. No k8s controller is acting on this and hence the status is False"

```
NAME                                      READY   TOPOLOGY       REGION    SITE    NODE
topo3nodesrl.region1.site1.core01.e1-1    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-10   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-11   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-12   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-13   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-14   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-15   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-16   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-17   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-18   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-19   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-2    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-20   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-21   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-22   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-23   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-24   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-25   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-26   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-27   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-28   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-29   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-3    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-30   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-31   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-32   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-33   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-34   False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-4    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-5    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-6    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-7    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-8    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.core01.e1-9    False   topo3nodesrl   region1   site1   core01
topo3nodesrl.region1.site1.edge01.e1-1    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-10   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-11   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-12   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-13   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-14   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-15   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-16   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-17   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-18   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-19   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-2    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-20   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-21   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-22   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-23   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-24   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-25   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-26   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-27   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-28   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-29   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-3    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-30   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-31   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-32   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-33   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-34   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-35   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-36   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-37   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-38   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-39   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-4    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-40   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-41   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-42   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-43   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-44   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-45   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-46   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-47   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-48   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-49   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-5    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-50   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-51   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-52   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-53   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-54   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-55   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-56   False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-6    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-7    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-8    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge01.e1-9    False   topo3nodesrl   region1   site1   edge01
topo3nodesrl.region1.site1.edge02.e1-1    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-10   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-11   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-12   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-13   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-14   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-15   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-16   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-17   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-18   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-19   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-2    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-20   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-21   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-22   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-23   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-24   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-25   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-26   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-27   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-28   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-29   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-3    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-30   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-31   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-32   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-33   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-34   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-35   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-36   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-37   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-38   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-39   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-4    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-40   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-41   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-42   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-43   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-44   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-45   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-46   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-47   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-48   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-49   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-5    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-50   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-51   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-52   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-53   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-54   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-55   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-56   False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-6    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-7    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-8    False   topo3nodesrl   region1   site1   edge02
topo3nodesrl.region1.site1.edge02.e1-9    False   topo3nodesrl   region1   site1   edge02
```

We now have a full device and link inventory in the system, which we can use to build network constructs.


[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF