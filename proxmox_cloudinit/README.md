# Script to generate Cloudinit template on Proxmox

## Description
This script is equal to :

```
wget https://download.rockylinux.org/pub/rocky/8.5/images/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2
qm create 1002 --name "rockylinux8v2-cloudinit-template" --memory 1024 --net0 virtio,bridge=vmbr0
qm importdisk 1002 Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2 local-lvm
qm set 1002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1002-disk-0
qm set 1002 --ide2 local-lvm:cloudinit
qm set 1002 --boot c --bootdisk scsi0
qm set 1002 --serial0 socket --vga serial0
qm set 1002 --cores 1
qm set 1002 --memory 1024
qm set 1002 --cicustom "user=local:snippets/user-data-redhat-like.yaml"
qm template 1002
```

**Note :**  
Command to clone a new VM  
```qm clone 1002 305 --name rockylinux8test6  ```
  
This Cloudinit image not allow an user with ssh password, it 's just to Proxmox console.  



## User Data to custom Cloudinit :
Put the **user-data-redhat-like.yaml** file to **/var/lib/vz/snippets/**.  
Password of Alasta user is : yourpass

Generate the password :
openssl passwd -6 -salt xyz  yourpass

## Bonus :
Cloud images :  
- <a href="https://cloud-images.ubuntu.com/" target=_blank>Ubuntu</a>
- <a href="https://cloud.debian.org/images/cloud/" target=_blank>Debian</a>
- <a href="https://cloud.centos.org/centos/" target=_blank>Centos</a>
- <a href="https://docs.openstack.org/image-guide/obtain-images.html" target=_blank>Others images</a>
- <a href="http://download.rockylinux.org/pub/rocky/" target=_blank>Rocky Linux</a>



