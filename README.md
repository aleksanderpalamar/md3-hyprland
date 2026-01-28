# MD3 Hyprland Setup

Um projeto de automação para transformar o Arch Linux em um ambiente desktop moderno, estético e funcional baseado nos princípios do **Material Design 3 (Google)**, utilizando o gerenciador de janelas **Hyprland**.

## Funcionalidades

- **Estética Material You:** Cores extraídas dinamicamente do seu wallpaper (usando `wallust`) aplicadas a todo o sistema.
- **Hyprland Configurado:** Animações fluidas, bordas arredondadas (16px), sombras suaves e layout _dwindle_.
- **Componentes Integrados:**
  - **Barra:** Waybar com design flutuante em formato de "pílula".
  - **Launcher:** Rofi estilizado para combinar com o tema.
  - **Terminal:** Kitty com cores sincronizadas.
  - **Notificações:** SwayNC com design limpo e funcional.
- **Instalação Segura:** Script automatizado que detecta configurações existentes e realiza backups automáticos antes de aplicar mudanças.

## Tecnologias Utilizadas

- **WM:** Hyprland
- **Barra:** Waybar
- **Launcher:** Rofi (Wayland fork)
- **Cores/Temas:** Wallust
- **Terminal:** Kitty
- **Gerenciador de Arquivos:** Dolphin
- **Notificações:** SwayNC
- **Automação:** Bash Scripts

## Pré-requisitos

- **Sistema Operacional:** Arch Linux (ou derivado compatível com AUR).
- **Gerenciador de Pacotes:** `pacman` e um AUR helper como `yay` (o script tenta instalar o `yay-bin` se não encontrar).

## Instalação

1.  Clone este repositório (ou baixe a pasta):

    ```bash
    git clone https://github.com/seu-usuario/md3-hyprland-setup.git
    cd md3-hyprland-setup
    ```

2.  Execute o script de instalação:

    ```bash
    ./install.sh
    ```

3.  Siga as instruções na tela. O script irá:
    - Verificar dependências.
    - Instalar os pacotes necessários.
    - Fazer backup de configurações antigas (`~/.config/hypr.backup_DATE`, etc).
    - Criar links simbólicos para as novas configurações.
    - Baixar um wallpaper inicial e gerar as cores.

## Personalização

Para mudar o esquema de cores, basta trocar o wallpaper e rodar o `wallust`:

```bash
wallust run /caminho/para/seu/novo_wallpaper.jpg
```

Para recarregar o Hyprland e a Waybar com as novas cores, você pode precisar reiniciar a sessão ou recarregar os componentes (o Wallust já atualiza os arquivos de configuração, mas algumas aplicações precisam ser reiniciadas).

## Estrutura de Arquivos

- `install.sh`: Orquestrador da instalação.
- `scripts/`: Scripts modulares para cada etapa (verificação, instalação, links).
- `config/`: Arquivos de configuração (dotfiles) otimizados para MD3.
- `assets/`: Recursos estáticos (wallpapers padrão).

## Nota

Este script foi projetado para **Arch Linux**. O uso em outras distribuições pode exigir adaptações nos comandos de instalação de pacotes (`pacman`/`yay`).
