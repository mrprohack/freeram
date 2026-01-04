# freeram - Fast RAM Cache Cleaner

Fast, simple, zero-dependency script to clear cached memory on Linux systems.

## Features

- **Zero dependencies** - Pure bash, no external tools required
- **Cross-distribution** - Works on Ubuntu, Debian, Fedora, Arch, and more
- **Multiple modes** - Interactive, silent, test, and statistics modes
- **History tracking** - Tracks memory freed over time
- **Professional** - Install/uninstall scripts, man page, examples

## Installation

```bash
# Clone or download
git clone https://github.com/yourusername/freeram.git
cd freeram

# Install system-wide
sudo ./install.sh
```

## Usage

```bash
sudo freeram              # Interactive mode
sudo freeram -y           # Auto-confirm
sudo freeram -s           # Silent mode
sudo freeram -t           # Test mode (dry run)
sudo freeram --stats      # Show statistics
sudo freeram -h           # Show help
```

## Options

| Option | Description |
|--------|-------------|
| `-y, --yes` | Skip confirmation |
| `-s, --silent` | Silent mode |
| `-t, --test` | Test mode (dry run) |
| `--stats` | Show statistics & history |
| `-h, --help` | Show help |
| `-v, --version` | Show version |

## Files

| File | Description |
|------|-------------|
| `/usr/local/bin/freeram` | Main script |
| `/var/log/freeram.log` | Activity log |
| `/var/lib/freeram/history` | Memory freed history |

## Automation

### Cron (add to crontab -e)
```bash
# Run daily at 2 AM
0 2 * * * /usr/local/bin/freeram -y -s
```

### Systemd Timer
```bash
sudo cp examples/freeram.service /etc/systemd/system/
sudo cp examples/freeram.timer /etc/systemd/system/
sudo systemctl enable --now freeram.timer
```

## Testing

```bash
./test.sh
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Requirements

- Linux with `/proc/meminfo`
- Root privileges (sudo)
- Bash 4.0+

## License

MIT
