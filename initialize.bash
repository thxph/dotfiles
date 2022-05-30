#!/usr/bin/env bash
set -e

here="$(dirname "$0")"
here="$(cd "$here"; pwd)"

(cd $here; git submodule init)
(cd $here; git submodule update)

mkln () {
    for file in "$here"/"$1"*; do
        name="$(basename "$file")"
        if [[ !( " bin config initialize.bash oh-my-zsh-custom readme.md " =~ " $name " ) ]]; then
            if [[ $2 == 't' ]]; then
                if [[ -e "$HOME/.$1$name" ]]; then
                    rm -rv "$HOME/.$1$name"
                fi
                if [[ `uname` == 'Linux' ]]; then
                    ln -sfv $file "$HOME/.$1$name"
                elif [[ `uname` == 'Darwin' ]]; then
                    ln -sfhv $file "$HOME/.$1$name"
                else
                    echo "UNSUPPORTED PLATFORM!!!!!!!!!!"
                    exit 1
                fi
            else
                if [[ -e "$HOME/.$1$name" ]]; then
                    echo "  `dirname $HOME/.$1$name`/`basename\
                    $HOME/.$1$name`"
                fi
            fi
        fi
    done
}

chkln () {
    for file in "$here/$1"*; do
        name="$(basename "$file")"
        if [[ -e "$HOME/$1$name" ]]; then
            echo "  `dirname $HOME/$1$name`/`basename\
            $HOME/$1$name`"
        fi
    done
}

confirmYn () {
    printf "$1"" (Y/n)"
    read -n 1 a
    while [[ ! $a == "Y" && ! $a == "n" ]]; do
        printf "\nPlease answer (Y/n)"
        read -n 1 a
    done
    echo ''
    if [[ $a == "Y" ]]; then
        $2
    fi
}

printf "\033[1;31;49m=== Conflicting dotfiles in $HOME:\n\033[0m"
mkln '' f
mkln 'config/' f
chkln 'bin/'
stepInitDotfiles () {
    if [[ ! -d "$HOME/.config" ]]; then
        echo "Creating ~/.config"
        mkdir "$HOME/.config"
    fi

    if [[ ! -d "$HOME/bin" ]]; then
        echo "Creating ~/bin"
        mkdir "$HOME/bin"
    fi

    mkln '' t
    mkln 'config/' t

    if [[ `uname` == 'Linux' ]]; then
        find "$here/bin" -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/bin/"
        find "$here/oh-my-zsh-custom/custom" -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/"
        find "$here/oh-my-zsh-custom/themes" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/themes/"
        find "$here/oh-my-zsh-custom/custom/plugins/" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/plugins/"
        find "$here/oh-my-zsh-custom/custom/ext/" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/"
    elif [[ `uname` == 'Darwin' ]]; then
        find "$here/bin" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/bin"
        find "$here/oh-my-zsh-custom/custom" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/"
        find "$here/oh-my-zsh-custom/themes" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/themes/"
        find "$here/oh-my-zsh-custom/custom/plugins" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/plugins/"
        find "$here/oh-my-zsh-custom/custom/ext" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/"
    fi
}
confirmYn "\033[1;32;49m=== Overwrite those files?\033[0m" stepInitDotfiles

if [[ -e "$HOME/.vim" ]] && [[ ! -e "$HOME/.config/nvim" ]]; then
    ln -sf $HOME/.vim $HOME/.config/nvim
fi

if [[ ! -d "$HOME/.vimbackup" ]]; then
    echo "Creating ~/.vimbackup"
    mkdir "$HOME/.vimbackup"
fi

if [[ ! -d "$HOME/.fonts" ]]; then
    echo "Creating ~/.fonts"
    mkdir "$HOME/.fonts"
fi

