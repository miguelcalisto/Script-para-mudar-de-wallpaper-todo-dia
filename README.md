# 📄 Wallpaper Diário com systemd 

Este projeto configura automaticamente um sistema de **troca diária de wallpaper** no Linux (Debian ou similar), usando:

- `feh` para aplicar o wallpaper
- `fish` para a lógica do script
- `systemd --user` para agendar a execução diariamente à meia-noite

---

## ✅ Requisitos

Antes de usar o script, instale os seguintes pacotes:

```bash
sudo apt update
sudo apt install feh fish

```
## como usar 
- sudo chmod +x sc.fish

- fish ./sc.fish
