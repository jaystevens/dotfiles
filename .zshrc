#!/bin/zsh
# A basically sane zsh environment.
#
# Jason Stevens (with help from the internets).

# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# complete hostnames from this file
#: ${HOSTFILE=~/.ssh/known_hosts}

# readline config
#: ${INPUTRC=~/.inputrc}

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# setup colors
autoload -U colors
colors

# setup history search (required before keys)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# setup keys
bindkey -e
# PgUP/PgDOWN key - history
bindkey "^[[5~"  up-line-or-history
bindkey "^[[6~"  down-line-or-search
# UP/DOWN key - basic search
#bindkey "^[[A"   up-line-or-search
#bindkey "^[[B"   down-line-or-search
# UP/DOWN key - beginning search
bindkey "^[[A"   up-line-or-beginning-search
bindkey "^[[B"   down-line-or-beginning-search
# HOME key
bindkey "^[[H"   beginning-of-line
bindkey "^[[1~"  beginning-of-line
bindkey "^[OH"   beginning-of-line
# END key
bindkey "^[[F"   end-of-line
bindkey "^[[4~"  end-of-line
bindkey "^[OF"   end-of-line
# magic space history thingy?
bindkey ' '      magic-space

# DELETE key
bindkey "^?"     backward-delete-char
bindkey "^[[3~"  delete-char
bindkey "^[3;5~" delete-char
bindkey "\e[3~"  delete-char

# bring in system bashrc
#if [ -r /etc/bashrc ]; then
#    . /etc/bashrc
#fi

# notify of bg job completion immediately
#set -o notify

# shell opts. see bash(1) for details
#shopt -s cdspell                 >/dev/null 2>&1
#shopt -s extglob                 >/dev/null 2>&1
#shopt -s histappend              >/dev/null 2>&1
#shopt -s hostcomplete            >/dev/null 2>&1
#shopt -s interactive_comments    >/dev/null 2>&1
#shopt -u mailwarn                >/dev/null 2>&1
#shopt -s no_empty_cmd_completion >/dev/null 2>&1

# fuck that you have new mail shit
unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
if [ "$USER" = dataman ]; then
    umask 0000
else
    umask 0022
fi

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put ~/bin on PATH if you have it
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# put StorNext in path if you have it
if [ -d "/usr/cvfs/bin" ]; then
    PATH="/usr/cvfs/bin:$PATH"
fi

# load StorNext Environment if you have it
if [ $UID -eq 0 ]; then
    if [ -e /usr/adic/.profile ]; then
        . /usr/adic/.profile
    fi
fi

# put TapeTools in path if you have it
if [ -d "/usr/tapetools/bin" ]; then
    PATH="/usr/tapetools/bin:$PATH"
fi

# put signiant dds in path if you have it
if [ -d "/usr/signiant/dds/bin" ]; then
    PATH="/usr/signiant/dds/bin:$PATH"
fi

# put anyconnect in path if you have it
if [ -d "/opt/cisco/anyconnect/bin" ]; then
    PATH="/opt/cisco/anyconnect/bin:$PATH"
fi

if [ "$USER" = dataman ]; then
    # put Atempo in path if you have it
    if [ -e "/usr/Atempo/tina/.tina.sh" ]; then
        source /usr/Atempo/tina/.tina.sh
    fi
fi

# on redhat some things compile into lib, some into lib64
if [ -e "/etc/redhat-release" ]; then
    # add "32bit" lib
    if [ -d "/usr/local/lib" ]; then
        LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
    fi
    : ${MACHINE=$(uname -m)}
    if [ "$MACHINE" = x86_64 ]; then
        if [ -d "/usr/local/lib64" ]; then
            LD_LIBRARY_PATH="/usr/local/lib64:$LD_LIBRARY_PATH"
        fi
    fi
fi

# CUDA
if [ -d "/usr/local/cuda" ]; then
    PATH="/usr/local/cuda/bin:$PATH"
    LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi


# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------

# detect interactive shell
if [[ -o interactive ]]; then
    INTERACTIVE=yes
else
    unset INTERACTIVE
fi

# detect login shell
if [[ -o login ]]; then
    LOGIN=yes
else
    unset LOGIN
fi

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"

# history stuff
HISTCONTROL=ignoreboth
HISTFILESIZE=100000
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)

# EDITOR
if [ -n "$HAVE_VIM" ]; then
    EDITOR=vim
