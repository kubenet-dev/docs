# Bridged Overlay Network

In this exercise we configure a bridged overlay network using EVPN. The same principle apply here. The default network config is used to simplify the configuration for the end user as much as possible.

/// details | Bridged Network

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/vpc1-bridged-network.yaml
--8<--
```
///

Execute the following command to instantiate the bridged network

/// tab | Interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl networkbridged
```

///

/// tab | Automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically one after the other

```
kubenetctl networkbridged -a
```

///


```shell
Configue a bridged EVPN overlay network
=======================================
# apply the default network config [1/1]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/vpc1-bridged-network.yaml
network.network.app.kuid.dev/topo3nodesrl.vpc1 created
```

An abstract data model is derived per device for this confiuration, which is translated to the specific implementation of [srlinux][srlinux] and finally transacted to the device. Important to note that only edge01 and edge02 got a new configuration, since these devices are only used for this specific configuration. The topology information is used to determine this.

The abstracted device models can be viewed with this command

```
kubectl get networkdevices.network.app.kuid.dev
```

```
NAME                          READY   PROVIDER
topo3nodesrl.default.core01   True    srlinux.nokia.com
topo3nodesrl.default.edge01   True    srlinux.nokia.com
topo3nodesrl.default.edge02   True    srlinux.nokia.com
topo3nodesrl.vpc1.edge01      True    srlinux.nokia.com
topo3nodesrl.vpc1.edge02      True    srlinux.nokia.com
```

The configuration send to the device can be seen through this command.

```
kubectl get configs.config.sdcio.dev 
```

```
NAME                          READY   REASON   TARGET           SCHEMA
topo3nodesrl.default.core01   True    ready    default/core01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.default.edge01   True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.default.edge02   True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc1.edge01      True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc1.edge02      True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
```

Lets check if this final ended up on the devices.

/// tab | edge01

```
A:edge01# show network-instance summary
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
|             Name             |      Type      |  Admin state   |   Oper state   |          Router id           |             Description              |
+==============================+================+================+================+==============================+======================================+
| default                      | default        | enable         | up             |                              | k8s-default                          |
| mgmt                         | ip-vrf         | enable         | up             |                              | Management network instance          |
| vpc1.br10                    | mac-vrf        | enable         | up             | N/A                          | k8s-vpc1.br10                        |
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+

```
///

/// tab | edge02

```
A:edge02# show network-instance summary
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
|             Name             |      Type      |  Admin state   |   Oper state   |          Router id           |             Description              |
+==============================+================+================+================+==============================+======================================+
| default                      | default        | enable         | up             |                              | k8s-default                          |
| mgmt                         | ip-vrf         | enable         | up             |                              | Management network instance          |
| vpc1.br10                    | mac-vrf        | enable         | up             | N/A                          | k8s-vpc1.br10                        |
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+

--{ + running }--[  ]--
```

You can also see the resulting configuration using kubectl using the following command.

```
kubectl get runningconfigs.config.sdcio.dev edge01 -o yaml
kubectl get runningconfigs.config.sdcio.dev edge02 -o yaml
```

Nice !!

///

[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF