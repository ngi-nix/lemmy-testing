# lemmy-testing

This repository provides a Nix flake which can be used for testing [Lemmy](https://github.com/LemmyNet/lemmy) via a NixOS VM test or inside a NixOS container.

## How-Tos

### Testing via a NixOS VM test

In order to run the VM test provided by the flake's checks output you will have to run the command below:

```bash
$ nix flake check -L
```

### Testing inside a NixOS container

Start by creating a container with the command below:

```bash
$ sudo nixos-container create lemmy --flake .#container
```

Once that done, you need to start the container you've created in the previous step, do that by executing the command below:

```bash
$ sudo nixos-container start lemmy
```

If you are interested in entering the container from a shell you can use the command below to enter the container's shell as root:

```bash
$ sudo nixos-container root-login lemmy
```