else
    EDITOR=vi
fi
export EDITOR

# PAGER
if [ -n "$(command -v less)" ]; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# ACK
ACK_PAGER="$PAGER"
ACK_PAGER_COLOR="$PAGER"

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

# setup prompt
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

function load_out() {
if [ $UNAME = "Darwin" ]; then
    echo -n "$(uptime | sed -e "s/.*load averages: \(.*\...\) \(.*\...\) \(.*\...\).*/\1/" -e "s/ //g")"
elif [ $UNAME = "FreeBSD" ]; then
    echo -n "$(uptime | sed -e "s/.*load averages: \(.*\...\), \(.*\...\), \(.*\...\).*/\1/" -e "s/ //g")"
else
    echo -n "$(uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\).*/\1/" -e "s/ //g")"
fi
}

prompt_xbase() {
    #RED="\[\033[0;31m\]"
    #BROWN="\[\033[0;33m\]"
    #GREY="\[\033[0;97m\]"
    #BLUE="\[\033[0;34m\]"
    #PS_CLEAR="\[\033[0m\]"
    #SCREEN_ESC="\[\033k\033\134\]"
    RED="%F{red}"
    BROWN="%F{130}"
    GREY="%F{015}"
    BLUE="%F{blue}"
    PS_CLEAR="%{$reset_color%}"

    if [ "$LOGNAME" = "root" ]; then
        COLOR1="${RED}"
        COLOR2="${BROWN}"
        P="#"
    else
        COLOR1="${BLUE}"
        COLOR2="${BROWN}"
        P="\$"
    fi
}

# define prompt theme 'simple'
prompt_simple_setup() {
    prompt_xbase
    PS1="[%n@%m:%~]\$"
}
prompt_themes+=( simple )

# define prompt theme 'compact'
prompt_compact_setup() {
    prompt_xbase
    PS1="${COLOR1}${P}${PS_CLEAR} "
}
prompt_themes+=( compact )

# define prompt theme 'color'
prompt_color_setup() {
    prompt_xbase
    PS1="${GREY}[${COLOR1}%n${GREY}@${COLOR2}%m${GREY}:${COLOR1}%~${GREY}]${COLOR2}${P}${PS_CLEAR} "
}
prompt_themes+=( color )

# define prompt theme 'full'
prompt_full_setup() {
    prompt_xbase
    PS1="${GREY}[$(load_out)][%D{%H:%M}][${COLOR1}%n${GREY}@${COLOR2}%m${GREY}:${COLOR1}%~${GREY}]${COLOR2}${P}${PS_CLEAR} "
}
prompt_themes+=( full )

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ $UNAME = "Darwin" ]; then
    # put ports on the paths if /opt/local exists
    test -x /opt/local -a ! -L /opt/local && {
        PORTS=/opt/local

        # setup the PATH and MANPATH
        PATH="$PORTS/bin:$PORTS/sbin:$PATH"
        MANPATH="$PORTS/share/man:$MANPATH"

        # make sure /usr/local is infront of /opt/local
        if [ -d "/usr/local/bin" ]; then
            PATH="/usr/local/bin:$PATH"
        fi
        if [ -d "/usr/local/sbin" ]; then
            PATH="/usr/local/sbin:$PATH"
        fi

        # nice little port alias
        alias port="sudo nice -n +18 $PORTS/bin/port"
    }

    test -x /usr/pkg -a ! -L /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }

    # setup java environment. puke.
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
    
    alias mac_hw_profile="system_profiler SPHardwareDataType"
fi

# ----------------------------------------------------------------------
# whatshell
# ----------------------------------------------------------------------

function whatshell() {
    SHELL_NAME="Unknown"
    SHELL_VER=""

    if [ -n "$BASH_VERSION" ]; then
        SHELL_NAME="BASH"
        SHELL_VER="${BASH_VERSION}"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_NAME="ZSH"
        SHELL_VER="$ZSH_VERSION"
    fi
    echo ${SHELL_NAME} ${SHELL_VER}
}

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
if [ $UNAME = "Darwin" ]; then
    alias du1='du -h -d 1 | sort -k2'
    alias du1s='date > du.txt; du -h -d 1 | sort -k2 >> du.txt; chmod a+rw du.txt'
else
    alias du1='du -h --max-depth=1 | sort -k2'
    alias du1s='date > du.txt; du -h --max-depth=1 | sort -k2 >> du.txt; chmod a+rw du.txt'
