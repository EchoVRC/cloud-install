# colors
darkgrey="$(tput bold ; tput setaf 1)"
white="$(tput bold ; tput setaf 7)"
timecolor="$(tput bold; tput setaf 46)"
stagecolor="$(tput bold; tput setaf 4)"
nc="$(tput sgr0)"

# exports
export PATH="${HOME}/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:"
export PATH="${PATH}/usr/local/sbin:/opt/bin:/usr/bin/core_perl:/usr/games/bin:"
export LD_PRELOAD=""
export EDITOR="vim"
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
export PROMPT_COMMAND=prompt_cmd

prompt_cmd () {
    cmdstatus=$?
    PS1=""
    [[ "$cmdstatus" -ne "0" && "$cmdstatus" -ne "130" ]] && PS1="\n\[$(tput setaf 196)\]$cmdstatus "
    history -a
    PS1="$PS1\[$timecolor\][\A]\[$white\]:\[$stagecolor\][\u@\h \[$white\]\W\[$stagecolor\]]\$ \[$nc\]"
}

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

getcolors()(
color(){
    for c; do
        printf '\e[48;5;%dm%03d' $c $c
    done
    printf '\e[0m \n'
}

IFS=$' \t\n'
color {0..15}
for ((i=0;i<6;i++)); do
    color $(seq $((i*36+16)) $((i*36+51)))
done
color {232..255}
)

mem()(ps aux | awk '{print $6/1024 " MB\t\t" $11}' | sort -n)

urlencode()(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$1")

alias ail="ansible-inventory --list"
alias ls="ls --color"
alias l="ls -latrh --color"
alias t="tree -Csh"
alias vi="vim"
alias shred="shred -zf"
#alias python="python2"
alias wget="wget -U 'noleak'"
alias curl="curl --user-agent 'noleak'"
alias ap="ansible-playbook"
alias an="ansible"
alias anr="ansible -m reboot"
alias lsblk="lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,MODEL"
alias getpass="openssl rand -base64"
alias apt=pacman-alias
alias apt-get=pacman-alias
alias yum=pacman-alias
alias t2qr="qrencode -t ANSI256UTF8 --"

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

export TESSDATA_PREFIX=/usr/share/

getresizespeed()(echo $(( (0 - $(ls -la $1 | awk '{print $5}') + $(sleep 10 && ls -la $1 | awk '{print $5}'))/10/1024/1024))МБ/c)

