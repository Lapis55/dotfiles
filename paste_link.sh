#!/bin/bash

sudo rm -rf ~/dotfiles/.vim/bundle/neobundle.vim
sudo rm -rf ~/.vim
rm ~/.vimrc
rm ~/.bashrc
rm ~/.latexmkrc
rm ~/.profile
wget https://raw.github.com/git/git/master/contrib/completion/git-completion.bash
wget https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh

git clone https://github.com/Shougo/neobundle.vim ~/dotfiles/.vim/bundle/neobundle.vim
ln -s ~/dotfiles/.vim ~/.vim
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.latexmkrc ~/.latexmkrc
ln -s ~/dotfiles/.profile ~/.profile

mkdir ~/.config/i3
ln -s ~/dotfiles/i3_files/i3/config ~/.config/i3/config
mkdir ~/.config/i3status
ln -s ~/dotfiles/i3_files/i3status/config ~/.config/i3status/config

