#!/bin/bash

# Membuat variabel dengan nama Anda
name="Ignatius Barry Santoso Hehe"

# Mencetak sapaan dengan nama
echo "Hello, my name is ${name}"

# Menampilkan ukuran memory pada sistem dalam satuan megabytes.
# Menggunakan perintah `free --mega` dan menampilkan hasilnya
while (( i < 3 )); do
  echo "Menampilkan ukuran memory pada sistem dalam satuan megabytes:"
  free --mega
  echo ""

  # Jeda selama 1 detik
  sleep 1

  # Menampilkan penggunaan ruang disk pada filesystem dalam satuan gigabytes.
  # Menggunakan perintah `df -BG` dan menampilkan hasilnya
  echo "Menampilkan penggunaan ruang disk pada filesystem dalam satuan gigabytes:"
  df -BG
  echo ""

  # Jeda selama 1 detik
  sleep 1

  # Menampilkan penggunaan ruang disk pada filesystem hanya untuk kolom Filesystem dan Use%
  # Menampilkan header "Filesystem Use%" diikuti oleh baris hasil dari `df -h` tanpa entri `tmpfs`
  echo "Menampilkan penggunaan ruang disk pada filesystem hanya untuk kolom Filesystem dan Use%:"
  echo "Filesystem Use%"
  df -h | awk '$1 != "tmpfs" {print $1, $5}'
  echo ""

  # Jeda selama 1 detik
  sleep 1

  # Increment the loop counter
  ((i++))
done
