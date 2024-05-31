# Network Config

Configuring networking involves managing numerous parameters and fine-tuning various settings. In this exercise, we demonstrate how to define network-wide parameters that network design engineers can use to accommodate diverse environments. The goal is to decouple the network design details from the service configuration. As such the detailed network design parameters are hidden from the people consuming the network. This is a technique to help abstraction.

First, we create an IP Index, which acts like a routing table. This IP Index serves as the global network IP range for the entire setup. We configure both IPv4 and IPv6 prefixes to ensure comprehensive coverage and flexibility in addressing.


/// details | IP Index

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-ipindex.yaml
--8<--
```
///

The 2nd configuration defines various parameters for the network that are specific to network designers.

- Which IP prefix to be used for interfaces versus loopback IP(s)
- The selection of dual stack for addressing
- The use of EBGP for the underlay and the respective AS pool, for allocating AS numbers per device.
- The usage of a RR for IBGP
- The selection of EVPN for the overlay routes for L2 and L3
- Which encapsulation is used for overlays
- etc

!!!note "The parameters can be extended/tuned for other environments. The idea here is to show how one could use such a concept"

Below we can see which information we use in this exercise

/// details | Network config

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-networkconfig.yaml
--8<--
```
///

Execute the following command

```
kubenetctl networkconfig
```

```shell
Configue the default network configuration (config parameters for the underlay)
===============================================================================
# apply the ip index (network prefixes the network is setup with) [1/2]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-ipindex.yaml
ipindex.ipam.be.kuid.dev/topo3nodesrl.default created

# apply the network config (network parameters for your network, BGP, VXLAN, Prefixes) [2/2]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-networkconfig.yaml
networkconfig.network.app.kuid.dev/topo3nodesrl.default created
```

Lets see what happened

An IP index is created with the respective IPs

```
kubectl get ipindices.ipam.be.kuid.dev 
```

```
NAME                   READY   PREFIX0      PREFIX1     PREFIX2       PREFIX3     PREFIX4
topo3nodesrl.default   True    10.0.0.0/8   1000::/32   192.0.0.0/8   1192::/32
```

A Set of IP claims are created for the respective loopbacks and inter-subnet links.

```
kubectl get ipclaims.ipam.be.kuid.dev 
```

```

NAME                                READY   INDEX                  CLAIMTYPE      PREFIXTYPE   CLAIMREQ       CLAIMRSP       DEFAULTGATEWAY
topo3nodesrl.default.10.0.0.0-16    True    topo3nodesrl.default   staticPrefix   pool         10.0.0.0/16    10.0.0.0/16    
topo3nodesrl.default.1000---64      True    topo3nodesrl.default   staticPrefix   pool         1000::/64      1000::/64      
topo3nodesrl.default.1192---56      True    topo3nodesrl.default   staticPrefix   network      1192::/56      1192::/56      
topo3nodesrl.default.192.0.0.0-16   True    topo3nodesrl.default   staticPrefix   network      192.0.0.0/16   192.0.0.0/16  
```

The AS pool is setup and we registered the AS number for the network

```
kubectl get asclaims.as.be.kuid.dev 
```

```
NAME                          READY   INDEX                  CLAIMTYPE   CLAIMREQ      CLAIMRSP
topo3nodesrl.default.aspool   True    topo3nodesrl.default   range       65000-65100   65000-65100
topo3nodesrl.default.ibgp     True    topo3nodesrl.default   staticID    65535         65535
```

All these parameters are registered through [kuid][kuid] API and can be leveraged as a source of truth that various components leverage for specific use cases. In the next examples you will see how certain networking applications leverage this for configuring the network,

You are ready to configure underlay and overlay !!!.


[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF