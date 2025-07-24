#!/usr/bin/env bash

echo ""
echo "=== Configurador automático de troca diária de wallpaper ==="
echo ""

# Verifica se o feh está instalado
if ! command -v feh &> /dev/null; then
    echo "❌ O programa 'feh' não está instalado. Por favor instale com:"
    echo "    sudo apt install feh"
    exit 1
fi

# Solicita o diretório de wallpapers
read -rp "Informe o caminho da pasta com os wallpapers: " wallpaper_dir
wallpaper_dir=$(eval echo "$wallpaper_dir")  # Expande ~ corretamente

# Verifica se a pasta existe
if [ ! -d "$wallpaper_dir" ]; then
    echo "❌ A pasta '$wallpaper_dir' não existe!"
    exit 1
fi

# Cria os diretórios necessários
mkdir -p ~/SCRIPTS/LOGS
log_path=~/SCRIPTS/LOGS/logs_scriptDataDoAnoTamanho.log

# Criando o script de troca de wallpaper
script_path=~/SCRIPTS/scripti3.sh
echo "✅ Criando script de troca de wallpaper em $script_path"
cat > "$script_path" <<EOF
#!/usr/bin/env bash

wallpaper_dir="$wallpaper_dir"
log_path="$log_path"

mapfile -t wallpapers < <(find "\$wallpaper_dir" -maxdepth 1 -type f -iregex '.*\.\(png\|jpe?g\)$' | sort)

num=\${#wallpapers[@]}
if [ "\$num" -eq 0 ]; then
    echo "Nenhuma imagem válida encontrada em \$wallpaper_dir" >> "\$log_path"
    exit 1
fi

day_of_year=\$(date +%j)
index=\$(( (day_of_year - 1) % num ))

selected="\${wallpapers[\$index]}"

echo "Mudando para o wallpaper do dia \$day_of_year: \$selected" >> "\$log_path"
feh --bg-scale "\$selected" >> "\$log_path" 2>&1
EOF

chmod +x "$script_path"

# Fallback: apenas autostart gráfico
echo ""
echo "✅ Adicionando método de fallback para login gráfico..."

autostart_dir="$HOME/.config/autostart"
autostart_file="$autostart_dir/wallpaper-autostart.desktop"
mkdir -p "$autostart_dir"

echo "✅ Criando autostart em $autostart_file"
cat > "$autostart_file" <<EOF
[Desktop Entry]
Type=Application
Exec=/bin/bash $script_path
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Mudar Wallpaper
Comment=Troca automática de wallpaper no login gráfico
EOF

echo ""
echo "✅ Tudo pronto! O script será executado automaticamente no login gráfico."
echo "📄 Você pode acompanhar os logs em: $log_path"
echo ""
echo "✅ Wallpaper automático configurado com sucesso!"



# Configuração do Systemd para a troca automática de wallpaper à meia-noite
echo ""
echo "✅ Configurando o systemd para a troca automática de wallpaper à meia-noite..."

# Criação do arquivo wall.service
service_file="$HOME/.config/systemd/user/wall.service"
mkdir -p "$(dirname "$service_file")"
cat > "$service_file" <<EOF
[Unit]
Description=Mudar wallpaper à meia-noite

[Service]
Type=oneshot
Environment="DISPLAY=:0"
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
ExecStart=/bin/bash ${HOME}/SCRIPTS/scripti3.sh

[Install]
WantedBy=default.target
EOF

# Criação do arquivo wall.timer
timer_file="$HOME/.config/systemd/user/wall.timer"
cat > "$timer_file" <<EOF
[Unit]
Description=Timer para mudar wallpaper à meia-noite

[Timer]
OnCalendar=00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Habilitando o timer
echo "✅ Habilitando o timer do systemd..."
systemctl --user daemon-reload
systemctl --user enable wall.timer
systemctl --user start wall.timer

echo ""
echo "✅ Systemd configurado! A troca de wallpaper será feita automaticamente à meia-noite."
