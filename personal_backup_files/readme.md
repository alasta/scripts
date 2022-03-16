# Backup Personal files



## Before execution :
### Set good path :  
Set good path of binary within script begin (MacOS vs Linux).  
Example to :  
#BIN_BASENAME="/usr/bin/basename" #MacOS  
BIN_BASENAME="/bin/basename" #Linux  

### Set parameter :
EXCLUDE_TAR : list of exclude extension, default : "--exclude=*.rpm --exclude=*.log"      
REMOTE_FOLDER_BCK : path of target backup, default : "/tmp/"  
  
Fill the backup file list : /path/of/script/ressources_to_backup (1 by line)    


## Execution :

### Informations :
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

### Execution :
```
./backup.sh -e
Generate files list to backup :
OK
Generate backup :  
/bin/tar: Suppression de « / » au début des noms des membres
OK
```


### Notes :
By default the color is enabled.
You can disable this by setting this variable before running the script :
export NO_COLOR=1
./my_template.sh ....

Reset to default : unset NO_COLOR
./my_template.sh ....



