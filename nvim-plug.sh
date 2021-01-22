#!/bin/bash

if [ "$1" != "" ]; then

  while getopts i:a:d:u:h flag
  do
    case "${flag}" in
      i) 
        install=${OPTARG};;
      a) 
        activate=${OPTARG};;
      d) 
        deactivate=${OPTARG};;
      u)
        uninstall=${OPTARG};;
      h)
        helpmanual=1;;
      *) 
        echo "Wrong option: ${flag} . Run: nvim-plug -h"
        exit 1;;
    esac
  done

else
  echo "No options given. Run: nvim-plug -h"
  exit 1
fi

# Help
if [ $helpmanual ]; then
  echo "nvim-plug -h"
  echo "Showing manual: "
  exit 0
fi
# Help

# Install 
if [ $install ]; then

# Clone the plugin repository from github
  reponame=$(echo "$install" | cut -d"/" -f2)
  #echo $reponame
  git clone git@github.com:$install ~/.config/nvim/git-real/$reponame
  if [ $? -eq 0 ]; then

    # Activating plugin
    echo "Activating plugin..."
    ln -s ~/.config/nvim/git-real/$reponame ~/.config/nvim/pack/git-plugins/start/$reponame
    #If git clonw works, add plugin on list
    if [ $? -eq 0 ]; then
      echo "$install" >> ~/.config/nvim/git-real/list
      echo "ok!"
    fi
  else
    echo "Erro ao clonar repositório $install"
    exit 1
  fi
fi

# Deactivating Plugin {{{
if [ $deactivate ]; then

  # Removing symbolic link from "pack" directory
  rm ~/.config/nvim/pack/git-plugins/start/$deactivate
  if [ $? -eq 0 ]; then

    # Checking if plugin is installed
    egrep $deactivate ~/.config/nvim/git-real/list
    if [ $? -eq 0 ]; then
      # Checking if plugin is active
      egrep '^#.*/'$deactivate ~/.config/nvim/git-real/list
      if [ $? -eq 0 ]; then
        echo "Plugin já está desativado!"
      else
        # Deactivating plugin
        sed -e '/'$deactivate'/,$s/^/#/' -i ~/.config/nvim/git-real/list
        echo Plugin $deactivate desativado com sucesso!
      fi
    else 
      echo "Plugin não instalado!"
      exit 1
    fi
  else
    echo "Plugin não está ativado! (Link não encotrado)"
    exit 1
  fi
fi
# }}}

# Activate {{{
if [ $activate ]; then
  # Checking if plugin is installed
  if [ -d "$HOME/.config/nvim/git-real/$activate" ]; then
    egrep '^#.*/'$activate ~/.config/nvim/git-real/list
    if [ $? -eq 0 ]; then
      # Activating plugin 
      sed -e '/'$activate'/,$s/#//' -i ~/.config/nvim/git-real/list
      ln -s ~/.config/nvim/git-real/$activate ~/.config/nvim/pack/git-plugins/start/$activate
      echo "Plugin ativado com sucesso!"
    else
      egrep $activate ~/.config/nvim/git-real/list
      if [ $? -eq 0 ]; then
        echo "Plugin já ativado!"
        exit 1
      else
        echo $activate >> ~/.config/nvim/git-real/list 
        echo "Corrigindo presença de $activate na lista!"
      fi
    fi
  else
    echo "Plugin $activate não instalado!"
    exit 1
  fi
fi
# }}}

# Uninstalling plugin {{{
if [ $uninstall ]; then
  # Check if plugin is installed
  if [ -d "$HOME/.config/nvim/git-real/$uninstall" ]; then
    # Removing git directory
    # git rm -r ~/.config/nvim/git-real/$uninstall
    rm -Rf $HOME/.config/nvim/git-real/$uninstall
    if [ $? -eq 0 ]; then
      echo "Diretório git removido!"
      if [ -L "$HOME/.config/nvim/pack/git-plugins/start/$uninstall" ]; then
        rm ~/.config/nvim/pack/git-plugins/start/$uninstall
        if [ $? -eq 0 ]; then
          echo "Link de ativação removido!"
        else
          echo "Falha ao remover link de ativação, porém $uninstall foi removido!"
        fi
      fi
    else
      if [ -L "$HOME/.config/nvim/pack/git-plugins/start/$uninstall" ]; then
        rm ~/.config/nvim/pack/git-plugins/start/$uninstall
        if [ $? -eq 0 ]; then
          echo "Falha na desinstalação, porém $uninstall foi desativado!"
        else
          echo "Falha na desinstalação e desativação de $uninstall. Verifique a existência ou permissões do arquivo!"
        fi
      fi
      echo "Falha ao remover diretório Git: $uninstall"
      exit 1
    fi

    # Removing from list
    egrep $uninstall ~/.config/nvim/git-real/list
    if [ $? -eq 0 ]; then
      grep -v $uninstall ~/.config/nvim/git-real/list > /tmp/list$uninstall.tmp 
      mv -f /tmp/list$uninstall.tmp ~/.config/nvim/git-real/list
      echo "Removendo $uninstall da lista!"
    fi

  else
    echo "Plugin não instalado!"
    exit 1
  fi
fi
#}}}

#if [ "$1" != "" ]; then
#
#  # Repo name
#
## Clone the plugin repository from github
#  reponame=$(echo "$1" | cut -d"/" -f2)
#  #echo $reponame
#  git clone git@github.com:$1 ~/.config/nvim/git-real/$reponame
#  if [ $? -eq 0 ]; then
#
#    # Activating plugin
#    ln -s ~/.config/nvim/git-real/$reponame ~/.config/nvim/pack/git-plugins/start/$reponame
#    #If git clonw works, add plugin on list
#    if [ $? -eq 0 ]; then
#      echo "$1" >> ~/.config/nvim/git-real/list
#      echo "ok!"
#    fi
#  else
#    echo "Erro ao clonar repositório $1"
#    exit 1
#  fi
#
## If repository name was not given, return error
#else
#  echo "Repositório do github não informado!"
#  exit 1
#fi
