#!/bin/bash

sudo rm -rf ~/dotfiles/.vim/bundle/neobundle.vim
sudo rm -rf ~/.vim
rm ~/.vimrc
rm ~/.bashrc
rm ~/.latexmkrc
rm ~/.profile
rm ~/.minttyrc

git clone https://github.com/Shougo/neobundle.vim ~/dotfiles/.vim/bundle/neobundle.vim
ln -s ~/dotfiles/.vim ~/.vim
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.latexmkrc ~/.latexmkrc
ln -s ~/dotfiles/.profile ~/.profile
ln -s ~/dotfiles/.minttyrc ~/.minttyrc
