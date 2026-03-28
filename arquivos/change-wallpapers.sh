#!/usr/bin/env bash

wallpaper_dir="$HOME/Imagens/Wallpapers"

mapfile -t wallpapers < <(ls -1S "$wallpaper_dir" | grep -iE '\.(png|jpe?g|webp|svg)$')

num=${#wallpapers[@]}

    if [ "$num" -eq 0 ]; then
        echo "Nenhuma imagem válida encontrada em $wallpaper_dir" >>/home/debian/SCRIPTS/LOGS/log.log
        exit 1
    fi

    day_of_year=$(date +%j)
    day_of_year=$((10#$day_of_year))

    index=$(((day_of_year - 1) % num))

    selected="$wallpaper_dir/${wallpapers[$index]}"

    current_datetime=$(date "+%d/%m/%Y - %H:%M:%S")

    echo "Mudando para o wallpaper do dia $day_of_year: $selected na data: $current_datetime" >>/home/debian/SCRIPTS/LOGS/log.log

    feh --bg-scale "$selected" >>/home/debian/SCRIPTS/LOGS/log.log 2>&1
    feh --bg-fill "$selected"