stepInstallStuff () {
    if uname -a | grep -iq linux > /dev/null && grep -iq debian /etc/*release* > /dev/null; then
        echo 'Installing stuff ...'
        sudo apt update
        sudo apt -y install aptitude python3 git zsh curl wget python3-venv python3-pip
        sudo apt -y install debhelper autotools-dev dh-autoreconf file libncurses5-dev libevent-dev pkg-config libutempter-dev build-essential
        sudo apt -y install sqlite3
        printf "\033[1;32;49m=== Type Y/y to install powerline: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
            echo 'Installing powerline'
            pip3 install --user wheel
            pip3 install --user powerline-status
            ln -sfv ${HOME}/.local/lib/python$(python3 --version | sed 's/.*\(3\..\).*/\1/')/site-packages/powerline/bindings/tmux/powerline.conf $HOME/.powerline-tmux.conf
            printf "\033[1;32;49m=== Type Y/y to install powerline patched fonts: \033[0m"
            read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
                sudo apt install -y fontconfig
                if which fc-cache; then
                    echo 'Installing powerline-patched-font'
                    git clone https://github.com/Lokaltog/powerline-fonts $HOME/powerline-font-82374846
                    find $HOME/powerline-font-82374846 -regextype posix-extended -iregex '.*\.(otf|ttf)' -print0 | xargs -0 -I % mv -v % $HOME/.fonts/
                    rm -rfv $HOME/powerline-font-82374846
                    fc-cache -vf $HOME/.fonts/
                fi
            fi
        fi
        printf "\033[1;32;49m=== Type Y/y to change default shell to zsh: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
        chsh -s `which zsh`
        fi
        printf "\033[1;32;49m=== Type Y/y to install neovim: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
            sudo apt update
            sudo apt -y install neovim
            sudo apt -y install python3-dev python3-pip
            sudo apt -y install highlight tree
            pip3 install --user neovim
            nvim +PlugInstall +qa
        fi
    elif uname -a | grep -iq linux > /dev/null && grep -iq manjaro /etc/*release* > /dev/null; then
        echo 'Installing stuff...'
        #pamac checkupdates || true
        #pamac update --no-confirm
        pamac install sqlite3 neovim tmux
        nvim +PlugInstall +qa
    elif uname -a | grep -iq darwin > /dev/null; then
        if [ -f /usr/local/bin/brew ]; then
            brew install python curl neovim wget python3 tmux zsh git reattach-to-user-namespace highlight tree
            pip3 install git+git://github.com/powerline/powerline
            pip3 install psutil
            pip3 install neovim
            if grep -iq '/usr/local/bin/zsh' /etc/shells; then
                printf "    \033[1;34;49m /usr/local/bin/zsh is already in /etc/shells\033[0m\n"
            else
                printf "    \033[1;34;49m Adding homebrew's zsh to /etc/shells\n\033[0m"
                sudo sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
            fi
            find /usr/local -iregex '.*tmux/powerline.conf' 2> /dev/null -print0 | xargs -0 -I % ln -sfv % $HOME/.powerline-tmux.conf
        fi
    fi
}
confirmYn "\033[1;32;49m=== Install zsh, python and powerline:\033[0m" stepInstallStuff

#echo $PWD

stepInstallFzf () {
    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        (cd ~/.fzf; git pull origin master)
    fi
    ~/.fzf/install --all --no-update-rc
}
confirmYn "\033[1;32;49m=== Install/update fzf:\033[0m" stepInstallFzf


stepConfigGitName () {
    while [[ x${git_global_name} == 'x' ]]; do
        read -rp "gitconfig global name: " git_global_name
    done
    while [[ x${git_global_email} == 'x' ]]; do
        read -rp "gitconfig global email: " git_global_email
    done
    cat <<EOF > $HOME/.gitconfigp
[user]
	name = ${git_global_name}
	email = ${git_global_email}
[core]
	excludesfile = $HOME/.gitignore
EOF
}
if [ -f $HOME/.gitconfigp ]; then
    confirmYn "\033[1;32;49m=== Config local git name/email:\033[0m" stepConfigGitName
else
    stepConfigGitName
fi
