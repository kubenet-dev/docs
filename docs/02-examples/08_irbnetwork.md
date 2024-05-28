# IRB Overlay Network

In this exercise we configure a irb overlay network using EVPN. The same principle apply here. The default network config is used to simplify the configuration for the end user as much as possible. Also note that the same API can be used to configure both routed and/or bridged instances.

/// details | IRB Network

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/vpc3-irb-network.yaml
--8<--
```
///

Execute the following command to instantiate the routed network

/// tab | Interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl networkirb
```

///

/// tab | Automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically one after the other

```
kubenetctl networkirb -a
```

///


```shell
Configue a IRB overlay EVPN network
===================================
# apply the default network config [1/1]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/network/vpc3-irb-network.yaml
network.network.app.kuid.dev/topo3nodesrl.vpc3 created
```

An abstract data model is derived per device for this confiuration, which is translated to the specific implementation of [srlinux][srlinux] and finally transacted to the device. Important to note that only Edge01 and edge01 has a configuration, since these devices are only used for this specific configuration. The topology information is used to determine this.

The abstracted device models per device can be viewed with this command.

```
kubectl get networkdevices.network.app.kuid.dev
```

```
AME                          READY   PROVIDER
topo3nodesrl.default.core01   True    srlinux.nokia.com
topo3nodesrl.default.edge01   True    srlinux.nokia.com
topo3nodesrl.default.edge02   True    srlinux.nokia.com
topo3nodesrl.vpc1.edge01      True    srlinux.nokia.com
topo3nodesrl.vpc1.edge02      True    srlinux.nokia.com
topo3nodesrl.vpc2.edge01      True    srlinux.nokia.com
topo3nodesrl.vpc2.edge02      True    srlinux.nokia.com
topo3nodesrl.vpc3.edge01      True    srlinux.nokia.com
topo3nodesrl.vpc3.edge02      True    srlinux.nokia.com
```

!!!Note "through the -o yaml option in `kubectl` you get the detailed view of the config in yaml format; -o json provide the json based output"

example command for the abstracted config of the edge01 device

```
kubectl get networkdevices.network.app.kuid.dev topo3nodesrl.vpc3.edge01 -o yaml
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
topo3nodesrl.vpc1.edge01      True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc1.edge02      True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc2.edge01      True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc2.edge02      True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc3.edge01      True    ready    default/edge01   srl.nokia.sdcio.dev/24.3.2
topo3nodesrl.vpc3.edge02      True    ready    default/edge02   srl.nokia.sdcio.dev/24.3.2
```

!!!Note "through the -o yaml option in `kubectl` you get the detailed view of the config in yaml format; -o json provide the json based output"

example command for the detailed [srlinux][srlinux] config of the edge01 device

```
kubectl get configs.config.sdcio.dev  topo3nodesrl.vpc3.edge01 -o yaml
```

Let's check if this final ended up on the devices

/// tab | edge01

```
A:edge01# show network-instance summary
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+
|             Name             |      Type      |  Admin state   |   Oper state   |          Router id           |             Description              |
+==============================+================+================+================+==============================+======================================+
| default                      | default        | enable         | up             |                              | k8s-default                          |
| mgmt                         | ip-vrf         | enable         | up             |                              | Management network instance          |
| vpc1.br10                    | mac-vrf        | enable         | up             | N/A                          | k8s-vpc1.br10                        |
| vpc2.rt20                    | ip-vrf         | enable         | up             |                              | k8s-vpc2.rt20                        |
| vpc3.br30                    | mac-vrf        | enable         | up             | N/A                          | k8s-vpc3.br30                        |
| vpc3.rt35                    | ip-vrf         | enable         | up             |                              | k8s-vpc3.rt35                        |
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
| vpc2.rt20                    | ip-vrf         | enable         | up             |                              | k8s-vpc2.rt20                        |
+------------------------------+----------------+----------------+----------------+------------------------------+--------------------------------------+

--{ + running }--[  ]--
```

You can also see the resulting configuration using kubectl using the following command.

```
kubectl get runningconfigs.config.sdcio.dev edge01 -o yaml
kubectl get runningconfigs.config.sdcio.dev edge02 -o yaml
```

Nice, a single API for both routed and/or bridged !! Lets explore gitops.

///

[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF