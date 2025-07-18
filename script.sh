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

# Verifica se o bash está sendo usado
if [ -z "$BASH_VERSION" ]; then
    echo "❌ Este script deve ser executado com Bash."
    exit 1
fi

# Solicita o diretório de wallpapers
read -rp "Informe o caminho da pasta com os wallpapers: " wallpaper_dir

# Verifica se a pasta existe
if [ ! -d "$wallpaper_dir" ]; then
    echo "❌ A pasta '$wallpaper_dir' não existe!"
    exit 1
fi

# Cria os diretórios necessários
mkdir -p ~/SCRIPTS/LOGS
mkdir -p ~/.config/systemd/user

# Caminhos
script_path=~/SCRIPTS/scripti3.sh
log_path=~/SCRIPTS/LOGS/logs_scriptDataDoAnoTamanho.log
service_path=~/.config/systemd/user/wall.service
timer_path=~/.config/systemd/user/wall.timer

# Criando o scripti3.sh
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

# Criando wall.service
echo "✅ Criando systemd service em $service_path"
cat > "$service_path" <<EOF
[Unit]
Description=Mudar wallpaper à meia-noite

[Service]
Type=oneshot
Environment="DISPLAY=:0"
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus"
ExecStart=/bin/bash $script_path
EOF

# Criando wall.timer
echo "✅ Criando systemd timer em $timer_path"
cat > "$timer_path" <<EOF
[Unit]
Description=Timer para mudar wallpaper à meia-noite

[Timer]
OnCalendar=00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Ativando systemd user timer
echo ""
echo "🔁 Recarregando systemd e ativando timer..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable wall.timer
systemctl --user start wall.service

# Aplicando imediatamente o wallpaper do dia
echo ""
echo "🔄 Aplicando wallpaper de hoje..."
/bin/bash "$script_path"



echo ""
echo "✅ Adicionando métodos de fallback para execução ao login (qualquer ambiente)..."

# 1. Autostart gráfico (.desktop)
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

# 2. Execução no terminal puro (TTY, SSH, etc.)
login_file=""
if [ -f "$HOME/.bash_profile" ]; then
    login_file="$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]; then
    login_file="$HOME/.profile"
else
    login_file="$HOME/.bash_profile"
    touch "$login_file"
fi

echo "✅ Garantindo execução no terminal login via $login_file"
marker="# === Wallpaper Auto ==="
if ! grep -q "$marker" "$login_file"; then
    {
        echo ""
        echo "$marker"
        echo "/bin/bash $script_path > /dev/null 2>&1 &"
    } >> "$login_file"
fi

# 3. Execução via ~/.xinitrc (para usuários de startx)
xinit_file="$HOME/.xinitrc"
if [ -f "$xinit_file" ]; then
    echo "✅ Adicionando ao ~/.xinitrc"
    if ! grep -q "$marker" "$xinit_file"; then
        {
            echo ""
            echo "$marker"
            echo "/bin/bash $script_path > /dev/null 2>&1 &"
        } >> "$xinit_file"
    fi
fi

echo ""
echo "✅ Tudo pronto! O script será executado:"
echo "  - Diariamente à meia-noite via systemd"
echo "  - No login gráfico via autostart"
echo "  - No login terminal (TTY) via $login_file"
echo "  - E em sessões 'startx' via ~/.xinitrc (se existir)"
echo ""
echo "📄 Você pode acompanhar os logs em: $log_path"
echo ""
echo "✅ Tudo pronto! O wallpaper será alterado automaticamente todos os dias à meia-noite."
echo "Você pode acompanhar os logs em: $log_path"

