#!/usr/bin/env bash

DIR_WALLPAPERS="$HOME/Imagens/Wallpapers"
ARQUIVO_LOG="$HOME/SCRIPTS/LOGS/log.log"

mkdir -p "$(dirname "$ARQUIVO_LOG")"

data_atual=$(date "+%d/%m/%Y - %H:%M:%S")

shopt -s nullglob nocaseglob

wallpapers=("$DIR_WALLPAPERS"/*.{png,jpg,jpeg,webp,svg})

total_wallpapers=${#wallpapers[@]}

if [ "$total_wallpapers" -eq 0 ]; then
echo "[$data_atual] Erro: Nenhuma imagem válida encontrada em $DIR_WALLPAPERS"
exit 1
fi

dia_do_ano=$(date +%j | sed 's/^0*//')

indice=$(( (dia_do_ano - 1) % total_wallpapers ))

wallpaper_escolhido="${wallpapers[$indice]}"

echo "[$data_atual] Mudando para o wallpaper do dia $dia_do_ano: $wallpaper_escolhido" >> "$ARQUIVO_LOG"

export DISPLAY="${DISPLAY:-:0}"

feh --bg-fill "$wallpaper_escolhido" >> "$ARQUIVO_LOG" 2>&1
