# Example Project showing how to Create a Python Package with a pybind11 backend

This example project uses pybind11 as a submodule added to `external/pybind11`.

## Project Structure

* `src`: contains the project's Python and C++ code
* `src/backend`: contains the project's C++ code and is target for the `cpython.so` which is created during the build process
* `external`: contains the project's submodules such as `pybind11`. Submodules can be downloaded using `git submodule update --init --recursive`
* `test`: contains the project's tests
* `test/py`: contains the Python unit tests
* `test/cc`: contains the C++ tests to test the C++ code without the Python interface
* `CMakeLists.txt`: contains all build instructions for the C++ code and the `pybind11` wrapper
* `setup.py`: contains the instructions on how to put everything into a Python package including C++ compiliation

## Install

### Prerequisits

Python version `>=3.10` (lower is possible if you avoid the `match` operator)

```
sudo apt install build-essential cmake ninja-build
```

macOS:
```
xcode-select --install
brew install cmake ninja-build
```

### Install Locally

```
git clone https://github.com/k0nze/pybind_example ${PYBIND_EXAMPLE_PATH}
cd ${INSTALL_DIR_PATH}
python -m venv .venv
source .venv/bin/activate
python -m pip install [-e] ${PYBIND_EXAMPLE_PATH}
```

### Install from github

```
cd ${INSTALL_DIR_PATH}
python -m venv .venv
source .venv/bin/activate
python -m pip install git+https://github.com/k0nze/pybind_example.git
```

### Incremental Build and Debugging

When using `pip` to install this project no build artifacts are cached which leads to rebuilding all C++ files. To work with incremental builds the project has to be installed as editable once:

```
python -m venv .venv
source .venv/bin/activate
python -m pip install [-e] ${PYBIND_EXAMPLE_PATH}\[dev\]
```

create a build directory and run `cmake`:
```
mkdir build
cmake ${PYBIND_EXAMPLE_PATH} -DPYTHON_EXECUTABLE=../.venv/bin/python -DPYBIND11_PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')") -DMOVE_LIB=ON -DMOVE_CPYTHON_SO=ON -DCMAKE_BUILD_TYPE=Debug -GNinja ..
ninja
```

#### Debugging C++ through Python

Launch `ipython` and `lldb` in two separate terminals. In the terminal running `ipython` enter:
```
!ps aux | grep -i ipython
```
copy the `pid` of the `ipython` process.

In the `lldb` terminal enter the following to attach to the `ipython` process and continue
```
attach --pid PID
continue
```

Set a breakpoint in the `lldb` terminal to a line in the ACADL backend:
```
breakpoint set -n Cat::purr
```

Run Python code from the `ipython` terminal:
```
run examples/example.py
```

## `clangd` Configuration

To get `pybind11` and Python includes for the `clangd` language server create a `.clangd` file at the project root with the following content:

```
CompileFlags:
  Add:
    - "-I[PATH_TO_PYTHON_INCLUDES]"
    - "-I../external/pybind11/include"
```

The path the the Python can be obtained with the following command:

```
echo $(python-config --includes)
```

## `pybind11` Stubs for Code Completion

When editing this project you can generate `pybind11` stubs for code completion.

```
cd ${PYBIND_EXAMPLE_PATH}
python -m venv .venv
source .venv/bin/activate
python -m pip install -e .
python -m pip install pybind11-stubgen
pybind11-stubgen --ignore-invalid signature -o stubs pybind_example
```
