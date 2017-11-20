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

printf "\033[1;31;49m=== Conflicting dotfiles in $HOME:\n\033[0m"
mkln '' f
mkln 'config/' f
chkln 'bin/'
printf "\033[1;32;49m=== Type Y/y to overwrite those files: \033[0m"
read -n 1 c
echo ''
if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
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
    elif [[ `uname` == 'Darwin' ]]; then
        find "$here/bin" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/bin"
        find "$here/oh-my-zsh-custom/custom" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/"
        find "$here/oh-my-zsh-custom/themes" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/themes/"
        find "$here/oh-my-zsh-custom/custom/plugins" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/plugins/"
    fi
fi

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

printf "\033[1;32;49m=== Type Y/y to install zsh, tmux, python and powerline: \033[0m"
read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
    if uname -a | grep -iq linux > /dev/null && grep -iq debian /etc/*release* > /dev/null; then
        echo 'Installing stuff ...'
        sudo apt-get update
        sudo apt-get install aptitude
        sudo apt-get -y install python-pip git zsh
        sudo apt-get -y install debhelper autotools-dev dh-autoreconf file libncurses5-dev libevent-dev pkg-config libutempter-dev build-essential
        printf "\033[1;32;49m=== Type Y/y to install powerline: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
            echo 'Installing powerline'
            pip install --user git+git://github.com/powerline/powerline
            find $HOME -iregex '.*tmux/powerline.conf' 2> /dev/null -print0 | xargs -0 -I % ln -sfv % $HOME/.powerline-tmux.conf
            printf "\033[1;32;49m=== Type Y/y to install powerline patched fonts: \033[0m"
            read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
                if which fc-cache; then
                    echo 'Installing powerline-patched-font'
                    git clone https://github.com/Lokaltog/powerline-fonts $HOME/powerline-font-82374846
                    find $HOME/powerline-font-82374846 -regextype posix-extended -iregex '.*\.(otf|ttf)' -print0 | xargs -0 -I % mv -v % $HOME/.fonts/
                    rm -rfv $HOME/powerline-font-82374846
                    fc-cache -vf $HOME/.fonts/
                fi
            fi
        fi
        chsh -s `which zsh`
        TMUX_VERSION=2.6
        echo "Checking tmux version..."
        if [[ ! -f /usr/local/bin/tmux ]] || ! /usr/local/bin/tmux -V | grep $TMUX_VERSION; then
            echo "Installing tmux $TMUX_VERSION"
            cpwd=$PWD
            mkdir -p "$HOME/src/$USER"
            cd "$HOME/src/$USER"
            if [[ ! -d tmux ]]; then
                git clone https://github.com/tmux/tmux.git
                cd tmux
            else
                cd tmux
                git fetch --all
            fi
            git checkout $TMUX_VERSION
            make clean || echo nothing to clean
            sh autogen.sh && ./configure && make && sudo make install
            cd $cpwd
        fi
        printf "\033[1;32;49m=== Type Y/y to install alacritty: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
            cpwd=$PWD
            mkdir -p "$HOME/src/$USER"
            cd "$HOME/src/$USER"
            if ! which rustup; then
                curl https://sh.rustup.rs -sSf | sh
            fi
            if [[ ! -d alacritty ]]; then
                git clone https://github.com/jwilm/alacritty.git
                cd alacritty
            else
                cd alacritty
                git pull origin master
            fi
            export PATH=$PATH:$HOME/.cargo/bin
            rustup override set stable
            rustup update stable
            sudo apt-get -y install cmake libfreetype6-dev libfontconfig1-dev xclip
            cargo build --release
            sudo cp target/release/alacritty /usr/local/bin
            mkdir -p $HOME/.local/share/applications
            cp Alacritty.desktop ~/.local/share/applications
            cd $cpwd
        fi
        printf "\033[1;32;49m=== Type Y/y to install neovim: \033[0m"
        read -n 1 c; echo ''; if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
            sudo add-apt-repository ppa:neovim-ppa/stable
            sudo apt-get update
            sudo apt-get -y install neovim
            sudo apt-get -y install python-dev python-pip python3-dev python3-pip
            pip install --user neovim
            pip3 install --user neovim
        fi
    elif uname -a | grep -iq darwin > /dev/null; then
        if [ -f /usr/local/bin/brew ]; then
            brew install python curl wget python3 tmux zsh git reattach-to-user-namespace
            pip3 install git+git://github.com/powerline/powerline
            pip3 install psutil
            if grep -iq '/usr/local/bin/zsh' /etc/shells; then

                printf "    \033[1;34;49m /usr/local/bin/zsh is already in /etc/shells\033[0m\n"
            else
                printf "    \033[1;34;49m Adding homebrew's zsh to /etc/shells\n\033[0m"
                sudo sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
            fi
            find /usr/local -iregex '.*tmux/powerline.conf' 2> /dev/null -print0 | xargs -0 -I % ln -sfv % $HOME/.powerline-tmux.conf
        fi
    fi
fi

echo $PWD

for d in dein ndein; do
    if [[ ! -d "$HOME/.cache/$d" ]]; then
        echo "Creating ~/.cache/$d"
        mkdir -p ~/.cache/$d
        curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > /tmp/installer.sh
        sh /tmp/installer.sh ~/.cache/$d
    fi
done

printf "\033[1;32;49m=== Type Y/y to install/update fzf: \033[0m"
read -n 1 c; echo ''
if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
    sudo apt-get -y install highlight tree
    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        (cd ~/.fzf; git pull origin master)
    fi
    ~/.fzf/install --all
fi

