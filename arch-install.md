# My Arch Install Guide
Adapted/taken from the *[ArchWiki Installation guide](https://wiki.archlinux.org/title/Installation_guide?ref=bluelinden.art)*  
Any text within double quotes in the code blocks need to be replaced with the variable you require **without** the double quotes  
Click on each step for more detailed information
## Getting the installation image
## Pre-installation stage
<details><summary>Set console keyboard layout and font</summary>
An optional step if happy with the default settings of a *US* console keymap. Otherwise the available layouts can be listed with `localectl list-keymaps`, *I'll most likely need to change the keymap to "uk"*.
    
Changing the console font is also optional, but it might be a good idea to change to a larger font to see the command line more clearly. Again, a list of available fonts can be found in `/usr/share/kbd/consolefonts/`, just need to omit the path and file extension. *I found "ter-120b" worked great on my laptop, clear and not too big.*
</details>
```
# loadkeys "country_code"
```
```bash
setfont "console_font"
```

### Verify boot mode
```bash
cat /sys/firmware/efi/fw_platform_size
```
Should return `64`

### Connect to the internet
#### How to connect to Wi-Fi
```bash
iwctl
```
```bash
[iwd]# device list
```
```bash
[iwd]# station "wlan0" scan
```
```bash
[iwd]# station "wlan0" get-networks
```
```bash
[iwd]# station "wlan0" connect "fanling/fanling_5G"
```
```bash
Passphrase: ********
```
**Ctrl + D** to exit

#### How to test network connection
```bash
ping archlinux.org
```
Should see byte reply from archlinux.org

**Ctrl + C** to stop ping reply

### Update the system clock
```bash
timedatectl
```

### Partition the disks
Identify the disk to be partitioned
```bash
fdisk -l
```
or 
```bash
lsblk
```

Enter partitioning tool interactive prompt
```bash
fdisk /dev/"mmcblk0"
```
```
Command (m for help):
```
Create ESP partition
1. "n"
2. "1"
3. "&#x23CE;"
4. "+1G"
5. "t"
6. ("L" to see the list of all types)
7. "1"

Create root partition
1. "n"
2. "2"
3. "&#x23CE;"
4. "&#x23CE;"

Write all changes to the disk
1. "w"

### Format the partitions
<details><summary><em>Format EFI system partition</em></summary>
Here we are adding a file system to the ESP. Instead of the usual Linux EXT4 file system, we add the more universal FAT32 file system. 

Make sure you include the ESP partition extension to the name of the drive when entering the command.
</details>

```bash
mkfs.fat -F 32 /dev/"mmcblk0p1"
```

Format root partition
```bash
mkfs.ext4 /dev/"mmcblk0p2"
```

### Mount the file systems
```bash
mount /dev/"mmcblk0p2" /mnt
```
```bash
mount -m /dev/"mmcblk0p1" /mnt/boot
```

## Installation stage
### Select mirror
```bash
pacman -Syy
```
```bash
pacman -S reflector
```
Backup mirror list
```bash
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_bak
```
Update mirror list to local region
```bash
reflector -c ""HK"" -f 12 -l 10 -n 10 --save /etc/pacman.d/mirrorlist
```
Double check
```bash
nano /etc/pacman.d/mirrorlist
```

### Install essential packages
```bash
pacstrap -K /mnt base linux linux-firmware nano networkmanager sudo efibootmgr
```

## Configure the system
### Fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
Check file

### Chroot
```bash
arch-chroot /mnt
```

### Set the time **(need to double check time zone)**
(List timezone if need be: `timedatectl list-timezones`)
```bash
ln -sf /usr/share/zoneinfo/"Asia"/"Hong_Kong" /etc/localtime
```
```bash
hwclock --systohc
```
**Check Clock drift thingy**

### Localization
Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and other locales **(<em>en_HK? or en_GB?</em>)**, then:
```bash
locale-gen
```
Create `/etc/locale.conf` file and set the LANG variable:
```bash
echo LANG=en_US.UFT-8 > /etc/locale.conf
>export lang=en_US.UTF-8
```
Make console keyboard layout permanent
```bash
echo KEYMAP=uk > /etc/vonsole.conf
```

### Network configuration
```bash
echo "hydrogen-chrultrabook" > /etc/hostname
```
```bash
nano /etc/hosts
```
Add the following lines to `/etc/hosts`
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   "hydrogen-chrultrabook"
```
>Add Network Manager!
>Check to see if other services are running?
>```bash
>systemctl --type=service
>```
>```bash
>pacman -S networkmanager
>```
>```bash
>systemctl enable NetworkManager
>```

### Initramfs (worth looking into?)

### Set the root password
```bash
passwd
```

### Create user and add privileges
```bash
useradd -m -G wheel "andyball"
```
```bash
passwd "andyball"
```
```bash
EDITOR=nano visudo
```
Uncomment '%wheel ALL=(ALL:ALL) ALL

### Install the bootloader
Bring up relevant info to copy
```bash
cat /etc/fstab
```
Create boot entry
```bash
efibootmgr -c -d /dev/"mmcblk0" -p 1 -L "Arch Linux" -l /vmlinuz-linux -u 'root=UUID="root_parition_UUID" rw initrd=\initramfs-linux.img'
```
If correct, third line of output will have the 'Arch Linux' `Boot*` first, with the correct root partition UUID at the end.

## Reboot
```bash
exit
```
```bash
reboot
```
and pray!

## Post-installation set up
```bash
nmcli device wifi list
nmcli device wifi connect "fanling/fanling_5G" password "19911993"
```
CHECK WIKI FOR DETAILS!