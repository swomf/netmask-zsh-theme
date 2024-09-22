# netmask.zsh-theme -- Based on rkj-repos and heapbytes
# Built with Termux compatibility in mind.

# ╭─[192.168.1.2] ~/git/py-stuff main +✈ 
# ╰─(env)—> 

# If git_prompt_status makes the zsh prompt load slowly in a big git repo, use:
# $ `git config --add oh-my-zsh.hide-status 1`
# $ `git config --add oh-my-zsh.hide-dirty 1` 
# within the repo. This disables the git status in the prompt.

# ============================
# = ENV INDICATOR            =
# ============================

# Move env so it doesn't mess up positioning of the arrows
export VIRTUAL_ENV_DISABLE_PROMPT=1
get_venv_info() {
  if test -d "$VIRTUAL_ENV"; then
    echo "(%{$fg_bold[cyan]%}env%{$fg_bold[blue]%})—"
  fi
}
get_venv_info_breeze() {
  if test -d "$VIRTUAL_ENV"; then
    echo "(%{$fg_bold[green]%}env%{$fg_bold[blue]%})—"
  fi
}

# ============================
# = IP ADDRESS               =
# ============================

# `ifconfig` depends on net-tools. If needed, change to `ip a` and `getline; nextline`.
# `awk` is used instead of a direct `ip a` or `ifconfig wlan0` for rootless Termux users.
get_ip_addr() { # awk: look for wlan0, get line below it, ensure field 1 ends with inet
  ifconfig 2>/dev/null | awk '/wlan0/ {getline; if ($1 ~ "inet$") print $2}'
}

get_ip_addr_alternate() { # add a space before ip number
  ifconfig 2>/dev/null | awk '/wlan0/ {getline; if ($1 ~ "inet$") print " "$2}'
}

# ============================
# = GIT PROMPT               =
# ============================

# note: git_prompt_status may cause lag in certain repositories
#       see https://github.com/ohmyzsh/ohmyzsh/discussions/9849
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}✱ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ " # ⨯
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}➦ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%}✀ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]%}✈ "

# ============================
# = ZSH PROMPT               =
# ============================

# colors: main -- ip only
PROMPT='\
%{$fg_bold[blue]%}╭─[%{$fg[cyan]%}$(get_ip_addr)%{$reset_color%}%{$fg_bold[blue]%}]%{$reset_color%} %{$fg[cyan]%}%~ %{$fg_bold[green]%}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}
%{$fg_bold[blue]%}╰─$(get_venv_info)>%{$reset_color%} '

# colors: breeze -- ip only
# PROMPT='\
# %{$fg_bold[blue]%}╭─[%{$fg_bold[green]%}$(get_ip_addr)%{$reset_color%}%{$fg_bold[blue]%}]%{$reset_color%} %{$fg[blue]%}%~ %{$fg_bold[green]%}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}
# %{$fg_bold[blue]%}╰─$(get_venv_info)>%{$reset_color%} '

# colors: breeze -- user@host with ip 
# PROMPT='%{$fg_bold[blue]%}╭─[%{$fg_bold[green]%}%n%b%{$fg[black]%}@%{$fg[cyan]%}%m%{$fg_bold[cyan]%}$(get_ip_addr_alternate)%{$reset_color%}%{$fg_bold[blue]%}]%{$reset_color%} %{$fg[blue]%}%~ %{$fg_bold[green]%}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}
# %{$fg_bold[blue]%}╰─$(get_venv_info)>%{$reset_color%} '

# ============================
# = ZSH PS2                  =
# ============================

# Alternative shell prompt when a command continues, e.g. when using CAT << EOF
# >
PS2=' %{$fg_bold[blue]%}>%{$reset_color%} '
