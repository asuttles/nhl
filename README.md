# NHL

Print NHL matchups and standings in the terminal.

## Usage

Display the help message:

```bash
nhl -h
```

Display NHL standings:

```bash
nhl -s
```

Display today's matchups:

```bash
nhl -m
```

Display both standings and matchups:

```bash
nhl -s -m
```

## Installation

### Prerequisites

* [SBCL](https://www.sbcl.org/)
* [Quicklisp](https://www.quicklisp.org/)


### Clone the Repository

```bash
git clone https://github.com/asuttles/nhl.git
cd nhl
```

### Configure ASDF

Ensure that ASDF can locate the project.

Create the file:

```text
~/.config/common-lisp/source-registry.conf.d/projects.conf
```

with the following contents:

```lisp
(:tree "~/projects/")
```

Alternatively, add the project manually from the REPL:

```lisp
(push #P"/path/to/nhl/"
      asdf:*central-registry*)
```

### Load the System

Start SBCL and load the application:

```lisp
(ql:quickload :nhl)
```

Quicklisp will automatically install the required dependencies.

### Running from the REPL

Display NHL standings:

```lisp
(nhl:run '("-s"))
```

Display today's matchups:

```lisp
(nhl:run '("-m"))
```

Display both standings and matchups:

```lisp
(nhl:run '("-s" "-m"))
```

Display help:

```lisp
(nhl:run '("-h"))
```

### Command Line Options

| Option | Description                   |
| ------ | ----------------------------- |
| `-s`   | Display NHL standings         |
| `-m`   | Display today's game matchups |
| `-h`   | Display help                  |
|        |                               |

## Building and Installing

### Build a Standalone Executable

Start SBCL and load the system:

```lisp
(ql:quickload :nhl)
```

Create a standalone executable:

```lisp
(sb-ext:save-lisp-and-die
 "nhl"
 :toplevel #'nhl:main
 :executable t)
```

### Install

#### Linux / FreeBSD

Copy the executable to a directory in your `PATH`:

```bash
install -m 755 nhl ~/.local/bin/nhl
```

or, system-wide:

```bash
sudo install -m 755 nhl /usr/local/bin/nhl
```
