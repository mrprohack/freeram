# freeram

`freeram` is a small Bash utility for inspecting Linux memory cache usage and, when explicitly requested as root, asking the kernel to drop page caches through `/proc/sys/vm/drop_caches`.

> [!IMPORTANT]
> Linux normally uses otherwise-idle RAM for filesystem cache and releases it automatically when applications need memory. Clearing caches routinely can reduce performance because useful cached data must be read again. Use `freeram` for troubleshooting, controlled testing, or specific operational needs—not as a general RAM-optimization tool.

## What changed in v2.1

- Clear errors for unknown options and invalid usage.
- `--test` and `--stats` no longer require root.
- Explicit validation for `/proc/meminfo` and `/proc/sys/vm/drop_caches`.
- `sync` runs before cache dropping.
- Failed cache writes stop immediately instead of producing success-looking history/log entries.
- Logging/history failures are reported as warnings.
- Negative memory deltas are never recorded as negative "freed" values.
- Installer/uninstaller now validate privileges, support non-interactive operation, and install/remove the man page.
- Expanded regression tests plus GitHub Actions CI.

## Requirements

- Linux with procfs mounted (`/proc/meminfo` and `/proc/sys/vm/drop_caches`).
- Bash 4.0+.
- Standard userland tools: `awk`, `sync`, `date`, `mkdir`, `dirname`, and `tail` for history display.
- Root privileges only for an actual cache-cleaning run, installation, or uninstallation.

No Python, Node.js, `bc`, or distribution-specific package manager is used by the runtime script.

## Installation

```bash
git clone https://github.com/mrprohack/freeram.git
cd freeram
sudo ./install.sh
```

For unattended reinstall/installation:

```bash
sudo ./install.sh --yes
```

The installer places:

- `/usr/local/bin/freeram`
- `/usr/local/share/man/man1/freeram.1`
- `/var/log/freeram.log`
- `/var/lib/freeram/`

## Usage

Read-only commands do **not** need sudo:

```bash
freeram --test       # Dry run; show what would be done
freeram --stats      # Current memory statistics + recorded history
freeram --help
freeram --version
```

Actual cache clearing requires root:

```bash
sudo freeram                 # Interactive confirmation
sudo freeram --yes           # Non-interactive
sudo freeram --yes --silent  # Automation: no normal output
```

`--silent` requires `--yes` during a cleaning run so a background process cannot block on a hidden confirmation prompt.

## Options

| Option | Description |
| --- | --- |
| `-y`, `--yes` | Skip confirmation before clearing caches |
| `-s`, `--silent` | Suppress normal output; errors/warnings still go to stderr |
| `-t`, `--test` | Dry run without changing kernel caches |
| `--stats` | Show current memory information and recent freeram history |
| `-h`, `--help` | Show usage help |
| `-v`, `--version` | Show version |

Unknown options and unexpected positional arguments are rejected instead of being silently ignored.

## What freeram does

For a real cleaning run, freeram:

1. Reads `MemFree`, `Cached`, `SReclaimable`, and `Shmem` from `/proc/meminfo`.
2. Confirms the request unless `--yes` is supplied.
3. Verifies root privileges and that `/proc/sys/vm/drop_caches` is writable.
4. Runs `sync` so pending filesystem writes are flushed.
5. Writes `3` to `/proc/sys/vm/drop_caches`.
6. Reads memory statistics again.
7. Records the observed `MemFree` change in history and the activity log.

The reported value is an observation around the cache-drop operation, not a guarantee that the same amount of RAM remains available later; memory usage can change concurrently.

## Files

| Path | Purpose |
| --- | --- |
| `/usr/local/bin/freeram` | Installed command |
| `/usr/local/share/man/man1/freeram.1` | Manual page |
| `/var/log/freeram.log` | Activity log |
| `/var/lib/freeram/history` | Timestamped before/after history |

If history or activity logging fails after caches were successfully dropped, freeram prints a warning to stderr rather than pretending the log succeeded.

## Exit status

- `0` — command completed successfully or the user cancelled an interactive run.
- `1` — runtime/environment error, missing requirement, permission failure, unreadable memory data, or cache-drop failure.
- `2` — command-line/usage error, including unknown options or unsafe non-interactive confirmation state.

## Automation

Cache cleaning must run as root. For cron, edit the **root** crontab:

```bash
sudo crontab -e
```

Example:

```cron
# Daily at 02:00
0 2 * * * /usr/local/bin/freeram --yes --silent
```

A systemd service/timer example is available in `examples/`:

```bash
sudo cp examples/freeram.service /etc/systemd/system/
sudo cp examples/freeram.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now freeram.timer
```

Before scheduling recurring cache drops, confirm that doing so solves a measured problem on your workload.

## Testing

Run the regression suite:

```bash
./test.sh
```

The tests use temporary memory/cache-control paths and an isolated installation root, so they do not drop the host's real caches or install files into `/usr`/`/var`.

Pull requests also run the suite through GitHub Actions.

## Uninstall

Remove the program and man page while keeping logs/history:

```bash
sudo ./uninstall.sh
```

Non-interactive removal:

```bash
sudo ./uninstall.sh --yes
```

Remove the program **and** freeram log/history data:

```bash
sudo ./uninstall.sh --yes --purge
```

## Troubleshooting

**`Cache cleaning requires root privileges`**  
Use `sudo freeram ...` only for a real cleaning run. `freeram --test` and `freeram --stats` should work without sudo.

**`Cache control file is not writable`**  
Confirm you are running as root and that procfs exposes `/proc/sys/vm/drop_caches`. Containers or restricted environments may intentionally block this operation.

**`Cannot read memory information`**  
Confirm `/proc/meminfo` exists and procfs is mounted correctly.

## License

MIT
