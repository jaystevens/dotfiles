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
#complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh scp sftp
#complete -W "$(echo `cat /etc/ssh/ssh_known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh scp sftp

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
      . /etc/bashrc

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell >/dev/null 2>&1
shopt -s extglob >/dev/null 2>&1
shopt -s histappend >/dev/null 2>&1
shopt -s hostcomplete >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
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
test -d "$HOME/bin" &&
    PATH="$HOME/bin:$PATH"

# put StorNext in path if you have it
test -d "/usr/cvfs/bin" &&
    PATH="/usr/cvfs/bin:$PATH"

# put mti tools in path if you have it
test -d "/usr/mti/bin" &&
    PATH="/usr/mti/bin:$PATH"

# put signiant dds in path if you have it
test -d "/usr/signiant/dds/bin" &&
    PATH="/usr/signiant/dds/bin:$PATH"

# put anyconnect in path if you have it
test -d "/opt/cisco/anyconnect/bin" &&
    PATH="/opt/cisco/anyconnect/bin:$PATH"

if [ "$USER" = dataman ]; then
    # put Atempo in path if you have it
    test -e "/usr/Atempo/tina/.tina.sh" &&
        source /usr/Atempo/tina/.tina.sh
fi

# linux gcc - add new to top
# put gcc-4.8.1 in lib path if you have it
test -d "/usr/local/gcc-4.8.1/lib64" &&
    LD_LIBRARY_PATH="/usr/local/gcc-4.8.1/lib64:$LD_LIBRARY_PATH"
# put gcc-4.8.0 in lib path if you have it
test -d "/usr/local/gcc-4.8.0/lib64" &&
    LD_LIBRARY_PATH="/usr/local/gcc-4.8.0/lib64:$LD_LIBRARY_PATH"
# put gcc-4.7.3 in lib path if you have it
test -d "/usr/local/gcc-4.7.3/lib64" &&
    LD_LIBRARY_PATH="/usr/local/gcc-4.7.3/lib64:$LD_LIBRARY_PATH"
# put gcc-4.7.2 in lib path if you have it
test -d "/usr/local/gcc-4.7.2/lib64" &&
    LD_LIBRARY_PATH="/usr/local/gcc-4.7.2/lib64:$LD_LIBRARY_PATH"
# put gcc-4.7.1 in lib path if you have it
test -d "/usr/local/gcc-4.7.1/lib64" &&
    LD_LIBRARY_PATH="/usr/local/gcc-4.7.1/lib64:$LD_LIBRARY_PATH"


# on redhat some things compile into lib, some into lib64
if [ -e "/etc/redhat-release" ]; then
    : ${MACHINE=$(uname -m)}
    if [ "$MACHINE" = x86_64 ]; then
        test -d "/usr/local/lib64" &&
            LD_LIBRARY_PATH="/usr/local/lib64:$LD_LIBRARY_PATH"
    fi
fi

# intel compiler
if [ -e "/opt/intel/bin/compilervars.sh" ]; then
    : ${MACHINE=$(uname -m)}
    if [ "$MACHINE" = x86_64 ]; then
        source /opt/intel/bin/compilervars.sh intel64
    else
        source /opt/intel/bin/compilervars.sh ia32
    fi
    alias unseticc='unset CC;unset CXX;unset F77;unset CFLAGS;unset CXXFLAGS;unset FFLAGS'
    alias unsetcf='unset CFLAGS;unset CXXFLAGS;unset FFLAGS'
    alias seticc='export CC="icc";export CXX="icpc";export F77="ifort";export AR="xiar";export LD="xild"'
    alias setauto='export CFLAGS="-axSSSE3,SSE4.1,SSE4.2,AVX,CORE-AVX2,CORE-AVX-I";export CXXFLAGS="$CFLAGS";export FFLAGS="$CFLAGS"'
    alias setatom='export CFLAGS="-xSSSE3_ATOM";export CXXFLAGS="$CFLAGS";export FFLAGS="$CFLAGS"'
    alias setsse41='export CFLAGS="-xSSE4.1";export CXXFLAGS="$CFLAGS";export FFLAGS="$CFLAGS"'
    alias setavx='export CFLAGS="-xAVX";export CXXFLAGS="$CFLAGS";export FFLAGS="$CFLAGS"'
    alias setflags='export CXXFLAGS="$CFLAGS";export FFLAGS="$CFLAGS"'
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
HISTFILESIZE=10000
HISTSIZE=10000

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)

# EDITOR
test -n "$HAVE_VIM" &&
EDITOR=vim ||
EDITOR=vi
export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# Ack
ACK_PAGER="$PAGER"
ACK_PAGER_COLOR="$PAGER"

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

