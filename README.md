# arma3.sh

A shell script to launch Arma 3 on macOS with all your Steam Workshop mods enabled.

## Requirements

- macOS
- Arma 3 installed via Steam (default library location)

## How it works

When launched through Steam on macOS, Arma 3 doesn't pick up Workshop mods the way it does on Windows. This script bridges that gap: it scans your Steam Workshop content folder for all subscribed mods, creates `@ModName` symlinks inside the Arma 3 game directory, then launches the game with the correct `-mod=` parameter built automatically.

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/mdobak/arma3-macos/main/arma3.sh -o arma3.sh
chmod +x arma3.sh
./arma3.sh
```

Any additional arguments are passed straight to the binary:

```bash
./arma3.sh -nosplash -skipIntro
```