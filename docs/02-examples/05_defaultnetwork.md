# Default Network

In this exercise we create the default network. The default network is your underlay network configuration, the network that interconnects all the devices. Looking at the configuration it looks really slim. The reason is that this leverages the parameters setup in the previous step [network config][network config].

/// details | Default Network

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-network.yaml
--8<--
```
///

Execute the following command to instantiate the default network

```
kubenetctl networkdefault
```

```shell
Configue the default underlay network
=====================================
# apply the default network config [1/1]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-network.yaml
network.network.app.kuid.dev/topo3nodesrl.default created
```

While this looks really simple, a lot is happening under the hood. This default network is leveraging the network config setup in the previous step and allocates AS per device for the underlay, It allocate a IP prefix for each link in the network per address family and a IP address for its individual enpoints, etc. On top a device config is derived thorugh an abstract data model, which is mapped to [srlinux][srlinux] for the specific implementation of the device. Once the device configuration is available for all the devices, the configurations are transacted to the device using [sdc][sdc].

!!!note "In a later exercise (gitops) you will see that another option is to check in the resulting device configurations in git, rather than transacting to the network".

Lets go through some resources that got allocated through these steps.

First an AS number per device is allocated, through the ASClaim API.

```
kubectl get asclaims.as.be.kuid.dev 
```

```
NAME                          READY   INDEX                  CLAIMTYPE   CLAIMREQ      CLAIMRSP
topo3nodesrl.default.aspool   True    topo3nodesrl.default   range       65000-65100   65000-65100
topo3nodesrl.default.core01   True    topo3nodesrl.default   dynamicID                 65002
topo3nodesrl.default.edge01   True    topo3nodesrl.default   dynamicID                 65001
topo3nodesrl.default.edge02   True    topo3nodesrl.default   dynamicID                 65000
topo3nodesrl.default.ibgp     True    topo3nodesrl.default   staticID    65535         65535
```

A Set of IP claims are created for the respective loopbacks and inter-subnet links using the IPClaim API.

```
kubectl get ipclaims.ipam.be.kuid.dev 
```

```
NAME                                                 READY   INDEX                  CLAIMTYPE        PREFIXTYPE   CLAIMREQ       CLAIMRSP                           DEFAULTGATEWAY
topo3nodesrl.default.10.0.0.0-16                     True    topo3nodesrl.default   staticPrefix     pool         10.0.0.0/16    10.0.0.0/16                        
topo3nodesrl.default.1000---64                       True    topo3nodesrl.default   staticPrefix     pool         1000::/64      1000::/64                          
topo3nodesrl.default.1192---56                       True    topo3nodesrl.default   staticPrefix     network      1192::/56      1192::/56                          
topo3nodesrl.default.192.0.0.0-16                    True    topo3nodesrl.default   staticPrefix     network      192.0.0.0/16   192.0.0.0/16                       
topo3nodesrl.default.core01.e1-1.ipv4                True    topo3nodesrl.default   dynamicAddress   network                     192.0.255.253/31                   
topo3nodesrl.default.core01.e1-1.ipv6                True    topo3nodesrl.default   dynamicAddress   network                     1192::2/127                        
topo3nodesrl.default.core01.e1-2.ipv4                True    topo3nodesrl.default   dynamicAddress   network                     192.0.0.3/31                       
topo3nodesrl.default.core01.e1-2.ipv6                True    topo3nodesrl.default   dynamicAddress   network                     1192::ff:ffff:ffff:ffff:fffd/127   
topo3nodesrl.default.core01.ipv4                     True    topo3nodesrl.default   dynamicAddress   pool                        10.0.0.0/32                        
topo3nodesrl.default.core01.ipv6                     True    topo3nodesrl.default   dynamicAddress   pool                        1000::2/128                        
topo3nodesrl.default.edge01.e1-49.core01.e1-1.ipv4   True    topo3nodesrl.default   dynamicPrefix    network                     192.0.255.252/31                   
topo3nodesrl.default.edge01.e1-49.core01.e1-1.ipv6   True    topo3nodesrl.default   dynamicPrefix    network                     1192::2/127                        
topo3nodesrl.default.edge01.e1-49.ipv4               True    topo3nodesrl.default   dynamicAddress   network                     192.0.255.252/31                   
topo3nodesrl.default.edge01.e1-49.ipv6               True    topo3nodesrl.default   dynamicAddress   network                     1192::3/127                        
topo3nodesrl.default.edge01.ipv4                     True    topo3nodesrl.default   dynamicAddress   pool                        10.0.0.1/32                        
topo3nodesrl.default.edge01.ipv6                     True    topo3nodesrl.default   dynamicAddress   pool                        1000::1/128                        
topo3nodesrl.default.edge02.e1-49.core01.e1-2.ipv4   True    topo3nodesrl.default   dynamicPrefix    network                     192.0.0.2/31                       
topo3nodesrl.default.edge02.e1-49.core01.e1-2.ipv6   True    topo3nodesrl.default   dynamicPrefix    network                     1192::ff:ffff:ffff:ffff:fffc/127   
topo3nodesrl.default.edge02.e1-49.ipv4               True    topo3nodesrl.default   dynamicAddress   network                     192.0.0.2/31                       
topo3nodesrl.default.edge02.e1-49.ipv6               True    topo3nodesrl.default   dynamicAddress   network                     1192::ff:ffff:ffff:ffff:fffc/127   
topo3nodesrl.default.edge02.ipv4                     True    topo3nodesrl.default   dynamicAddress   pool                        10.0.0.2/32                        
topo3nodesrl.default.edge02.ipv6                     True    topo3nodesrl.default   dynamicAddress   pool                        1000::/128    
```

The abstracted device models per device can be viewed with this command

```
kubectl get networkdevices.network.app.kuid.dev
```

```
NAME                          READY   PROVIDER
topo3nodesrl.default.core01   True    srlinux.nokia.com
topo3nodesrl.default.edge01   True    srlinux.nokia.com
topo3nodesrl.default.edge02   True    srlinux.nokia.com
```

!!!Note "through the -o yaml option in `kubectl` you get the detailed view of the config in yaml format; -o json provide the json based output"

example command for the abstracted config of the edge01 device

```
kubectl get networkdevices.network.app.kuid.dev topo3nodesrl.default.edge01 -o yaml
```

The final device specific [srlinux][srlinux] configuration send to the device can be seen through this command.

```
kubectl get configs.config.sdcio.dev 
```

```
NAME                          READY   REASON   TARGET           SCHEMA
topo3nodesrl.default.core01   True    ready    default/core01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.default.edge01   True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.default.edge02   True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
```

!!!Note "through the -o yaml option in `kubectl` you get the detailed view of the config in yaml format; -o json provide the json based output"

example command for the detailed [srlinux][srlinux] config of the edge01 device

```
kubectl get configs.config.sdcio.dev  topo3nodesrl.default.edge01 -o yaml
```

Let's check if this finally ended up on the devices

/// tab | edge01

```
docker exec clab-topo3nodesrl-edge01 sr_cli -- show network-instance summary
```

Expected output

```
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
|             Name             |      Type      |  Admin state   |   Oper state   |          Router id           |             Description              |
+==============================+================+================+================+==============================+======================================+
| default                      | default        | enable         | up             |                              | k8s-default                          |
| mgmt                         | ip-vrf         | enable         | up             |                              | Management network instance          |
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
```

```
docker exec clab-topo3nodesrl-edge01 sr_cli -- show network-instance default protocols bgp neighbor
```

Expected output

```
----------------------------------------------------------------------------------------------------------------------------------------------------------
BGP neighbor summary for network-instance "default"
Flags: S static, D dynamic, L discovered by LLDP, B BFD enabled, - disabled, * slow
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
+-----------------+-------------------------+-----------------+------+---------+--------------+--------------+------------+-------------------------+
|    Net-Inst     |          Peer           |      Group      | Flag | Peer-AS |    State     |    Uptime    |  AFI/SAFI  |     [Rx/Active/Tx]      |
|                 |                         |                 |  s   |         |              |              |            |                         |
+=================+=========================+=================+======+=========+==============+==============+============+=========================+
| default         | 10.0.0.0                | overlay         | S    | 65535   | established  | 0d:0h:8m:2s  | evpn       | [0/0/0]                 |
|                 |                         |                 |      |         |              |              | ipv4-      | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | unicast    | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 192.0.255.253           | underlay        | S    | 65002   | established  | 0d:0h:8m:32s | ipv4-      | [2/2/1]                 |
|                 |                         |                 |      |         |              |              | unicast    | [2/2/1]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 1192::2                 | underlay        | S    | 65002   | established  | 0d:0h:8m:37s | ipv4-      | [3/1/3]                 |
|                 |                         |                 |      |         |              |              | unicast    | [3/2/3]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
+-----------------+-------------------------+-----------------+------+---------+--------------+--------------+------------+-------------------------+
----------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:
3 configured neighbors, 3 configured sessions are established,0 disabled peers
0 dynamic peers
```
///


/// tab | core01

```
docker exec clab-topo3nodesrl-core01 sr_cli -- show network-instance summary
```

Expected output

```
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
|             Name             |      Type      |  Admin state   |   Oper state   |          Router id           |             Description              |
+==============================+================+================+================+==============================+======================================+
| default                      | default        | enable         | up             |                              | k8s-default                          |
| mgmt                         | ip-vrf         | enable         | up             |                              | Management network instance          |
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+

