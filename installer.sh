#!/bin/bash

fail() {
    echo "ERROR: $1"
    exit 1
}

# --------------------------
# Variables
# --------------------------
JAVA_DIR="$HOME/.local/java"
JAVA_BIN="$JAVA_DIR/bin/java"
LAUNCHER_DIR="$HOME/.local/bin"
LAUNCHER_PATH="$LAUNCHER_DIR/mclaunch"
JAR_PATH="$HOME/LL.jar"
JAVA_VERSION="17"
DESKTOP_FILE="$HOME/.local/share/applications/mclaunch.desktop"

# --------------------------
# Create necessary directories
# --------------------------
mkdir -p "$JAVA_DIR" "$LAUNCHER_DIR" "$(dirname "$DESKTOP_FILE")" || fail "Failed to create directories."

# --------------------------
# Install Java if missing
# --------------------------
if ! command -v java &>/dev/null || ! java -version 2>&1 | grep -q "$JAVA_VERSION"; then
    echo "Java $JAVA_VERSION not found. Downloading OpenJDK..."
    
    # Example Adoptium OpenJDK 17 Linux x64
    JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/latest/download/OpenJDK17U-jre_x64_linux_hotspot.tar.gz"
    
    TMP_TAR=$(mktemp)
    wget -O "$TMP_TAR" "$JDK_URL" || fail "Failed to download Java."
    
    echo "Extracting Java..."
    tar -xzf "$TMP_TAR" -C "$JAVA_DIR" --strip-components=1 || fail "Failed to extract Java."
    rm "$TMP_TAR"
    
    echo "Java installed locally at $JAVA_DIR"
else
    JAVA_BIN=$(command -v java)
    echo "Java $JAVA_VERSION already installed at $JAVA_BIN"
fi

# --------------------------
# Download LL.jar
# --------------------------
echo "Downloading LL.jar..."
wget -O "$JAR_PATH" https://llaun.ch/jar || fail "Failed to download LL.jar."
chmod +x "$JAR_PATH"

# --------------------------
# Create launcher shortcut
# --------------------------
echo "Creating mclaunch shortcut..."
LAUNCHER_CONTENT="#!/bin/bash
\"$JAVA_BIN\" -jar \"$JAR_PATH\""

echo "$LAUNCHER_CONTENT" > "$LAUNCHER_PATH" 2>/dev/null || \
    echo "$LAUNCHER_CONTENT" | tee "$LAUNCHER_PATH" >/dev/null 2>&1 || \
    (TMPFILE=$(mktemp) && echo "$LAUNCHER_CONTENT" > "$TMPFILE" && mv "$TMPFILE" "$LAUNCHER_PATH") || fail "Failed to create launcher."

chmod +x "$LAUNCHER_PATH"

# --------------------------
# Add ~/.local/bin to PATH if missing
# --------------------------
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding $HOME/.local/bin to PATH in ~/.bashrc..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "You may need to run 'source ~/.bashrc' or restart your terminal."
fi

# --------------------------
# Create .desktop entry for Chrome OS launcher
# --------------------------
cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=MCLaunch
Comment=Launch LL.jar Minecraft Launcher
Exec=$LAUNCHER_PATH
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Game;
EOL

chmod +x "$DESKTOP_FILE"
echo "Desktop entry created! It should appear in the Chrome OS app launcher under 'Linux apps'."

# --------------------------
# Launch now
# --------------------------
echo "Setup complete! You can now run:"
echo "    mclaunch"
"$LAUNCHER_PATH"
