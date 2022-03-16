# Backup Personal files


## Execution :

```
./backup.sh -h
Usage: backup.sh [-h] [-V] [-D] -e

Backup personal files.
Use reference file : /path/to/script/ressources_to_backup (1 file by line)

Available options:

  -h      Print this help and exit
  -V      Print version
  -D      Enable debug
  -e      Execute backup
```





### Notes :
By default the color is enabled.
You can disable this by setting this variable before running the script :
export NO_COLOR=1
./my_template.sh ....

Reset to default : unset NO_COLOR
./my_template.sh ....



