# Alienware Omarchy Controls

Omarchy/Quickshell controls for an Alienware m15 R4 running Hyprland.

The panel uses two upstream projects:

- [AWCC-Linux](https://github.com/32bitcolor/awcc-linux) for thermal profiles,
  fan monitoring, and additive fan boost.
- [alienfx-linux](https://github.com/tr1xem/alienfx-linux) for Alienware chassis
  and keyboard lighting.

## Features

- Thermal profile selection: quiet, cool, balanced, performance, and custom
- CPU/GPU temperatures and fan RPMs
- Additive CPU/GPU fan boost controls
- AlienFX blue, purple, white, and off presets
- An `AW` widget in the Omarchy bar

## Install The Custom Layer

The hardware backends must be installed separately using their upstream
instructions. After that, from this directory run:

```bash
install -Dm755 bin/omarchy-alienware ~/.local/bin/omarchy-alienware
mkdir -p ~/.config/omarchy/plugins/gebo.alienware
cp -a omarchy/plugins/gebo.alienware/. ~/.config/omarchy/plugins/gebo.alienware/
```

Install the lighting permissions with an administrative terminal:

```bash
sudo install -Dm644 udev/99-alienware-lighting.rules \
  /etc/udev/rules.d/99-alienware-lighting.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --action=add /sys/class/hidraw/hidraw0 /sys/class/hidraw/hidraw1
```

Enable the plugin by adding `gebo.alienware` to `plugins` and to a bar layout
section in `~/.config/omarchy/shell.json`. `config/shell.json` is a snapshot of
the working configuration, not a file to blindly overwrite on another system.

Reload the shell:

```bash
omarchy-shell shell rescanPlugins
omarchy restart shell
```

## AlienFX Probe

The first setup requires probing the controllers as root while keeping the
mapping file in the user's home:

```bash
HOME="$HOME" sudo -E ~/.local/bin/alienfx-cli probe --dev 0 --lights 4
HOME="$HOME" sudo -E ~/.local/bin/alienfx-cli probe --dev 1 --lights 136
sudo chown -R "$USER:$USER" ~/.local/share/alienfx
```

Do not run fan commands that directly replace the firmware safety curve unless
you understand the model-specific behavior. This panel uses AWCC-Linux's
additive boost interface and leaves the embedded controller's safety floor in
place.
