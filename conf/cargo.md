# Cargo

The Rust package manager.

## Installed executables

### amp

Cli text editor.

```
cargo install amp
```

### btm

Cli system monitor.

```
cargo install bottom
```

### procs

A modern replacement for ps.

```
cargo install procs
```

### dust

Dust is meant to give you an instant overview of which directories are using disk space without requiring sort or head.

```
cargo install du-dust
```

### fd

Finds entries in your filesystem.

```
cargo install fd-find
```

### gitui

GitUI provides you with the comfort of a git GUI but right in your terminal.

```
cargo install gitui
```

### loc

loc is a tool for counting lines of code.

```
cargo install loc
```

### mdbook

mdBook is a utility to create modern online books from Markdown files.

```
cargo install mdbook
```

### miniserve

miniserve is a small, self-contained cross-platform CLI tool that allows you to just grab the binary and serve some file(s) via HTTP.

```
cargo install miniserve
```

### redis-query

Searches keys in multiple Redis' databases.

```
cargo install redis-query
```

### rg

ripgrep (rg) ripgrep is a line-oriented search tool that recursively searches the current directory for a regex pattern.

```
cargo install ripgrep
```

### sd

sd is an intuitive find & replace CLI.

```
cargo install sd
```

### so_stupid_search

Search text in files

```
cargo install so_stupid_search
```

### viu

Terminal image viewer.

```
cargo install viu
```

### xcp

An extended cp.

```
cargo install xcp
```

### xor

Command line application that implements basic XOR encryption, written in Rust.

```
cargo install xor
```

### xsv

A fast and flexible CSV reader and writer for Rust, with support for Serde.

```
cargo install xsv
```

### dum

An npm scripts runner written in Rust.

```
cargo install dum
```


## Automation

Supposing that this file is located in the work directory and it is named `cargo.md`:

```sh
# Check the difference between what is locally installed and what is described in this file
diff <(cat cargo.md | rg '^### ' | awk '{print $2}' | sort) <(ls ~/.cargo/bin) | rg '<|>' | sd '>' '+' | sd '<' '-'

# Install/update all the executable
for crate in $(rg '^cargo install' cargo.md | sd 'cargo install' ''); do echo -e "\nInstalling/updating create ${crate}..."; cargo install $crate; done

# list executables with description
echo $(rg -A 2 '^###' cargo.md) | sd '\-\- ' '\n' | sd '### ([-\w]+)' '$1:'
```
