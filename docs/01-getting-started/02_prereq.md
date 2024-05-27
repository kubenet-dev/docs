# Prerequisites

## CPU architecture

All the kubernetes components run on both AMD and ARM based CPU, but most network OS(es) are not supported on ARM based CPU(s). As a result use an AMD based CPU to run the exercises.

## Operating system

We tested on WSL for windows and Linux and darwin OS.

## kubectl

Install [kubectl][kubectl]

## Auto completions for kubectl (optional)

/// tab | bash

```
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
```
///

/// tab | zsh
```
source <(kubectl completion zsh)
alias k=kubectl
complete -F _start_kubectl k
```
///

## kubenetctl

kubenetctl is a single binary built for linux and Mac OS, distributed via [ghreleases][ghreleases] focussed to help run through the kubenet exercises. 

!!!note "By default it runs in interactive mode, where you need to press enter between all steps. The -a option runs the step automatically while still printing what each step does"


!!!note "The --shell option allows to change the shell used to execute the commands, by default it uses bash. If you wan to use another shell use --shell zsh e.g"

/// tab | linux/Mac OS

To download & install the latest release the following automated [installation script][installscript] can be used.

```bash
bash -c "$(curl -sL https://github.com/kubenet-dev/kubenetctl/raw/main/install.sh)"
```

As a result, the latest `kubenetctl` version will be installed in the /usr/local/bin directory and the version information will be printed out.


To install a specific version of `kubenetctl`, provide the version with -v flag to the installation script:

```bash
bash -c "$(curl -sL https://github.com/kubenet-dev/kubenetctl/raw/main/install.sh)" -- -v 0.0.1
```

///

/// tab | Packages

Linux users running distributions with support for deb/rpm packages can install gnmic using pre-built packages:

```bash
bash -c "$(curl -sL https://github.com/kubenet-dev/kubenetctl/raw/main/install.sh)" -- --use-pkg
```

///

## Install Kubernetes 

we use kind for the exercises as it is a convenient tool to setup a kubernetes cluster 

/// tab | kind

Install kind using [kind][kind-install]

In this example we install a [`kind`][kind] cluster with name `sdc`. 

```
kind create cluster --name sdc
```
///

/// tab | other
///

[kind-install]: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
[kind]: https://kind.sigs.k8s.io/
[kubectl]: https://kubernetes.io/docs/tasks/tools/
[ghreleases]: https://github.com/pkgserver-dev/pkgctl/releases
[installscript]: https://github.com/pkgserver-dev/pkgctl/blob/main/install.sh