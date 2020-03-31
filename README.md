# stuff

Scripts and notes about stuff that I use often.

## Bashrc

```bash

#... at the end of the file

### Completion and Colorize

if [ "$(whoami)" != "root" ]; then
  PS1='${debian_chiroot:+($debian_chroot)}'
  PS1=$PS1'\[\033[00;36m\]$(date +"%H:%M:%S") '
  PS1=$PS1'\[\033[00;32m\]\u@\h '
  PS1=$PS1'\[\033[01;34m\]\w'
  PS1=$PS1'\[\033[00;34m\]$(__git_ps1)'
  PS1=$PS1'\[\033[00m\] \$ '
else
  PS1='${debian_chiroot:+($debian_chroot)}'
  PS1=$PS1'\[\033[00;36m\]$(date +"%H:%M:%S") '
  PS1=$PS1'\[\033[00;33m\]\u@\h '
  PS1=$PS1'\[\033[01;34m\]\w'
  PS1=$PS1'\[\033[00;34m\]$(__git_ps1)'
  PS1=$PS1'\[\033[00m\] \$ '
fi

# If this is an xterm set the window title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#
# sets the terminal title
#
function set_title {
  if (( $# < 1 )); then
    echo -e "\nUsage:\n  set_title <title>\n";
  else
    if [[ -z "$ORIG" ]]; then
      ORIG=$PS1
    fi
    TITLE="\[\e]2;$*\a\]"
    PS1=${ORIG}${TITLE}
  fi
}


/*
 * Compiles and runs a Rust script (without Cargo)
 */
function rustrun {
    name=$(echo $1 | sed 's/\.rs$//') \
    && echo "# FORMAT: rustfmt $1" \
    && rustfmt $1 \
    && echo "# COMPILE: rustc -O $1 && strip $name" \
    && rustc -O $1 && strip "$name" \
    && size=$(du -hs "$name" | sed -r 's/^([0-9]+[A-Z]).*$/\1/g') \
    && echo "binary size: $size" \
    && echo \
    && echo "# RUN: time ./${name}" \
    && echo \
    && time "./${name}"
}


### Alias

alias hat='bat --style=header'
alias ..='cd ..'
alias saysomething='fortune | cowsay -f `ls /usr/share/cowsay/cows/ | shuf -n 1`'

### PATH

export PATH=$PATH:~/coding/project/my/stuff/nodejs
export PATH=$PATH:~/coding/project/my/stuff/sh

### React Native Tools

export ANDROID_HOME=/opt/apps/android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

```

## find -exec


```bash
find . -exec grep chrome "{}" \;
# or
find . -exec grep chrome "{}" +
```

find will execute grep and will substitute {} with the filename(s) found. The difference between ; and + is that with ; a single grep command for each file is executed whereas with + as many files as possible are given as parameters to grep at once.


## Run a remote command detached from your local environment

```bash
# usage
ssh user@domain screen -d -m remote_command
```

## Working with the clipboard

xsel can copy and paste to three different "clipboards". By default, it uses the X Window System primary selection, which is basically whatever is currently in selection. The X Window System also has a secondary selection (which isn't used much), and a clipboard selection. You're probably looking for the clipboard selection, since that's what the desktop environment (e.g. Gnome, KDE, XFCE) uses for its clipboard. To use that with xsel:

```bash
xsel --clipboard < new-clipboard-contents.txt
xsel --clipboard
```

Alternativelly you can use

```bash
xclip -sel clip < new-clipboard-contents.txt
xclip -o
```

or using [CopyQ](ttps://hluk.github.io/CopyQ/)

```bash
copyq copy - < new-clipboard-contents.txt
copyq clipboard
```