fi
alias fn='find . -iname'
alias hi='history | tail -20'
alias df='df -Ph'
#alias rsyncjay='rsync -avrh --progress --stats --inplace --whole-file --compress-level=0'
alias rsyncjay='rsync -avrh --progress --stats --inplace --whole-file'
alias rsyncvm='rsync -avrh --progress --stats --whole-file --sparse'
# rsyncsyno info: -a = -rlptgoD, rsyncsyno removes: -p (--perms), -g (--group), -o (--owner)
# synologys server side ACL's prevent setting group and owner(throws an error), and permissions are silently ignored
#alias rsyncsyno='rsync -rltD -v -r -h --progress --stats --inplace --whole-file --compress-level=0'
alias rsyncsyno='rsync -rltDvh --progress --stats --inplace --whole-file'
alias bashver='echo $BASH_VERSION'
# ssh aliases for clustered machines that the host key changes
#alias sshice="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' ice.fdn.ad"
alias sshmdc01="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' stornext@mdc01"
alias sshmdx01="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' stornext@mdx01"

# sernet samba
if [ -e '/etc/init.d/sernet-samba-smbd' ]; then
    alias sernet-stop="service sernet-samba-smbd stop;service sernet-samba-nmbd stop;service sernet-samba-winbindd stop"
    alias sernet-start="service sernet-samba-winbindd start;sleep 2;service sernet-samba-nmbd start;sleep 2;service sernet-samba-smbd start"
    alias sernet-restart="sernet-stop;sleep 2;sernet-start"
    alias sernet-status="service sernet-samba-smbd status;service sernet-samba-nmbd status;service sernet-samba-winbindd status;smbstatus"
    alias sernet-reload="service sernet-samba-winbindd reload;service sernet-samba-nmbd reload;service sernet-samba-smbd reload"
    alias sernet-wb-stop="service sernet-samba-winbindd stop"
    alias sernet-wb-start="service sernet-samba-winbindd start"
    alias sernet-wb-restart="sernet-wb-stop;sleep 2;sernet-wb-start"
fi

# macos un-quarantine alias
if [ $UNAME = "Darwin" ]; then
    alias macunblock="xattr -d com.apple.quarantine"
fi

# alias spotlight control
if [ $UNAME = "Darwin" ]; then
    alias spotlight-off="sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
    alias spotlight-on="sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
    alias spotlight-stat="sudo launchctl list | grep mds"
fi

# alias poweroff on mac
if [ $UNAME = "Darwin" ]; then
    alias poweroff='shutdown -h now'
    #alias reboot='shutdown -r now'
fi

# alias titan on
#if [[ `uname -n` = *"wiz.lan"* ]]; then
#    alias titanon='ipmipower -h 192.168.1.11 -u ADMIN -p ADMIN --on'
#fi

# make cvcp work more like cp -rvp, increase buffer
if [ -e "/usr/cvfs/bin/cvcp" ]; then
    alias cvcp='/usr/cvfs/bin/cvcp -k 16777216 -xyzd'
fi

# sudo cvadmin if not root
if [ "$USER" != root ]; then
    if [ -e "/usr/cvfs/bin/cvadmin" ]; then
        alias cvadmin='sudo /usr/cvfs/bin/cvadmin'
    fi
fi

# if on fedora alias my rpmbuild cmd
if [ -e "/etc/fedora-release" ]; then
    alias rpmbuildjay="rpmbuild -bb --with baseonly --with firmware --without degubinfo --target=`uname -m` ~/rpmbuild/SPECS/kernel.spec"
fi

# if Wowza is installed add an alias to control it's service - version 4+
if [ -e "/usr/local/WowzaStreamingEngine" ]; then
    alias wse="service WowzaStreamingEngine"
    alias wsem="service WowzaStreamingEngineManager"
fi

# dataman user alias
if [ "$USER" = dataman ]; then
    alias chmod='sudo /bin/chmod'
    alias chgrp='sudo /bin/chgrp'
    alias chown='sudo /bin/chown'
    alias ln='sudo /bin/ln'
    alias iotop='sudo /usr/sbin/iotop'
    alias iotop-c='sudo /usr/sbin/iotop-c'
    alias lsof='sudo /usr/sbin/lsof'
    if [ -e "/usr/cvfs/bin/snfsdefrag" ]; then
        alias snfsdefrag="sudo /usr/cvfs/bin/snfsdefrag"
    fi
