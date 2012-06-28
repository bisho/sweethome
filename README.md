# Sweet Home

This repo tries to make easy to install all the custom tweaks I want on my home directory when arriving to a new computer. It's based on the idea of other "dotfiles" projects.

Feel free to use it, customize, or whatever.

## What includes
Includes:

 - bin folder in path
 - Nice bash configuration
 - Nice git tweaks
 - spf13-vim (installs a ton of plugins)
 - My vim tweaks
 - awesome window manager and the xsession file to launch it

## Installation
Just branch it, tweak it, and execute

    $ ./init.sh

That will symlink all the files into your home directory, keeping a backup just in case.

Example (assuming the repo is cloned on ".sweethome"):

    ** Initializing home directory with 'sweethome' repo in /home/bisho/.sweethome
    
    The following files will be REPLACED by symbolic links to this
    sweethome repo:
    
      - ~/.bash_logout -> ~/.sweethome/dotfiles/bash_logout
      - ~/.bashrc -> ~/.sweethome/dotfiles/bashrc
      - ~/.config/awesome -> ~/.sweethome/dotfiles/config.awesome
      - ~/.profile -> ~/.sweethome/dotfiles/profile
      - ~/.screenrc -> ~/.sweethome/dotfiles/screenrc
      - ~/.vim -> ~/.sweethome/dotfiles/vim
      - ~/.vimrc -> ~/.sweethome/dotfiles/vimrc
      - ~/.vimrc.bundles.local -> ~/.sweethome/dotfiles/vimrc.bundles.local
      - ~/.vimrc.local -> ~/.sweethome/dotfiles/vimrc.local
      - ~/.xsession -> ~/.sweethome/dotfiles/xsession
      - ~/.gnupg -> ~/.sweethome/private/dotfiles/gnupg
      - ~/.ssh -> ~/.sweethome/private/dotfiles/ssh
      - ~/bin -> ~/.sweethome/bin
      - ~/conf -> ~/.sweethome/conf
      - ~/.private -> ~/.sweethome/private
    
    Note: A Backup of the original files will be created.
    Do you want to continue?
    (y/n): y
    
    * Creating backup...
      You can find old files in /home/bisho/sweet7MyGHe.tgz
    
    * Linking files...
      - Linking ~/.bash_logout -> ~/.sweethome/dotfiles/bash_logout
      - Linking ~/.bashrc -> ~/.sweethome/dotfiles/bashrc
      - Linking ~/.config/awesome -> ~/.sweethome/dotfiles/config.awesome
      - Linking ~/.profile -> ~/.sweethome/dotfiles/profile
      - Linking ~/.screenrc -> ~/.sweethome/dotfiles/screenrc
      - Linking ~/.vim -> ~/.sweethome/dotfiles/vim
      - Linking ~/.vimrc -> ~/.sweethome/dotfiles/vimrc
      - Linking ~/.vimrc.bundles.local -> ~/.sweethome/dotfiles/vimrc.bundles.local
      - Linking ~/.vimrc.local -> ~/.sweethome/dotfiles/vimrc.local
      - Linking ~/.xsession -> ~/.sweethome/dotfiles/xsession
      - Linking ~/.gnupg -> ~/.sweethome/private/dotfiles/gnupg
      - Linking ~/.ssh -> ~/.sweethome/private/dotfiles/ssh
      - Linking ~/bin -> ~/.sweethome/bin
      - Linking ~/conf -> ~/.sweethome/conf
      - Linking ~/.private -> ~/.sweethome/private
    Done!
    
    Now we will launch vim bundle installation.
    Press ENTER to continue...
    [...here vim launches installing plugins, wait and relax...]


Enjoy!

