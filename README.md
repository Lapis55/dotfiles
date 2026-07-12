# dotfiles

個人用 dotfiles。配置場所は `~/dotfiles` 固定。

管理対象は次の 4 パッケージ。

- `bash`: `.bashrc`
- `vim`: `.vimrc`, `.vim/`
- `mintty`: `.minttyrc`
- `codex`: `.codex/AGENTS.md`

Windows では PowerShell、Linux / WSL では GNU Stow を使う。既存ファイルは展開スクリプトが削除せずに
`~/.dotfiles-backup/YYYYmmdd-HHMMSS/` へ退避する。

## 初回セットアップ

### Windows / Git Bash

Git Bash は MSYS2 そのものではないため、通常は `pacman` が使えない。
Windows 上でリンクを更新する場合は PowerShell から実行する。

```powershell
cd ~/dotfiles
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

PowerShell の symbolic link 作成には、Windows Developer Mode または管理者権限が
必要な場合がある。`.vim` ディレクトリは junction にフォールバックするが、
`.bashrc` や `.codex/AGENTS.md` などのファイルリンク作成に失敗した場合は Developer Mode を有効化するか、
管理者 PowerShell で再実行する。

### Linux / WSL

```sh
cd ~/dotfiles
bash install.sh --dry-run
bash install.sh
```

`stow` が無い場合は先に入れる。

```sh
# Debian / Ubuntu / WSL
sudo apt install stow
```

MSYS2 を別途インストールしてそのシェルを使う場合だけ、`pacman -S stow` が使える。
Git Bash では使えない。

## Vim plugins

プラグイン管理は `vim-plug`。

```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
```

よく使う操作。

```vim
:PlugInstall
:PlugUpdate
:PlugClean
```

`~/.vim/autoload/plug.vim` と `~/.vim/plugged/` は Git 管理しない。

## よく使う操作

```sh
# Windows: 全部を展開
powershell -ExecutionPolicy Bypass -File .\install.ps1

# Windows: 何が起きるか確認
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun

# Windows: Vim だけ展開
powershell -ExecutionPolicy Bypass -File .\install.ps1 vim

# Windows: Codex のグローバル AGENTS.md だけ展開
powershell -ExecutionPolicy Bypass -File .\install.ps1 codex

# Linux / WSL: 全部を展開
bash install.sh

# Linux / WSL: 何が起きるか確認
bash install.sh --dry-run

# Linux / WSL: Vim だけ展開
bash install.sh vim

# Linux / WSL: Codex のグローバル AGENTS.md だけ展開
bash install.sh codex

# Stow の状態を直接確認
stow -nv -d ~/dotfiles -t ~ bash vim mintty
```

既存ファイルを戻したい場合は、直近の `~/.dotfiles-backup/` から戻す。

## Stow と chezmoi

Linux / WSL では Stow を使う。Windows では Stow を無理に入れず、`install.ps1` で
同じリンク構造を作る。理由は、管理対象が少なく、やりたいことが symlink 展開と
バックアップに収まっているため。

chezmoi は、OS ごとのテンプレート分岐、秘密情報、マシンごとの差分が増えたら
検討する。Windows / Git Bash / WSL をまたぐだけなら、当面は `.bashrc` 内の
条件分岐、PowerShell スクリプト、Stow で十分。
