# Electronic hourglass kit page definition grammar

This folder contains lex and yacc files for electronic hourglass kit pages defintion format.

## Debian Trixie configuration

```bash
sudo mkdir /usr/lib/fpc
sudo ln -s /usr/lib/x86_64-linux-gnu/fpc/lexyacc /usr/lib/fpc/
```

## Generate parser
```bash
# Generate lexer
plex pd.l
```
