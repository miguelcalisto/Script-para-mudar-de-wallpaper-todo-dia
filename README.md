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
```bash
 sudo chmod +x sc.fish

 fish ./sc.fish
 ```


## Observação
- Apenas foi testado no debian com x11 e i3wm
- quando o script perguntar o caminho das pastas dos wallpapers o caminho deve ser absoluto como /home/seu_nome/Dowloads/Walls

