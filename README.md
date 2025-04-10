# Netmask theme

A non-intrusive, Termux-first utilitarian theme for [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh).

* IPv4 address
  * Cross-platform: uses own implementation via C stdlib
  to avoid `ifconfig`/`ip addr`/Termux permission inconsistencies
* Full directory structure
* Git branch and status
* Virtual environment
* Support for the new high-speed [async prompt](https://github.com/ohmyzsh/ohmyzsh/issues/12328#issuecomment-2043492331)

![Netmask theme preview](preview.png)

Tested on rootless Android 13+ Termux and various
desktop glibc Linux distributions.

## Installation

```bash
git clone https://github.com/swomf/netmask-zsh-theme
cd netmask-zsh-theme
make nconfig # Recommended. May not be necessary.
make && make install
# if necessary, use `sudo -E make install` instead.
```

### Why `make nconfig?`

By default, the theme will print the first network interface that
starts with `wl` (e.g. `wlan0`, `wlp3s0`). However, some may prefer
to explicitly define their wanted interface, or change it to `tun0`
or something else.

Run `make help` for more information.


## Roadmap

* [ ] Improve installation process when using `sudo`
  * `sudo -E` is sometimes needed because the presence of
  ohmyzsh is detected in the project Makefile via the `$ZSH` env var;
  this may not be defined in `/root/.zshrc` for system-wide ohmyzsh
  installations.
* [ ] Test on non-glibc systems
  * [ ] macOS (Apple C Library)
  * [ ] \*BSD (libc)
  * [ ] Alpine Linux/Void Linux (musl)
  * [ ] MinGW-w64 (msvcrt)

## Inspiration

* [rkj-repos zsh theme](https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/rkj-repos.zsh-theme) (MIT): some icon choices
* [heapbytes zsh theme](https://github.com/heapbytes/heapbytes-zsh) (MIT): main inspiration

No code was reused.
