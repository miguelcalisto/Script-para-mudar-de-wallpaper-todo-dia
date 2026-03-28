#!/usr/bin/env bash

echo ""
echo "=== Configurador automático de troca diária de wallpaper ==="
echo ""

read -rp "Informe o caminho da pasta com os wallpapers: " wallpaper_dir

if [ ! -d "$wallpaper_dir" ]; then
    echo "A pasta '$wallpaper_dir' não existe!"
    exit 1
fi

mkdir -p ~/Imagens/Wallpapers/
cp -r "$wallpaper_dir"/* ~/Imagens/Wallpapers/

# cp -r "$wallpaper_dir"/. ~/Imagens/Wallpapers/

mkdir -p ~/SCRIPTS/LOGS

script_path=~/SCRIPTS/scripti3.sh
mkdir -p ~/SCRIPTS

echo "✅ Criando script de troca de wallpaper em $script_path"
cp ./arquivos/change-wallpapers.sh "$script_path"

chmod +x "$script_path"

echo ""
echo "✅ Script criado com sucesso!"

echo ""
echo "✅ Configurando execução no login gráfico..."

autostart_dir="$HOME/.config/autostart"
autostart_file="$autostart_dir/wallpaper-autostart.desktop"

mkdir -p "$autostart_dir"

cp ./arquivos/wallpapers-autostart.desktop "$autostart_file"

echo "✔ Autostart criado em $autostart_file"

echo ""
echo "✅ Criando serviço e timer do systemd..."

systemd_user_dir="$HOME/.config/systemd/user"
mkdir -p "$systemd_user_dir"

cp ./arquivos/wall.timer ~/.config/systemd/user/wall.timer
cp ./arquivos/wall.service ~/.config/systemd/user/wall.service

systemctl --user daemon-reload

systemctl --user enable --now wall.timer

systemctl --user start wall.service

echo ""
echo "=============================="
echo "✔ Tudo pronto!"
