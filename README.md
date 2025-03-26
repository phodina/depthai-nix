# Nixpkgs DepthAIv3 

This repository provides a template for using DepthAIv3 packaged in the nixpkgs.

## Install Nix on the system

Follow the [guide](https://nixos.org/download/) to setup Nix on the Linux or MacOSX system.

On NixOS system this section will be skipped as it's already configured.

## Enable Nix features

Edit the Nix config file `~/.config/nix/nix.conf` (for user) or `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

Then restart the daemon to take the new configurtion into account.
```
sudo systemctl stop nix-daemon
sudo systemctl start nix-daemon
```

# Create Development environment
## Nix Flake

Copy the `flake.nix` (optionally also the `flake.lock`) to project directory.

To update the dependencies run the `nix flake update`. This command downloads from git the latest revision and updates the `flake.lock` file.

## Development environment

To enter the development environment run the following `nix develop`. This creates the environment based on your specification.

# Misc
## Package search

To find the packages you'd like to add you can search for them [here](https://search.nixos.org/packages)

## Binary caching

Nixos allows to build packages from sources, however, that would take long time and require lot of resources. Therefore it also allows to specify the machine that holds prebuild packages.

Setup nix daemon to look for the depthai builds in the office - TBD

## Remote building

Similiarly the Nix daemon allows you to offload the build from you machine to another remote machine running Nix daemon and later just download the built package.

Setup nix daemon to build depthai on desktop in the office - TBD

## Copying the prebuild package

Nix also allows you to simply transfer built package to another machine. So it's like manual binary cache.

Give example how to do that - TBD

# Upstreaming
- [x] [apriltag](https://github.com/NixOS/nixpkgs/pull/392308)
- [x] [xlink](https://github.com/NixOS/nixpkgs/pull/392352)
- [ ] [libnop](https://github.com/NixOS/nixpkgs/pull/393017)
- [ ] [neargye-semver](https://github.com/NixOS/nixpkgs/pull/393018)
- [ ] [cpr](https://github.com/NixOS/nixpkgs/pull/393020)
- [ ] [ws-protocol](https://github.com/NixOS/nixpkgs/pull/393027)
- [ ] [fp16](https://github.com/NixOS/nixpkgs/pull/393036)

## TBD
- [ ] [depthai-data](https://github.com/phodina/depthai-data)
  - solve manily Licenses of the files 
  - maybe move under Luxonis git repo
- [ ] [depthai-core](https://github.com/phodina/nixpkgs/commits/depthaiv3_upstream/)
  - solve the list of patches that need to be applied
  - unify the MacOSX and Linux builds
  - upstream the fixes for other packages to build depthai-core on MacOSX 
  - split into generic part and then create different version of the package - core C/C++, Python, w/ OpenCV
