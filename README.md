# Clear Cached Memory Script


This Bash script clears the cached memory on (Ubuntu/Debian) Linux systems, freeing up RAM by clearing the file system buffers and caches.

Usage
To use the script, simply run it with root privileges:

bash
Copy code
sudo ./clear-cached-memory.sh
The script will output information about your current memory usage and the amount of memory that will be freed up by clearing the caches.

Dependencies
This script requires the bc tool to be installed. If you don't have it already, you can install it using the following command:

bash
Copy code
sudo apt install bc
Authors
This script was created by mrprohack and tamilanmkv.

License
This script is released under the MIT License. Feel free to use, modify, and distribute it as you like.