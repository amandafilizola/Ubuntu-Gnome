#!/bin/bash

# ============================================
# Função de debug
# ============================================
function log(){
  echo "[LOG] $*"
}

function init(){
    # icons folder
    icons_path="$HOME/.local/share/icons/"
    test -d "$icons_path" || mkdir -p "$icons_path"
    current_folder=$(pwd)
}

# ============================================
# Function to install Korla Icons
# ============================================
function install_korla_icons(){
    local korla_temp_folder="/tmp/korla_temp"
    # Instala o pacote de ícones 'Korla'
    # ------------------------------------------------------------------
    #log "install Korla icon theme"
    [[ -e "${icons_path}/korla" ]] && sudo rm -rf "${icons_path}/korla"
    [[ -e "${icons_path}/korla-light" ]] && sudo rm -rf "${icons_path}/korla-light"

    [[ -e "$korla_temp_folder" ]] || mkdir "$korla_temp_folder" && rm -rf "$korla_temp_folder"
    git clone git@github.com:bikass/korla.git "$korla_temp_folder"
    cd "$korla_temp_folder" && sudo mv korla korla-light "$icons_path"

    # Instala o pacote de folders do 'Korla'
    # o modo de instalação está no github deles.
    log "install Korla icon folder"
    git clone git@github.com:bikass/korla-folders.git
    cd korla-folders
    unzip -x places_1.zip
    mv "places_1" "scalable"
    rm -rf "${icons_path}/korla/places/scalable"
    sudo mv "scalable" "${icons_path}/korla/places"

    rm -rf "$korla_temp_folder"

    log "set icons to Korla"
    gsettings set org.gnome.desktop.interface icon-theme "korla"

    # apply korla icon folders in some folders
    cd "$current_folder"
    bash utils/korla_folders_apply.sh
    #for some reason, after apply, window buttons are going left
    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
}

# ============================================
# Install Breeze-Cursor theme
# ============================================
# function install_breeze_cursor(){
#     sudo apt update
#     sudo apt install -y breeze-cursor-theme

#     gsettings set org.gnome.desktop.interface cursor-theme "Breeze_Snow"
# }

# ============================================
# Install Arc-Dark GTK theme
# ============================================
function install_arc_darker_theme(){
    # install dependencies
    sudo apt install -y autoconf automake pkg-config libgtk-3-dev gnome-themes-standard gtk2-engines-murrine
    cd ~/bin && git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
    ./autogen.sh --prefix=/usr
    sudo make install

    # GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker"
    # Gnome-Shell theme
    gsettings set org.gnome.shell.extensions.user-theme name "Arc-Darker"

    echo "Agora Abra o Gnome Tweak tools e adicione o tema Ark-Dark no Shell"
}

# ============================================
# Install Flat-Remix-dark Gnome-Shell theme
# ============================================
# function install_FlatRemix_Gnome_Shell(){
#     # https://www.gnome-look.org/p/1013030/
#     local flat_remix_dark_url="https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE1ODY3MTUyNjEiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6ImFjMWUyMmY0MTY2MjE3OTU1NzgzZGY2YWEyMWQ2YTBkYTE2OTU0Mzg5YjdmM2YwMTMzZTU3YjZhNzZiMzE1YmM3NTRjNDA0ZmE5MjA3MGExNjY1NzcxNTMxZGQ5M2RlNmNmMTdjNDZjZTc0ZThhYTRmM2E3YzYzNzM2OTllZjZlIiwidCI6MTU4Njc0MDI2NSwic3RmcCI6IjAzZjgxNjg3Y2JlOGUwMzdmNGQ3ZTBkOWQzN2ExODZkIiwic3RpcCI6IjI4MDQ6MTRkOjU0ODE6ODMzOTo6MTAwMSJ9.xFS1Qp2ycsJCf6kOZMFVxnN5P3VcRDph_A5G4133wXk/03-Flat-Remix-Dark_20200412.tar.xz"

#     cd /usr/share/themes
#     sudo wget "$flat_remix_dark_url"
#     sudo tar xf *.tar.xz
#     sudo rm -rf *.tar.xz
# }

# ============================================
# Main
# ============================================
log "Inicializing..."
init
log "Install Korla Icons..."
install_korla_icons
# log "Install Breeze Cursors..."
# install_breeze_cursor
log "Install Arc-Darker GTK theme..."
install_arc_darker_theme
# log "Install FlatRemix Gnome-Shell theme..."
# install_FlatRemix_Gnome_Shell

log "refreshing Gnome..."
gnome-shell --replace &>/dev/null & disown
