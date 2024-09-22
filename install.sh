#!/bin/sh

# Message utils
arrow_msg() {
  printf "%s => %s%s%s%s\n" \
    "$(tput setaf 2 bold)" "$(tput sgr0)" \
    "$(tput bold)" "${1}" "$(tput sgr0)"
}
arrow_err() {
  printf "%s => %s%s%s%s\n" \
    "$(tput setaf 1 bold)" "$(tput sgr0)" \
    "$(tput bold)" "${1}" "$(tput sgr0)"
}

# Check if oh-my-zsh is installed
if ! test -d "$ZSH"; then
  arrow_err "Could not find oh-my-zsh. Quitting"
  exit 1
fi

# ============================

# Prepare a temp file for editing
arrow_msg "Preparing temp file"
cp netmask.zsh-theme temp-netmask.zsh-theme

# Switch to `ip addr` if not using Termux
#   Because `ifconfig` does not bind to the netlink socket, it is preferred
#   over `ip addr` for rootless Termux users on Android 13+ SELinux.
#   See https://github.com/termux/termux-app/issues/2993
using_termux=$(echo "$HOME" | awk "/com.termux/ {print}")
ifconfig_exists=$(command -v ifconfig)

if [ -z "$using_termux" ]; then
  # Replace `ifconfig` with `ip a` on non-commented lines
  arrow_msg "Replaced \`ifconfig\` with \`ip a\`"
  sed -i '/^#/b; s#ifconfig#ip a#g' temp-netmask.zsh-theme
  # Also change `getline`; to `getline; getline`
  #   `ifconfig` has the IPv4 address just below the interface name
  #   `ip a` has the IPv4 address two lines below the interface name
  sed -i 's/getline;/getline; getline;/g' temp-netmask.zsh-theme
fi


# Determine relevant network interface
#   The move to the Predictable Names scheme means that wireless network interfaces
#   are not necessarily named wlan0. To revert to wlan0 on rooted computers, run
#   $ ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules
#   This search is not needed for Termux.
network_interface="wlan0"
if [ -z "$using_termux" ]; then
  wifi_example=
  if [ -n "$ifconfig_exists" ]; then
    ifconfig 2>/dev/null | \
      awk '/^[a-zA-Z0-9]+:/ {printf $1" "; getline; printf (($1 ~ "inet$") ? $2"\n" : "\n")}'
    wifi_example="$(ifconfig | awk '/flags/ && !/^lo:/ { print substr($1, 1, length($1)-1); exit }')"
  else
    ip a | awk '{if ($0 ~ /[a-zA-Z0-9]+: /) printf "\n"$2" "; else if ($0 ~ /inet /) printf $2}' && printf '\n'
    wifi_example=$(ip a | awk '/[a-zA-Z0-9]+: / && !/lo:/ {print substr($2, 1, length($2)-1); exit}')
  fi
  arrow_msg "From the list, type the network interface name
    that you want to display. e.g. ${wifi_example}"
  read -r network_interface
fi

# Replace `wlan0` with network interface name
arrow_msg "Setting network interface name to ${network_interface}"
sed -i "s#/wlan0/#/${network_interface}/#g" temp-netmask.zsh-theme

# get sudo permission if $ZSH is within the /usr/share directory
arrow_msg "Installing to ${ZSH}/themes/netmask.zsh-theme"
if test "$(dirname "$ZSH")" = '/usr/share'; then
  sudo -v
  sudo install -Dm644 temp-netmask.zsh-theme "$ZSH/themes/netmask.zsh-theme"
else
  install -Dm644 temp-netmask.zsh-theme "$ZSH/themes/netmask.zsh-theme"
fi
arrow_msg "Installed."

printf "\n"

has_zstyle="$(grep "^zstyle ':omz:alpha:lib:git' async-prompt no" ~/.zshrc 2>/dev/null)"
if test -n "$has_zstyle"; then
  arrow_msg \
  "Post-install: Poor zstyle detected. Please remove
        zstyle ':omz:alpha:lib:git' async-prompt no
    from ~/.zshrc; this will increase prompt load speed."
else
  arrow_msg \
"Post-install: If you have async-prompt disabled, please remove 
        zstyle ':omz:alpha:lib:git' async-prompt no
    from your ~/.zshrc. This will increase prompt load speed."
fi