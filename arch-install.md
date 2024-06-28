# My Arch Install Guide
Adapted/taken from the *[ArchWiki Installation guide](https://wiki.archlinux.org/title/Installation_guide?ref=bluelinden.art)*  

>[!IMPORTANT]
>Any text within double quotes in the code blocks need to be replaced with the variable you require **without** the double quotes  

>[!TIP]
>For more information/details on each step, look for the disclosure widgets!

## Getting the installation image

## Pre-installation stage
<details>
<summary><strong>Set console keyboard layout and font</strong></summary>

An optional step if happy with the default settings of a <em>US</em> console keymap. Otherwise the available layouts can be listed with `localectl list-keymaps`.  
<em>I'll most likely need to change the keymap to "uk".</em>
    
Changing the console font is also optional, but it might be a good idea to change to a larger font to see the command line more clearly. Again, a list of available fonts can be found in `/usr/share/kbd/consolefonts/`, just need to omit the path and file extension.  
<em>I found "ter-120b" worked great on my laptop, clear and not too big.</em>
</details>

```
# loadkeys "country_code"
```
```
# setfont "console_font"
```
<br>

**Verify boot mode**

```
# cat /sys/firmware/efi/fw_platform_size
```
<details>
<summary>Should return <code>64</code></summary>

If the command returns `64`, then the system is booted in UEFI mode and has a 64-bit x64 UEFI. Exactly what we need for this installation.

If the command returns `32`, then the system is booted in UEFI mode and has a 32-bit IA32 UEFI; you can still follow along but it will limit the boot loader choice later to <em>systemd-boot</em> and <em>GRUB</em>.

If the file does not exist, the system may be booted in BIOS (or CSM) mode. You'll need to look up another guide or look at how to change to UEFI mode.
</details>

**Connect to the internet**  
<details>
<summary>Either via Ethernet...</summary>

Just plug in that cable!
</details>

<details>
<summary><strong>... or via Wi-Fi</strong></summary>

**Enter the interactive prompt for the iNet Wireless Daemon (***iwd*** package)**
```
# iwctl
```
Note the change in the command prompt.  
Find the name of your wireless device using the following command:
```
[iwd]# device list
```
Use the following commands to first scan for available Wi-Fi networks, then output the list to view. 
```
[iwd]# station "device_name" scan
```
```
[iwd]# station "device_name" get-networks
```
Connect to the network with the following command and enter the passphrase at the prompt. 
```
[iwd]# station "device_name" connect "SSID"
```
```
    Passphrase: ********
```
Exit the interactive prompt by pressing:
<kbd>Ctrl</kbd> + <kbd>D</kbd>
</details>

#### How to test network connection
```
# ping archlinux.org
```
Should see byte reply from archlinux.org

**'Ctrl + C'** to stop ping reply

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