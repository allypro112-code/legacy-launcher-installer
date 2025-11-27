#!/bin/bash

log() {
    echo
    echo ">>> $1"
    echo
}

fail() {
    echo
    echo "!!! ERROR: $1"
    echo
    exit 1
}

log "Starting MCLaunch Installer (debug mode enabled)"
log "System info:"
uname -a
echo "Home directory: $HOME"
echo "PATH: $PATH"

# --------------------------
# apt update
# --------------------------
log "Running: sudo apt update"
sudo apt update || fail "apt update failed."

# --------------------------
# Install Java + X11
# --------------------------
log "Running: sudo apt install -y openjdk-17-jre x11-apps"
sudo apt install -y openjdk-17-jre x11-apps || fail "Java or X11 install failed."

# Verify Java installation
log "Checking Java version:"
java -version || fail "Java is installed but java -version failed."

# --------------------------
# Download LL.jar
# --------------------------
log "Downloading LL.jar to $HOME/LL.jar"
wget -v -O "$HOME/LL.jar" https://llaun.ch/jar || fail "Failed to download LL.jar."

log "Setting permissions on LL.jar"
chmod +x "$HOME/LL.jar" || fail "chmod failed on LL.jar."

# --------------------------
# Create launcher command
# --------------------------
log "Creating launcher directory: $HOME/.local/bin"
mkdir -pv "$HOME/.local/bin" || fail "Failed to create ~/.local/bin"

LAUNCHER_PATH="$HOME/.local/bin/mclaunch"

log "Creating launcher script at $LAUNCHER_PATH"
cat > "$LAUNCHER_PATH" <<EOL
#!/bin/bash
echo ">>> Running MCLaunch..."
java -jar "\$HOME/LL.jar"
EOL

log "Making launcher executable"
chmod +x "$LAUNCHER_PATH" || fail "Failed to chmod launcher."

# --------------------------
# Add ~/.local/bin to PATH
# --------------------------
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    log "~/.local/bin not in PATH — adding it to ~/.bashrc"

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" || fail "Failed to write to ~/.bashrc"

    log "NOTE: Restart the terminal or run 'source ~/.bashrc' for PATH update."
else
    log "~/.local/bin is already in PATH"
fi

# --------------------------
# Final message
# --------------------------
log "INSTALLATION COMPLETE!"

echo "You can now run the launcher using:"
echo
echo "    mclaunch"
echo
echo "Or manually:"
echo
echo "    java -jar \$HOME/LL.jar"
echo
echo "If something fails above, take a screenshot and send it to me."