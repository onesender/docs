# Downgrade
Sebelum downgrade, harap menonaktifkan aplikasi yang sedang berjalan
```
systemctl stop onesender@x
```
**ps**: _Ganti `x` dengan nomor onesender yang digunakan_

contoh

_systemctl stop onesender@1_

### Langkah downgrade
Untuk downgrade OneSender silahkan mengikuti langkah-langkah berikut:

1. Hapus isi tabel setting `_prefix_settings`. Prefix tabel menyesuaikan instalasi di server Anda. 
   Hapus isi tabel setting untuk melakukan install ulang. Tanpa menghapus catatan delivery.
2. Replace file `/opt/onesender/onesender-x86_64` dengan versi yang yang diinginkan.
3. Ubah settingan file `config_x.yaml`. 
   Sesuaikan file config dengan yang digunakan.
```
auto_upgrade:
    enabled: false
```
4. Install setting baru
```
cd /opt/onesender
./onesender-x86_64 -c /opt/onesender/config_1.yaml --install
```
**PS**:
ubah file config dengan sesuai file yang digunakan

```
systemctl stop onesender@x
```