fi

# ftp-srvr sudo alias
if [ `uname -n` = "ftp-srvr.fdn.ad" ]; then
    alias addftp='sudo /usr/local/sbin/addftp'
    alias modftp='sudo /usr/local/sbin/modftp'
    alias rmftp='sudo /usr/local/sbin/rmftp'
    alias lsftp='sudo /usr/local/sbin/lsftp'
    alias modsupport='sudo /usr/local/sbin/modsupport'
    alias ftpwho='sudo /usr/local/sbin/ftpwho'
    alias pure-ftpwho='sudo /usr/local/sbin/pure-ftpwho'
fi

# iptables alias
alias iptables-list='iptables -L -nxv --line-numbers -t raw && iptables -L -nxv --line-numbers -t mangle && iptables -L -nxv --line-numbers -t nat && iptables -L -nxv --line-numbers -t filter'

# postgres connections
alias postgwho='ps -ef | grep -i "postgres: postgres" | grep --invert-match "grep"'

# ----------------------------------------------------------------------
# ZSH COMPLETION
# ----------------------------------------------------------------------

# setup command completion
autoload -U compinit
if [ $UNAME = "Darwin" ]; then
    # -u disable insecure check, required on macOS 10.14 vm
    compinit -u
else
    compinit
fi
zmodload -i zsh/complist


