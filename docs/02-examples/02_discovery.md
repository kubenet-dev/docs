# Discovery

This exercise will focus on network device discovery. We will discover the deployed network devices that were deployed using [containerlab][containerlab] in the installation section.


Given [sdc][sdc] is build to support multiple vendors, the first thing we need to do is load the YANG schema for the respective vendor and release. In this exercise we use [gNMI][gnmi], but netconf could also be used.

/// details | Schema

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/schemas/srl24-3-2.yaml
--8<--
```
///

After the schema is configured we create a set of profiles that [sdc][sdc] uses to connect and sync the configurations from the devices. Also the credentials, using secrets are setup for the respectve device.

/// details | Connection Profile

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/profiles/conn-gnmi-skipverify.yaml
--8<--
```
///

/// details | Sync Profile

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/profiles/sync-gnmi-get.yaml
--8<--
```
///

Lastly we configure a discovery rule that is used by [sdc][sdc] to discover the devices within the ip range we setup in the setup step.

/// details | Discovery rule

```yaml
--8<--
https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/drrules/dr-dynamic.yaml
--8<--
```

///

/// tab | Interactive

kubenetctl has the option to run in interactive mode if you want to follow the steps one by one. If you are prompted with ..., hit ENTER

```
kubenetctl sdc
```

///

/// tab | Automatic

When specifying the automatic option -a, kubenetctl will run the steps automatically one after the other

```
kubenetctl sdc -a
```

///

```shell
Configue sdc
============
# apply the schema for srlinux 24.3.2 [1/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/schemas/srl24-3-2.yaml
schema.inv.sdcio.dev/srl.nokia.sdcio.dev-24.3.2 created

# apply the gnmi profile to connect to the target (clab node) [2/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/profiles/conn-gnmi-skipverify.yaml
targetconnectionprofile.inv.sdcio.dev/conn-gnmi-skipverify created

# apply the gnmi sync profile to sync config from the target (clab node) [3/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/profiles/sync-gnmi-get.yaml
targetsyncprofile.inv.sdcio.dev/sync-gnmi-get created

# apply the srl secret with credentials to authenticate to the target (clab node) [4/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/profiles/secret.yaml
secret/srl.nokia.sdcio.dev created

# apply the discovery rule to discover the srl devices deployed by containerlab [5/5]:

> kubectl apply -f https://raw.githubusercontent.com/kubenet-dev/kubenet/v0.0.1/sdc/drrules/dr-dynamic.yaml
discoveryrule.inv.sdcio.dev/dr-dynamic created
```

Lets see if this was successfull.

```
 kubectl get targets
```

Wow 🎉 we discovered the 3 devices setup with containerlab, with its respective MAC address, IP address, Provider, etc.

```
NAME     READY   REASON   PROVIDER              ADDRESS            PLATFORM      SERIALNUMBER     MACADDRESS
core01   True             srl.nokia.sdcio.dev   172.21.0.3:57400   7220 IXR-D3   Sim Serial No.   1A:D3:02:FF:00:00
edge01   True             srl.nokia.sdcio.dev   172.21.0.4:57400   7220 IXR-D2   Sim Serial No.   1A:16:03:FF:00:00
edge02   True             srl.nokia.sdcio.dev   172.21.0.5:57400   7220 IXR-D2   Sim Serial No.   1A:1D:04:FF:00:00
```

The following command allows to see the running config of the respective devices.

```
kubectl get runningconfigs.config.sdcio.dev core01 -o yaml
```

E.g. if you want to backup the config of your devices this command allows you to pull the configuration and back them up in your preferred backup system.

Lets configure the network devices such that we can exchange routes and validate the configuration.

[containerlab]: https://containerlab.dev
[kind]: https://kind.sigs.k8s.io
[pkgserver]: https://docs.pkgserver.dev
[sdc]: https://docs.sdcio.dev
[kuid]: https://kuidio.github.io/docs/
[srlinux]: https://learn.srlinux.dev/
[gnmi]: https://github.com/openconfig/gnmi
[netconf]: https://en.wikipedia.org/wiki/NETCONF