function load_out() {
if [ `uname -s` = "Darwin" ]; then
    #echo -n "$(uptime | sed -e "s/.*load averages: \(.*\...\) \(.*\...\) \(.*\...\).*/\1/" -e "s/ //g")"
    echo -n "-1"
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
elif hostname | grep -q 'github\.com'; then
    GITHUB=yep
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
    #PS1="${GREY}[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS1="${GREY}[\$(load_out)][\A][${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[[33;1m\]continue \[[0m[1m\]> "
}

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ `uname -s` = "Darwin" ]; then
    # put ports on the paths if /opt/local exists
    test -x /opt/local -a ! -L /opt/local && {
        PORTS=/opt/local

        # setup the PATH and MANPATH
        PATH="$PORTS/bin:$PORTS/sbin:$PATH"
        MANPATH="$PORTS/share/man:$MANPATH"

        # make sure /usr/local is infront of /opt/local
        test -d "/usr/local/bin" &&
            PATH="/usr/local/bin:$PATH"
        test -d "/usr/local/sbin" &&
            PATH="/usr/local/sbin:$PATH"

        # nice little port alias
        alias port="sudo nice -n +18 $PORTS/bin/port"
    }

    test -x /usr/pkg -a ! -L /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }

    # setup java environment. puke.
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"

    # hold jruby's hand
    test -d /opt/jruby &&
        export JRUBY_HOME="/opt/jruby"
fi

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
if [ `uname -s` = "Darwin" ]; then
    alias du1='du -h -d 1'
    alias du1s='date > du.txt; du -h -d 1 >> du.txt; chmod a+rw du.txt'
else
    alias du1='du -h --max-depth=1'
    alias du1s='date > du.txt; du -h --max-depth=1 >> du.txt; chmod a+rw du.txt'
fi
alias fn='find . -name'
alias hi='history | tail -20'
alias df='df -Ph'
alias rsyncmti='rsync -avrh --progress --stats --inplace --whole-file --compress-level=0'
alias udrmti='udr -c /usr/local/bin/udr rsync -avrh --progress --stats --inplace --whole-file --compress-level=0'
alias wizmnt='sshfs -o Cipher="arcfour" root@wizardofthenet.com:/home/ghosttoast/www/www/'
alias uwizmnt='fusermount -u'
alias lfmnt='sshfs -o Cipher="arcfour" jay.stevens@landfill.mti.ad:/data/landfill/'
alias bashver='echo $BASH_VERSION'
alias sshice="ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' ice.mti.ad"

# alias titan on
if [ `uname -n` = "ares.lan" ]; then
    alias titanon='ipmipower -h 192.168.1.4 -u ADMIN -p ADMIN --on'
fi

# make cvcp work more like cp -rvp, increase buffer
test -e "/usr/cvfs/bin/cvcp" && 
    alias cvcp='/usr/cvfs/bin/cvcp -k 16777216 -xyzd'

# sudo cvadmin if not root
if [ "$USER" != root ]; then
    test -e "/usr/cvfs/bin/cvadmin" &&
        alias cvadmin='sudo /usr/cvfs/bin/cvadmin'
fi

# if on fedora alias my rpmbuild cmd
test -e "/etc/fedora-release" &&
    alias rpmbuildjay="rpmbuild -bb --with baseonly --with firmware --without degubinfo --target=`uname -m` ~/rpmbuild/SPECS/kernel.spec"

# if Wowza is installed add an alias to control it's service
# version 3
test -e "/usr/local/WowzaMediaServer" &&
    alias wms="service WowzaMediaServer"
# version 4
test -e "/usr/local/WowzaStreamingEngine" &&
    alias wse="service WowzaStreamingEngine"
test -e "/usr/local/WowzaStreamingEngine" &&
    alias wsem="service WowzaStreamingEngineManager"

# dataman user alias
if [ "$USER" = dataman ]; then
    alias chmod='sudo /bin/chmod'
    alias chgrp='sudo /bin/chgrp'
    alias chown='sudo /bin/chown'
    alias ln='sudo /bin/ln'
fi

# ftp-srvr sudo alias
if [ `uname -n` = "ftp-srvr.mti.ad" ]; then
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

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

test -z "$BASH_COMPLETION" && {
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    test -n "$PS1" && test $bmajor -gt 1 && {
        # search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /usr/pkg/etc/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion
        do
            test -f $f && {
                . $f
                break
            }
        done
    }
    unset bash bmajor bminor
}

# override and disable tilde expansion
#_expand() {
#    return 0
#}

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
if [ `uname -s` = "Darwin" ]; then
    LS_COMMON="-hBsl"
else
    LS_COMMON="-hBsl --color=auto"
fi

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"

# --------------------------------------------------------------------
# MISC COMMANDS
# --------------------------------------------------------------------

# fix git ssh askpass on cmdline
unset SSH_ASKPASS

# push SSH public key to another box
push_ssh_cert() {
    local _host
    test -f ~/.ssh/id_dsa.pub || ssh-keygen -t dsa
    for _host in "$@";
    do
        echo $_host
        ssh $_host 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_dsa.pub
    done
}

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

# use gem-man(1) if available:
man () {
    gem man -s "$@" 2>/dev/null ||
    command man "$@"
}

# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# bring in rbdev functions
. rbdev 2>/dev/null || true

# source ~/.shenv now if it exists
test -r ~/.shenv &&
. ~/.shenv

# condense PATH entries
PATH=$(puniq $PATH)
export PATH
MANPATH=$(puniq $MANPATH)
#export MANPATH
LD_LIBRARY_PATH=$(puniq $LD_LIBRARY_PATH)
LD_LIBRARY_PATH=$(puniq $LD_LIBRARY_PATH)
export LD_LIBRARY_PATH

# Use the color prompt by default when interactive
test -n "$PS1" &&
prompt_color

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}

# vim: ts=4 sts=4 shiftwidth=4 expandtab
