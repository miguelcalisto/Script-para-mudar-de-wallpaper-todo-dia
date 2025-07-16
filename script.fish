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

# Verifica se a pasta existe
if not test -d "$wallpaper_dir"
    echo "❌ A pasta '$wallpaper_dir' não existe!"
    exit 1
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
echo "#!/usr/bin/env fish" > $script_path
echo "set wallpaper_dir \"$wallpaper_dir\"" >> $script_path
echo "set wallpapers (ls -1S \$wallpaper_dir | grep -iE '\\.(png|jpe?g)\$')" >> $script_path
echo "set num (count \$wallpapers)" >> $script_path
echo "" >> $script_path
echo "if test \$num -eq 0" >> $script_path
echo "    echo \"Nenhuma imagem válida encontrada em \$wallpaper_dir\" >> $log_path" >> $script_path
echo "    exit 1" >> $script_path
echo "end" >> $script_path
echo "" >> $script_path
echo "set day_of_year (date +%j)" >> $script_path
echo "set index (math \"(\$day_of_year - 1) % \$num + 1\")" >> $script_path
echo "set selected \"\$wallpaper_dir/\$wallpapers[\$index]\"" >> $script_path
echo "" >> $script_path
echo "echo \"Mudando para o wallpaper do dia \$day_of_year: \$selected\" >> $log_path" >> $script_path
echo "feh --bg-scale \"\$selected\" >> $log_path 2>&1" >> $script_path

chmod +x $script_path

# Criando wall.service
echo "✅ Criando systemd service em $service_path"
echo "[Unit]" > $service_path
echo "Description=Mudar wallpaper à meia-noite" >> $service_path
echo "" >> $service_path
echo "[Service]" >> $service_path
echo "Type=oneshot" >> $service_path
echo "Environment=\"DISPLAY=:0\"" >> $service_path
echo "Environment=\"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus\"" >> $service_path
echo "ExecStart=/usr/bin/fish $script_path" >> $service_path

# Criando wall.timer
echo "✅ Criando systemd timer em $timer_path"
echo "[Unit]" > $timer_path
echo "Description=Timer para mudar wallpaper à meia-noite" >> $timer_path
echo "" >> $timer_path
echo "[Timer]" >> $timer_path
echo "OnCalendar=00:00" >> $timer_path
echo "Persistent=true" >> $timer_path
echo "" >> $timer_path
echo "[Install]" >> $timer_path
echo "WantedBy=timers.target" >> $timer_path

# Ativando systemd user timer
echo ""
echo "🔁 Recarregando systemd e ativando timer..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable wall.timer
systemctl --user start wall.timer

echo ""
echo "✅ Tudo pronto! O wallpaper será alterado automaticamente todos os dias à meia-noite."
echo "Você pode acompanhar os logs em: $log_path"

