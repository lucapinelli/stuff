# stuff

Scripts and notes about stuff that I use often.

## In progress

### Compile and run a Rust script (without Cargo)

```bash
function rust_run {
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
```

### find -exec


```bash
find . -exec grep chrome "{}" \;
# or
find . -exec grep chrome "{}" +
```

find will execute grep and will substitute {} with the filename(s) found. The difference between ; and + is that with ; a single grep command for each file is executed whereas with + as many files as possible are given as parameters to grep at once.


### Run a remote command detached from your local environment

```bash
# usage
ssh user@domain screen -d -m remote_command
```

### Working with the clipboard

xsel can copy and paste to three different "clipboards". By default, it uses the X Window System primary selection, which is basically whatever is currently in selection. The X Window System also has a secondary selection (which isn't used much), and a clipboard selection. You're probably looking for the clipboard selection, since that's what the desktop environment (e.g. Gnome, KDE, XFCE) uses for its clipboard. To use that with xsel:

```bash
xsel --clipboard < new-clipboard-contents.txt
xsel --clipboard
```

Alternatively you can use

```bash
xclip -sel clip < new-clipboard-contents.txt
xclip -o
```

or using [CopyQ](ttps://hluk.github.io/CopyQ/)

```bash
copyq copy - < new-clipboard-contents.txt
copyq clipboard
```
