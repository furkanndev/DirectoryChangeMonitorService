#!/bin/bash

HEDEF_DIZIN="/home/mrlinux/Desktop"
KAYIT_DOSYASI="/home/mrlinux/Desktop/kayit.txt"

numara=1

while true
do

  read path action file < <(inotifywait -e modify,attrib,close_write,move,create,delete $HEDEF_DIZIN)
  ZAMAN=$(date +"%Y-%m-%d %T")
  MESAJ="$numara. $HEDEF_DIZIN dizininde $ZAMAN tarihinde değişiklik yapıldı: $path $action $file"
  echo "$MESAJ" >> $KAYIT_DOSYASI
  ((numara++))
done
