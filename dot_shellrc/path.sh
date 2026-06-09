# Add user-local executables to PATH
path_prepend "$HOME/.local/bin"

# Add rust toolchain
path_prepend "$HOME/.cargo/bin"

export PATH
