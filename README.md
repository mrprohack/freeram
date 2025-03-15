# Enhanced Clear Cached Memory Script

This Bash script efficiently clears the cached memory on (Ubuntu/Debian) Linux systems, freeing up RAM by clearing the file system buffers and caches, and includes additional features for improved usability and logging.

## Key Features
- Clears cached memory to free up RAM, enhancing system performance.
- Logs the amount of memory freed to `/var/log/freeram.log` for auditing and monitoring purposes.
- Presents a confirmation prompt before executing the cache clearing operation to prevent accidental runs.
- Automatically checks for and installs the required `bc` tool if it's not already installed.
- Optionally downloads and installs the script directly to the system with appropriate permissions.

## Usage
To utilize the script, run it with root privileges:

```sh
sudo ./freeram
```

The script will display detailed information about your current memory usage and the amount of memory that will be freed up by clearing the caches. A confirmation prompt will appear before proceeding with the operation.

## Dependencies
The script requires the `bc` tool. If not installed, it can be added using:

```sh
sudo apt install bc
```

For direct download and installation of the script, use:

```sh
sudo wget https://raw.githubusercontent.com/mrprohack/freeram/main/freeram -O /usr/bin/freeram && sudo chmod +x /usr/bin/freeram
```

## Log File
All script operations are logged to `/var/log/freeram.log`, providing a record of when the script was run and how much memory was freed.

## Authors and Contributions
This script was initially created by [mrprohack](https://github.com/mrprohack) and [tamilanmkv](https://github.com/tamilanmkv), with subsequent enhancements and contributions from the open-source community.

## License
Released under the MIT License, this script is free to use, modify, and distribute as desired.
