#!/usr/bin/env fish
echo ""
echo "=== Configurador automático de troca diária de wallpaper ==="
echo ""

# Verifica se o feh está instalado
if not type -q feh
    echo "❌ O programa 'feh' não está instalado. Por favor instale com:"
    echo "    sudo apt install feh"
    exit 1
end

# Solicita o diretório de wallpapers
read -l -P "Informe o caminho da pasta com os wallpapers: " wallpaper_dir
set wallpaper_dir (eval echo $wallpaper_dir)  # Expande ~

# Verifica se a pasta existe
if not test -d "$wallpaper_dir"
    echo "❌ A pasta '$wallpaper_dir' não existe!"
    exit 1
end

# Verifica e ativa linger se necessário
set linger_status (loginctl show-user (whoami) | grep Linger | cut -d= -f2)
if test "$linger_status" != "yes"
    echo ""
    echo "⚠️  O 'linger' não está habilitado para o usuário (whoami)."
    read -l -P "❓ Deseja ativar agora? (requer sudo) [s/N]: " resp
    switch (string lower -- $resp)
        case s y
            if sudo loginctl enable-linger (whoami)
                echo "✅ 'linger' ativado com sucesso."
            else
                echo "❌ Falha ao ativar 'linger'. Ative manualmente com:"
                echo "    sudo loginctl enable-linger (whoami)"
            end
        case '*'
            echo "⚠️ Prosseguindo sem 'linger'. O timer pode não funcionar fora da sessão gráfica."
    end
end

# Cria os diretórios necessários
mkdir -p ~/SCRIPTS/LOGS
mkdir -p ~/.config/systemd/user

# Caminhos
set script_path ~/SCRIPTS/scripti3.fish
set log_path ~/SCRIPTS/LOGS/logs_scriptDataDoAnoTamanho.log
set service_path ~/.config/systemd/user/wall.service
set timer_path ~/.config/systemd/user/wall.timer

# Criando o scripti3.fish
echo "✅ Criando script de troca de wallpaper em $script_path"
cat > $script_path <<EOF
#!/usr/bin/env fish

set wallpaper_dir "$wallpaper_dir"
set log_path "$log_path"

function detect_dbus_address
    for pid in (pgrep -u (id -u) gnome-session)
        if test -e /proc/\$pid/environ
            set -lx DBUS_SESSION_BUS_ADDRESS (strings /proc/\$pid/environ | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)
            if test -n "\$DBUS_SESSION_BUS_ADDRESS"
                return 0
            end
        end
    end
    set -lx DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/(id -u)/bus"
end

detect_dbus_address
set -lx DISPLAY :0

set wallpapers (find \$wallpaper_dir -maxdepth 1 -type f -iregex '.*\\.(png|jpe?g)' | sort)
set num (count \$wallpapers)

if test \$num -eq 0
    echo "Nenhuma imagem válida encontrada em \$wallpaper_dir" >> \$log_path
    exit 1
end

set day_of_year (date +%j)
set index (math "(\$day_of_year - 1) % \$num + 1")
set selected \$wallpapers[\$index]

echo "Mudando para o wallpaper do dia \$day_of_year: \$selected" >> \$log_path
feh --bg-scale \$selected >> \$log_path 2>&1
EOF

chmod +x $script_path

# Criando wall.service
echo "✅ Criando systemd service em $service_path"
cat > $service_path <<EOF
[Unit]
Description=Mudar wallpaper à meia-noite

[Service]
Type=oneshot
Environment=DISPLAY=:0
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
ExecStart=/usr/bin/fish $script_path
EOF

# Criando wall.timer
echo "✅ Criando systemd timer em $timer_path"
cat > $timer_path <<EOF
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

# Execução imediata
echo ""
echo "🔄 Aplicando wallpaper de hoje..."
fish "$script_path"

# === Execução garantida em qualquer ambiente ===
echo ""
echo "✅ Adicionando métodos de fallback para execução ao login (qualquer ambiente)..."

set marker "# === Wallpaper Auto ==="
set command "/usr/bin/fish $script_path > /dev/null 2>&1 &"

# 1. Autostart gráfico (.desktop)
set autostart_dir ~/.config/autostart
set autostart_file $autostart_dir/wallpaper-autostart.desktop
mkdir -p $autostart_dir

echo "✅ Criando autostart em $autostart_file"
cat > $autostart_file <<EOF
[Desktop Entry]
Type=Application
Exec=$command
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Mudar Wallpaper
Comment=Troca automática de wallpaper no login gráfico
EOF

# 2. Terminal login (TTY, SSH)
if test -f ~/.bash_profile
    set login_file ~/.bash_profile
else if test -f ~/.profile
    set login_file ~/.profile
else
    set login_file ~/.bash_profile
    touch $login_file
end

echo "✅ Garantindo execução no terminal login via $login_file"
if not grep -qF "$marker" $login_file
    echo "" >> $login_file
    echo "$marker" >> $login_file
    echo "$command" >> $login_file
end

# 3. Execução via ~/.xinitrc (startx)
if test -f ~/.xinitrc
    set xinit_file ~/.xinitrc
    echo "✅ Adicionando ao ~/.xinitrc"
    if not grep -qF "$marker" $xinit_file
        echo "" >> $xinit_file
        echo "$marker" >> $xinit_file
        echo "$command" >> $xinit_file
    end
end

echo ""
echo "✅ Tudo pronto! O script será executado:"
echo "  - Diariamente à meia-noite via systemd"
echo "  - No login gráfico via autostart"
echo "  - No login terminal (TTY) via $login_file"
echo "  - E em sessões 'startx' via ~/.xinitrc (se existir)"
echo ""
echo "📄 Você pode acompanhar os logs em: $log_path"
echo ""
echo "✅ Wallpaper automático configurado com sucesso!"

