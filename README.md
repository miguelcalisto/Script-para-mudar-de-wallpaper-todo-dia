# 📄 Wallpaper Diário

Este projeto configura automaticamente a **troca diária de wallpaper** no Linux (Debian ou similar), usando:
- `feh` para aplicar o wallpaper
- `bash` como shell de execução do  script
- **Autostart em .config** e **systemd** para agendar a execução diária

---
**Observação foi testado apenas no debian com i3wm x11**

## ✅ Requisitos

Antes de usar o script, instale o pacote `feh`:

```bash
sudo apt update
sudo apt install feh
```

## 🛠 Como usar

1. **Clone ou baixe o repositório.**
2. **Torne o script executável**:

```bash
cd /caminho/para/Script-para-mudar-de-wallpaper-todo-dia
sudo chmod +x script.sh
```

3. **Execute o script**:

```bash
./script.sh
```


O script solicitará o **diretório** **(O CAMINHO DEVE SER ABSOLUTO)** onde seus wallpapers estão localizados (ex: `/home/user/Downloads/Wallpapers`) e configurará o sistema para aplicar automaticamente um novo wallpaper a cada dia.

---


## ⚙️ Como funciona

Ao executar o script, ele faz o seguinte:

1. **Verifica se o `feh` está instalado.**  
   Caso não esteja, exibe uma mensagem com instruções para instalação.

2. **Solicita ao usuário o caminho da pasta com os wallpapers.**  
   A pasta deve conter imagens `.jpg`, `.jpeg` ou `.png`.

3. **Cria a seguinte estrutura de diretórios no sistema:**

```
~/SCRIPTS/
├── script.sh                     # Script principal que contém a lógica de troca diária de wallpapers
└── LOGS/
    └── logs_scriptDataDoAnoTamanho.log  # Log com histórico das execuções
~/.config/autostart/
└── wallpaper-autostart.desktop  # Arquivo de autostart para executar o script no login gráfico
```

4. **Gera o script `script.sh`**, responsável por:
   - Obter o **dia do ano atual** (ex: 001 a 365).
   - Listar as imagens da pasta ordenadas por **tamanho decrescente**.
   - Calcular o índice da imagem do dia com base no número do dia.
   - Definir o wallpaper com `feh`.
   - Registrar o processo em um log localizado em `~/SCRIPTS/LOGS/`.

5. **Cria um arquivo de autostart**, que:
   - Executa o script automaticamente **no login gráfico**.

6. **Cria um serviço com systemd**, que:
   - Permite a execução diária do script de forma programada as 00:00.

---

## 🕒 Execução automática com systemd 

Além do autostart , o script também configura um **timer com systemd para executar diariamente à meia-noite**.

Ele cria os seguintes arquivos no diretório do systemd do usuário:

```
~/.config/systemd/user/
├── wall.service   # Serviço que executa o script uma vez
└── wall.timer     # Timer que agenda o serviço todo dia às 00:00
```

O timer é ativado automaticamente e verifica todos os dias, à meia-noite, se deve trocar o wallpaper.

Você pode verificar se o timer está ativo com:

```bash
systemctl --user status wall.timer
```

Para ver quando ele será executado novamente:

```bash
systemctl --user list-timers
```

Se quiser desativar:

```bash
systemctl --user disable --now wall.timer
```

---

## ❌ Como remover completamente

Caso queira remover o script e todos os arquivos relacionados:

```bash
# Remover scripts e arquivos criados
rm -rf ~/SCRIPTS/

# Remover o arquivo de autostart
rm ~/.config/autostart/wallpaper-autostart.desktop

# Remover os arquivos do systemd
rm ~/.config/systemd/user/wall.service
rm ~/.config/systemd/user/wall.timer

# Desativar o timer (se ainda estiver ativo)
systemctl --user disable --now wall.timer
```

Após isso, recomenda-se encerrar a sessão do usuário para que as alterações tenham efeito.