```

Expected output

```
docker exec clab-topo3nodesrl-core01 sr_cli -- show network-instance default protocols bgp neighbor
```

```
----------------------------------------------------------------------------------------------------------------------------------------------------------
BGP neighbor summary for network-instance "default"
Flags: S static, D dynamic, L discovered by LLDP, B BFD enabled, - disabled, * slow
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
+-----------------+-------------------------+-----------------+------+---------+--------------+--------------+------------+-------------------------+
|    Net-Inst     |          Peer           |      Group      | Flag | Peer-AS |    State     |    Uptime    |  AFI/SAFI  |     [Rx/Active/Tx]      |
|                 |                         |                 |  s   |         |              |              |            |                         |
+=================+=========================+=================+======+=========+==============+==============+============+=========================+
| default         | 10.0.0.1                | overlay         | S    | 65535   | established  | 0d:0h:9m:54s | evpn       | [0/0/0]                 |
|                 |                         |                 |      |         |              |              | ipv4-      | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | unicast    | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 10.0.0.2                | overlay         | S    | 65535   | established  | 0d:0h:9m:56s | evpn       | [0/0/0]                 |
|                 |                         |                 |      |         |              |              | ipv4-      | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | unicast    | [2/0/2]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 192.0.0.2               | underlay        | S    | 65000   | established  | 0d:0h:10m:26 | ipv4-      | [1/1/2]                 |
|                 |                         |                 |      |         |              | s            | unicast    | [1/1/2]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 192.0.255.252           | underlay        | S    | 65001   | established  | 0d:0h:10m:23 | ipv4-      | [1/1/2]                 |
|                 |                         |                 |      |         |              | s            | unicast    | [1/1/2]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 1192::3                 | underlay        | S    | 65001   | established  | 0d:0h:10m:28 | ipv4-      | [3/0/3]                 |
|                 |                         |                 |      |         |              | s            | unicast    | [3/1/3]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
| default         | 1192::ff:ffff:ffff:ffff | underlay        | S    | 65000   | established  | 0d:0h:10m:31 | ipv4-      | [3/0/3]                 |
|                 | :fffc                   |                 |      |         |              | s            | unicast    | [3/1/3]                 |
|                 |                         |                 |      |         |              |              | ipv6-      |                         |
|                 |                         |                 |      |         |              |              | unicast    |                         |
+-----------------+-------------------------+-----------------+------+---------+--------------+--------------+------------+-------------------------+
----------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:
6 configured neighbors, 6 configured sessions are established,0 disabled peers
0 dynamic peers
```

///

You can also see the resulting configuration using kubectl using the following command.

```
kubectl get runningconfigs.config.sdcio.dev core01 -o yaml
kubectl get runningconfigs.config.sdcio.dev edge01 -o yaml
kubectl get runningconfigs.config.sdcio.dev edge02 -o yaml
```

Lets see how we can do the same for overlays


[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF
[network config]: https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/default-networkconfig.yaml