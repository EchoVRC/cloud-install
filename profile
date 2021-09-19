# colors
darkgrey="$(tput bold ; tput setaf 1)"
white="$(tput bold ; tput setaf 7)"
blue="$(tput bold; tput setaf 4)"
cyan="$(tput bold; tput setaf 6)"
nc="$(tput sgr0)"

# exports
export PATH="${HOME}/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:"
export PATH="${PATH}/usr/local/sbin:/opt/bin:/usr/bin/core_perl:/usr/games/bin:"
#export PS1="\[$blue\][ \[$cyan\]\H \[$darkgrey\]\w\[$darkgrey\] \[$blue\]]\\[$darkgrey\]$ \[$nc\]"
export PS1='\[\e[0;32m\][\A]\[\e[0m\]:\[\e[0;31m\][\u@\h \[\e[0;94m\]\[\e[0;31m\]\W]\$ \[\e[0m\]'
export LD_PRELOAD=""
export EDITOR="vim"
#export MSF_DATABASE_CONFIG="`ls ~/.msf4/database.yml`"
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config

# alias
pacman-alias(){
  if [ $# -gt 0 ] && [ "$1" == "install" ] ; then
     shift
     pacman -S "$@"
  elif [ $# -gt 0 ] && [ "$1" == "search" ] ; then
     shift
     pacman -Ss "$@"
  else
     echo "$@"
     echo 'This is archlinux!' && false
  fi
}

mem()(ps aux | awk '{print $6/1024 " MB\t\t" $11}' | sort -n)


alias ls="ls --color"
alias l="ls -la --color"
alias t="tree -Csh"
alias vi="vim"
alias shred="shred -zf"
alias wget="wget -U 'noleak'"
alias curl="curl --user-agent 'noleak'"
alias ap="ansible-playbook"
alias ail="ansible-inventory --list"
alias an="ansible"
alias anr="ansible -m reboot"
alias lsblk="lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,MODEL"
alias getpass="openssl rand -base64"
alias apt=pacman-alias
alias apt-get=pacman-alias
alias yum=pacman-alias

# source files
[ -r /usr/share/bash-completion/completions ] &&
  . /usr/share/bash-completion/completions/*

function getpkgsize(){
	LC_ALL=C pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h
}

linstor()(kubectl -n piraeus-system exec -it piraeus-controller-0 -- linstor $@)

complete -C /usr/bin/mcli mcli

declare -x HISTCONTROL="ignoredups"
declare -x HISTFILESIZE="10000"
declare -x HISTSIZE="10000"
declare -x HISTTIMEFORMAT="%F %T "
shopt -s histappend
PROMPT_COMMAND='history -a'

export TESSDATA_PREFIX=/usr/share/

getresizespeed()(echo $(( (0 - $(ls -la $1 | awk '{print $5}') + $(sleep 10 && ls -la $1 | awk '{print $5}'))/10/1024/1024))МБ/c)

#export http_proxy='http://user:user@ip:port'
