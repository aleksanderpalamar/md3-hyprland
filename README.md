# MD3 Hyprland Setup

Um projeto de automação para transformar o Arch Linux em um ambiente desktop moderno, estético e funcional baseado nos princípios do **Material Design 3 (Google)**, utilizando o gerenciador de janelas **Hyprland**.

## Funcionalidades

- **Estética Material You:** Cores extraídas dinamicamente do seu wallpaper (usando **Matugen**) aplicadas a todo o sistema.
- **Hyprland Configurado:** Animações fluidas, bordas arredondadas (16px), sombras suaves e layout _dwindle_.
- **Tema Dinâmico Real (MD3):**
  - Suporte completo a **Light/Dark Mode** com troca instantânea.
  - Cores semânticas (Surface, Primary, Container) garantindo contraste perfeito.
- **Componentes Integrados:**
  - **Barra:** Waybar com design flutuante e cores Material Design 3.
  - **Launcher:** Rofi estilizado para combinar com o tema.
  - **Terminal:** Kitty com cores sincronizadas.
  - **Notificações:** SwayNC (Central de Controle) com design consistente.
- **Instalação Segura:** Script automatizado que detecta configurações existentes e realiza backups automáticos antes de aplicar mudanças.

## Tecnologias Utilizadas

- **WM:** Hyprland
- **Barra:** Waybar
- **Launcher:** Rofi (Wayland)
- **Cores/Temas:** Matugen (Substituindo Wallust para melhor fidelidade MD3)
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
    git clone https://github.com/aleksanderpalamar/md3-hyprland-setup.git
    cd md3-hyprland-setup
    ```

2.  Execute o script de instalação:

    ```bash
    ./install.sh
    ```

3.  Siga as instruções na tela. O script irá:
    - Verificar dependências.
    - Instalar os pacotes necessários (incluindo `matugen-bin`).
    - Fazer backup de configurações antigas (`~/.config/hypr.backup_DATE`, etc).
    - Criar links simbólicos para as novas configurações.
    - Baixar um wallpaper inicial e gerar as cores.

## Personalização

### Trocar Wallpaper
Use o script integrado ou o menu de configurações (se disponível). Para gerar manualmente:

```bash
# Para tema Dark (Padrão)
matugen image /caminho/do/wallpaper.jpg -c ~/.config/matugen/config.toml -m dark

# Para tema Light
matugen image /caminho/do/wallpaper.jpg -c ~/.config/matugen/config.toml -m light
```

O script `init_wallpaper.sh` gerencia isso automaticamente no boot.

### Atalhos Úteis (Keybindings)

- **Menu de Configurações:** Verifique seu `hyprland.conf` para atalhos de troca de tema.
- **Recarregar Waybar:** `pkill -SIGUSR2 waybar`

## Estrutura de Arquivos

- `install.sh`: Orquestrador da instalação.
- `scripts/`: Scripts modulares para cada etapa.
- `config/`: Dotfiles organizados (Hyprland, Waybar, Matugen Templates).
- `assets/`: Recursos estáticos.

## Nota

Este script foi projetado para **Arch Linux**. O uso em outras distribuições pode exigir adaptações nos comandos de instalação de pacotes (`pacman`/`yay`).

## Licença

Este projeto está licenciado sob a Licença Pública Geral GNU v3.0 (GPLv3) - veja o arquivo [LICENSE](LICENSE) para detalhes.
