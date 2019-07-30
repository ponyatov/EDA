## Makefile targets

### variables

#### `CWD` current directory

#### `GZ` source code `*_GZ` packages download storage

```
GZ ?= $(HOME)/gz
```

#### `TMP` out-of-tree build

```
TMP ?= $(CWD)/tmp
```

#### `SRC` source code unpack & in-tree build

```
SRC ?= $(TMP)/src
```

#### `WGET` download client

```
WGET = wget -c -P $(GZ)
```

### `doc` 
### `dirs` 
### `gz`
### `install`
