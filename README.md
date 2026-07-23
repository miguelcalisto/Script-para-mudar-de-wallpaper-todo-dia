# 📄 Wallpaper Diário

configura automaticamente a **troca diária de wallpaper** no Linux (Debian ou similar), usando:

- `feh` para aplicar o wallpaper
- **Autostart em .config** e **systemd** para agendar a execução diária

---

**Observação foi testado apenas no debian com i3wm x11**
**imagens aceitas: png, jpg, jpeg, webp, svg**

## ✅ Requisitos

```bash
sudo apt update
sudo apt install feh --yes
```

1. **Clone o repositório.**

```bash
git clone https://github.com/miguelcalisto/Script-para-mudar-de-wallpaper-todo-dia.git
```

```bash
cd Script-para-mudar-de-wallpaper-todo-dia/
sudo chmod +x script.sh
./script.sh
```

O script solicitará o **diretório** **(O CAMINHO DEVE SER ABSOLUTO)** onde seus wallpapers estão localizados (ex: `/home/user/Downloads/Wallpapers`) e irá movê-los para `~/Imagens/Wallpapers/`.

---

3. **Estrutura de diretórios**

```text
~/.config/change-wallpaper/
├── script.sh                     # Script principal que contém a lógica de troca diária de wallpapers
└── log.log                       # Log da mudança dos wallpapers

~/.config/autostart/
└── wallpaper-autostart.desktop   # Arquivo de autostart para executar o script no login gráfico

~/.config/systemd/user/
├── wall.service                  # Serviço que executa o script uma vez
└── wall.timer                    # Timer que agenda o serviço todo dia às 00:00

~/Imagens/Wallpapers/
└── ...                           # Wallpapers do usuário
```

Verificar se o timer está ativo com:

```bash
systemctl --user status wall.timer
```

```bash
systemctl --user list-timers
```

Se quiser desativar:

```bash
systemctl --user disable --now wall.timer
```

---

## ❌ Como remover completamente

```bash
rm -rf ~/.config/change-wallpaper

rm ~/.config/autostart/wallpaper-autostart.desktop

rm ~/.config/systemd/user/wall.service
rm ~/.config/systemd/user/wall.timer

systemctl --user disable --now wall.timer
```
