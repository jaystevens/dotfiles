#!/bin/bash
# A basically sane bash environment.
#
# Ryan Tomayko <http://tomayko.com/about> (with help from the internets).

# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

# readline config
: ${INPUTRC=~/.inputrc}

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
if [ -r /etc/bashrc ]; then
    . /etc/bashrc
fi

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell                 >/dev/null 2>&1
shopt -s extglob                 >/dev/null 2>&1
shopt -s histappend              >/dev/null 2>&1
shopt -s hostcomplete            >/dev/null 2>&1
shopt -s interactive_comments    >/dev/null 2>&1
shopt -u mailwarn                >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

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

# QT 4.8.6
if [ -d "/usr/local/Trolltech/Qt-4.8.6/bin" ]; then
    PATH="/usr/local/Trolltech/Qt-4.8.6/bin:$PATH"
fi
if [ -d "/usr/local/Trolltech/Qt-4.8.6/lib" ]; then
    LD_LIBRARY_PATH="/usr/local/Trolltech/Qt-4.8.6/lib:$LD_LIBRARY_PATH"
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
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

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

function load_out() {
if [ $UNAME = "Darwin" ]; then
    echo -n "$(uptime | sed -e "s/.*load averages: \(.*\...\) \(.*\...\) \(.*\...\).*/\1/" -e "s/ //g")"
elif [ $UNAME = "FreeBSD" ]; then
    echo -n "$(uptime | sed -e "s/.*load averages: \(.*\...\), \(.*\...\), \(.*\...\).*/\1/" -e "s/ //g")"
else
    echo -n "$(uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\).*/\1/" -e "s/ //g")"
fi
}

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
elif hostname | grep -q '\.github\.'; then
    GITHUB=true
    COLOR1="\[\e[0;94m\]"
    COLOR2="\[\e[0;92m\]"
    P="\$"
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREY}[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
}

prompt_full() {
    PS1="${GREY}[\$(load_out)][\A][${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[[33;1m\] \[[0m[1m\]> "
}

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
alias rsyncjay='rsync -avrh --progress --stats --inplace --whole-file --compress-level=0'
alias rsyncvm='rsync -avrh --progress --stats --whole-file --sparse'
alias rsyncsyno='rsync -rltD -v -r -h --progress --stats --inplace --whole-file --compress-level=0'
alias wizmnt='sshfs -o Cipher="aes128-ctr" root@wizardofthenet.com:/home/ghosttoast/www/www/'
alias uwizmnt='fusermount -u'
alias bashver='echo $BASH_VERSION'
alias sshice="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' ice.fdn.ad"
alias sshmdc01="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' stornext@mdc01.fdn.ad"
alias sshmdc02="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' stornext@mdc02.fdn.ad"

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
alias postgwho='ps -ef | grep -i "postgres: postgres"'

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

if [ -z "$BASH_COMPLETION" ]; then
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    if [ -n "$PS1" -a "$bmajor" -gt 1 ]; then
        # search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /usr/pkg/etc/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion
        do
            if [ -f $f ]; then
                . $f
                break
            fi
        done
    fi
    unset bash bmajor bminor
fi

# override and disable tilde expansion
#_expand() {
#    return 0
#}

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
dircolors="$(type -P gdircolors dircolors | head -1)"
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
    prompt_full
fi

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

osversion () {
    # print mac version
    if [ $UNAME = "Darwin" ]; then
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
