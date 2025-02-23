# Clear Cached Memory Script

This Bash script clears the cached memory on (Ubuntu/Debian) Linux systems, freeing up RAM by clearing the file system buffers and caches.

## Features
- Clears cached memory to free up RAM.
- Logs the amount of memory freed to `/var/log/freeram.log`.
- Confirmation prompt before executing the cache clearing operation.

## Usage
To use the script, simply run it with root privileges:

```sh
sudo ./freeram
```

The script will output information about your current memory usage and the amount of memory that will be freed up by clearing the caches. You will be prompted to confirm the operation before proceeding.

## Dependencies
This script requires the `bc` tool to be installed. If you don't have it already, you can install it using the following command:

```sh
sudo apt install bc
```

You can also download the script directly to your system with:

```sh
wget https://raw.githubusercontent.com/mrprohack/freeram/main/freeram -O /usr/bin/freeram && chmod +x /usr/bin/freeram 
```

## Log File
The script logs its operations to `/var/log/freeram.log`. You can check this file to see when the script was run and how much memory was freed.

## Authors
This script was created by [mrprohack](https://github.com/mrprohack) and [tamilanmkv](https://github.com/tamilanmkv).

## License
This script is released under the MIT License. Feel free to use, modify, and distribute it as you like.