# -- START -- https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
#zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  expand-or-complete-with-dots() {
    # use $COMPLETION_WAITING_DOTS either as toggle or as the sequence to show
    [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f"
    # turn off line wrapping and print prompt-expanded "dot" sequence
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  # Set the function as the default tab completion widget
  bindkey -M emacs "^I" expand-or-complete-with-dots
  bindkey -M viins "^I" expand-or-complete-with-dots
  bindkey -M vicmd "^I" expand-or-complete-with-dots
fi

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

# -- END -- https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh

# do bash style completion
unsetopt menu_complete
unsetopt auto_menu
zstyle ':completion:::*:default' menu no select
# disable from above: zstyle ':completion:*:*:*:*:*' menu select

# disable command completion reccommending sudo
zstyle ':completion::complete:*' gain-privileges 0

#cdpath=(.)

# do not provide users to ssh completion
zstyle ':completion:*:ssh:*:users' hidden true

# use /etc/hosts and known_hosts for hostname completion
[ -r /etc/ssh/ssh_known_hosts ] && _global_ssh_hosts=(${${${${(f)"$(</etc/ssh/ssh_known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_global_ssh_hosts[@]"
  "$_ssh_hosts[@]"
  "$_etc_hosts[@]"
  "$HOST"
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts


# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
if [ $UNAME = "Darwin" ] || [ $UNAME = "FreeBSD" ]; then
    export CLICOLOR=YES
    LS_COMMON="-hBsl"
else
    LS_COMMON="-hBsl --color=auto"
fi

# if the dircolors utility is available, set that up to
#dircolors="$(type -P gdircolors dircolors | head -1)"
# find dircolor or gdircolors on macOS
# use 'env which' because ksh which is broke
dircolors=$(env which dircolors 2>/dev/null)
if [ -n "$dircolors" ]; then
    dircolors=$(env which gdircolors 2>/dev/null)
fi
if [ -n "$dircolors" ]; then
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
fi
unset dircolors

# setup the main ls alias if we've established common args
if [ -n "$LS_COMMON" ]; then
    alias ls="command ls $LS_COMMON"
fi

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"

# --------------------------------------------------------------------
# PATH MANIPULATION FUNCTIONS
# --------------------------------------------------------------------

# Usage: pls [<var>]
# List path entries of PATH or environment variable <var>.
pls () { eval echo \$${1:-PATH} |tr : '\n'; }

# Usage: pshift [-n <num>] [<var>]
# Shift <num> entries off the front of PATH or environment var <var>.
# with the <var> option. Useful: pshift $(pwd)
pshift () {
    local n=1
    [ "$1" = "-n" ] && { n=$(( $2 + 1 )); shift 2; }
    eval "${1:-PATH}='$(pls |tail -n +$n |tr '\n' :)'"
}

# Usage: ppop [-n <num>] [<var>]
# Pop <num> entries off the end of PATH or environment variable <var>.
ppop () {
    local n=1 i=0
    [ "$1" = "-n" ] && { n=$2; shift 2; }
    while [ $i -lt $n ]
    do eval "${1:-PATH}='\${${1:-PATH}%:*}'"
       i=$(( i + 1 ))
    done
}

# Usage: prm <path> [<var>]
# Remove <path> from PATH or environment variable <var>.
prm () { eval "${2:-PATH}='$(pls $2 |grep -v "^$1\$" |tr '\n' :)'"; }

# Usage: punshift <path> [<var>]
# Shift <path> onto the beginning of PATH or environment variable <var>.
punshift () { eval "${2:-PATH}='$1:$(eval echo \$${2:-PATH})'"; }

# Usage: ppush <path> [<var>]
ppush () { eval "${2:-PATH}='$(eval echo \$${2:-PATH})':$1"; }

# Usage: puniq [<path>]
# Remove duplicate entries from a PATH style value while retaining
# the original order. Use PATH if no <path> is given.
#
# Example:
#   $ puniq /usr/bin:/usr/local/bin:/usr/bin
#   /usr/bin:/usr/local/bin
puniq () {
    echo "$1" |sed -e 's/^://' |sed -e 's/:^//' |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
    cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://' |sed -e 's/:^//' |sed -e 's/^://'
}

# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# source ~/.shenv now if it exists
if [ -r ~/.shenv ]; then
    . ~/.shenv
fi

# condense PATH entries
PATH=$(puniq $PATH)
export PATH
MANPATH=$(puniq $MANPATH)
#export MANPATH
LD_LIBRARY_PATH=$(puniq $LD_LIBRARY_PATH)
LD_LIBRARY_PATH=$(puniq $LD_LIBRARY_PATH)
export LD_LIBRARY_PATH

# Use the color prompt by default when interactive
if [ -n "$PS1" ]; then
    prompt full
fi

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

if [ $UNAME = "Darwin" ]; then
    mac_cpu_info () {
        # print mac CPU type
        MAC_CPU_TYPE=$(uname -m)
        MAC_CPU="Unknown"

        if [ "${MAC_CPU_TYPE}" = "i386" ]; then
            MAC_CPU="Intel"
        elif [ "${MAC_CPU_TYPE}" = "x86_64" ]; then
            MAC_CPU="Intel"
        elif [ "${MAC_CPU_TYPE}" = "arm64" ]; then
            MAC_CPU="AppleSilicon"
        fi
        
        echo "Mac CPU: ${MAC_CPU}"
        
        MAC_CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
        echo "Mac CPU Model: ${MAC_CPU_MODEL}"
        
        MAC_CPU_CORE=$(sysctl -n machdep.cpu.core_count 2>/dev/null)
        MAC_CPU_THREAD=$(sysctl -n machdep.cpu.thread_count 2>/dev/null)
        echo "Mac CPU Core/Thread: ${MAC_CPU_CORE}/${MAC_CPU_THREAD}"
    }
    
    mac_hw_info () {
        # print mac hardware and hw.model
        HW_MODEL=$(sysctl -n hw.model 2>/dev/null)
        HW_NAME="Unknown"

        # VMware
        if [[ "${HW_MODEL}" = VMware* ]]; then
            HW_NAME="VMware"
        fi

        # Macmini
        if [ "${HW_MODEL}" = "Macmini7,1" ]; then
            HW_NAME="Mac Mini (Late 2014)"
        elif [ "${HW_MODEL}" = "Macmini8,1" ]; then
            HW_NAME="Mac Mini (Late 2018)"
        elif [ "${HW_MODEL}" = "Macmini9,1" ]; then
            HW_NAME="Mac Mini (Late 2020) [M1]"
        elif [ "${HW_MODEL}" = "Mac14,12" ]; then
            HW_NAME="Mac Mini (2023) [M2 Pro]"
        elif [ "${HW_MODEL}" = "Mac14,3" ]; then
            HW_NAME="Mac Mini (2023) [M2]"
        elif [ "${HW_MODEL}" = "Mac14,12" ]; then
            HW_NAME="Mac Mini (2023) [M2 Pro]"
        elif [[ "${HW_MODEL}" = Macmini* ]]; then
            HW_NAME="Mac Mini"
        fi

        # Mac (Studio)
        if [ "${HW_MODEL}" = "Mac13,1" ]; then
            HW_NAME="Mac Studio (2022) [M1 Max]"
        elif [ "${HW_MODEL}" = "Mac13,2" ]; then
            HW_NAME="Mac Studio (2022) [M1 Ultra]"
        elif [ "${HW_MODEL}" = "Mac14,13" ]; then
            HW_NAME="Mac Studio (2023) [M2 Max]"
        elif [ "${HW_MODEL}" = "Mac14,14" ]; then
            HW_NAME="Mac Studio (2023) [M2 Ultra]"
        fi

        # MacPro
        if [ "${HW_MODEL}" = "MacPro4,1" ]; then
            HW_NAME="Mac Pro (Early 2009)"
        elif [ "${HW_MODEL}" = "MacPro5,1" ]; then
            HW_NAME="Mac Pro (Mid 2010/Mid 2012)"
        elif [ "${HW_MODEL}" = "MacPro6,1" ]; then
            HW_NAME="Mac Pro (Late 2013) [TrashCan]"
        elif [ "${HW_MODEL}" = "MacPro7,1" ]; then
            HW_NAME="Mac Pro (2019) [Lattice] [Intel]"
        elif [ "${HW_MODEL}" = "Mac14,8" ]; then
            HW_NAME="Mac Pro (2023) [Lattice] [M2 Ultra]"
        elif [[ "${HW_MODEL}" = MacPro* ]]; then
            HW_NAME="Mac Pro"
        fi

        # iMac
        if [ "${HW_MODEL}" = "iMac19,1" ]; then
            HW_NAME="iMac (Early 2019)"
        elif [ "${HW_MODEL}" = "iMac19,2" ]; then
            HW_NAME="iMac (Early 2019)"
        elif [ "${HW_MODEL}" = "iMac20,1" ]; then
            HW_NAME="iMac (Mid 2020)"
        elif [ "${HW_MODEL}" = "iMac20,2" ]; then
            HW_NAME="iMac (Mid 2020)"
        elif [ "${HW_MODEL}" = "iMac21,1" ]; then
            HW_NAME="iMac (2021) [M1]"
        elif [ "${HW_MODEL}" = "iMac21,2" ]; then
            HW_NAME="iMac (2021) [M1]"
        elif [[ "${HW_MODEL}" = iMac* ]]; then
            HW_NAME="iMac"
        fi
        
        # other hardware I just do not care about
        if [[ "${HW_MODEL}" = MacBookPro* ]]; then
            HW_NAME="MacBook Pro"
        elif [[ "${HW_MODEL}" = MacBookAir* ]]; then
            HW_NAME="MacBook Air"
        elif [[ "${HW_MODEL}" = MacBook* ]]; then
            HW_NAME="MacBook"
        fi

        echo "Mac HW : ${HW_NAME} - ${HW_MODEL}"
    }
fi

osversion () {
    # print mac version
    if [ $UNAME = "Darwin" ]; then
        # print macOS version
        MACVER_PART1=$(sw_vers -productName)
        MACVER_PART2=$(sw_vers -productVersion)
        echo $MACVER_PART1 $MACVER_PART2
    else
        # print linux os dist and version
        if [ -e "/usr/bin/lsb_release" ]; then
            lsb_release -ds | sed -e 's/"//g'
        elif [ -e "/etc/system-release" ]; then
            cat /etc/system-release
        fi
    fi
}

if [ -n "$INTERACTIVE" -a -n "$LOGIN" ]; then
    osversion
    uname -npsr
    uptime
    if [ $UNAME = "Darwin" ]; then
        mac_hw_info
        mac_cpu_info
        if [[ "${TERM_PROGRAM}" == "Apple_Terminal" || "${TERM_PROGRAM}" == "iTerm.app" ]]; then
            if [ -e "${HOME}/.force_bash" ]; then
                echo "force bash is set, launching bash shell"
                bash
            fi
        fi
    fi
    # this starts/reconnects to a single screen session
    # when you login as dataman
    if [ "$USER" = dataman ]; then
        if [ -z "$STY" ]; then
            echo ""
            echo "waiting 5 seconds before starting 'screen' session"
            echo "Press CTRL-C to keep std shell"
            sleep 5
            screen -aOUxRR
            logout
        fi
    fi
fi

# beep
alias beep='tput bel'

# if you shell is a screen session show the standard 
# login information
if [ "$TERM" = screen ]; then
    if [ -e /etc/motd ]; then
        cat /etc/motd
    fi
    osversion
    uname -npsr
    uptime
fi

# vim: ts=4 sts=4 shiftwidth=4 expandtab
