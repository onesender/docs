Use this guide if you want to install multiple OneSender on a single VPS server.

Please note the following. For example, you want to install 5 applications.

- You only need 1 binary file. The location is in the `/opt/onesender/onesender-x86_64` folder.
- Please don't change the onesender's default folder.
- You need to create 5 settings files in yaml format.
- All these applications can use 1 database. Each one uses a unique prefix. Example: `os1_`, `os2_`, `os3_`.

## Install
1. Download installer from your member area [https://onesender.net/my-account/](https://onesender.net/my-account/).

2. Upload installer file to your server. Then extract the installer file.
```
#/tmp/onesender-latest.zip
cd /tmp
unzip -q onesender-latest.zip
ls -l
```

3. Download the install script from github
```
cd /tmp/onesender-latest
wget https://raw.githubusercontent.com/onesender/docs/main/script/install-many.sh
```

4. Jalankan script install
```
sudo bash install-many.sh
```

This script will copy files to the folder `/opt/onesender` automatically.

![Install screen](/media/install-many-1.png "Install screen")
