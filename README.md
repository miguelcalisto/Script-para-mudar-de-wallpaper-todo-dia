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
 cd  Script-para-mudar-de-wallpaper-todo-dia
   
 sudo chmod +x script.fish

 fish ./script.fish
 ```


## Observação
- Apenas foi testado no debian com x11 e i3wm
- quando o script perguntar o caminho das pastas dos wallpapers o caminho deve ser absoluto como /home/seu_nome/Dowloads/Walls
- os scripts .fish e .bash devem fazer as mesmas coisas caso algum não funcione tente o outro

## ⚙️ Como funciona

Ao executar o script principal:

1. **Verifica se o `feh` está instalado.**  
   Caso não esteja, exibe uma mensagem com instruções para instalação.

2. **Solicita ao usuário o caminho da pasta com os wallpapers.**  
   Essa pasta deve conter imagens `.jpg`, `.jpeg` ou `.png`.

3. **Cria a seguinte estrutura de diretórios no sistema:**

```
~/SCRIPTS/
├── scripti3.fish                # Script principal que contém a lógica de troca diária de wallpapers
└── LOGS/
    └── logs_scriptDataDoAnoTamanho.log  # Log com histórico das execuções

~/.config/systemd/user/
├── wall.service                # Serviço systemd que executa o script
└── wall.timer                  # Timer que dispara o serviço todo dia à meia-noite
```

4. **Gera o script `scripti3.fish`**, responsável por:
   - Esse é o script responsavel pela lógica de troca de wallpapers a intenção é que não se repita os wallpapers como um ciclo
   - Obter o **dia do ano atual** (ex: 001 a 365)
   - Listar as imagens da pasta ordenadas por **tamanho decrescente**
   - Calcular o índice da imagem do dia com base no número do dia
   - Definir o wallpaper com `feh`
   - Registrar o processo em um log localizado em `~/SCRIPTS/LOGS/`

5. **Cria o serviço systemd e o timer correspondente**, que:
   - Executa `scripti3.fish` automaticamente todos os dias à **meia-noite**
   - Garante persistência mesmo após reinicializações
   - esse serviço fica em `~/.config/systemd/user/`

   Você pode verificar se o timer está ativo com:

   ```bash
   systemctl --user list-timers --all | grep wall.timer
   ```

   E para verificar o status detalhado:

   ```bash
   systemctl --user status wall.timer
   ```

   Para conferir se o script foi executado corretamente, veja o log gerado em:

   ```bash
   cat ~/SCRIPTS/LOGS/logs_scriptDataDoAnoTamanho.log
   ```


6. **Ativa e inicia o timer automaticamente**, sem necessidade de reiniciar o sistema.

---




## ❌ Como remover completamente
```
# Parar e desativar o timer
systemctl --user stop wall.timer
systemctl --user disable wall.timer

# Remover scripts e arquivos criados
rm -rf ~/SCRIPTS/
rm ~/.config/systemd/user/wall.service
rm ~/.config/systemd/user/wall.timer

# Recarregar systemd do usuário
systemctl --user daemon-reload

#Remover pastas e arquivos criados
rm -rf ~/SCRIPTS

#Remover o .desktop
rm .config/autostart/wallpaper-autostart.desktop 
```

## AVISO
foi adicionado a execução do script3 em .profile e .config/autostart
