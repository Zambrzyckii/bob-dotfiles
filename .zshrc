autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

export DOTNET_SYSTEM_NET_DISABLEIPV6=1
alias cat='bat'
alias grep='grep --color=auto'
alias update='yay -Syu'
alias backup='/home/bob/.config/scripts/backup.sh'
alias clean='sudo pacman -Sc && yay -Sc'
alias battery='sudo powertop'
alias ls="eza --color=always --icons=always --group-directories-first"
alias ll="eza -al --color=always --icons=always --group-directories-first --git"

msg () {
    local message="${*:-None}"
    notify-send -a "Terminal" "Terminal" "$message"
}

fire() {
    clear
    if command -v cacafire &> /dev/null; then
        CACA_DRIVER=ncurses cacafire
    elif command -v aafire &> /dev/null; then
        aafire -driver curses
    fi
}

bonsai() {
    clear
    LC_NUMERIC=C cbonsai -l -t 10
}

\cat ~/.cache/wal/sequences

eval "$(starship init zsh)"

ask() {
    if [ $# -eq 0 ]; then
        aichat
    else
        aichat "$*"
    fi
}

execute() {
    if [ $# -eq 0 ]; then
        echo "Usage: execute <task description>"
    else
        aichat -e "$*"
    fi
}

analyze() {
    if [ $# -eq 0 ]; then
        echo "Usage: analyze <filename>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found."
        return 1
    fi

    cat "$1" | aichat "Analyze this code for bugs, security issues, and optimizations. Provide a technical summary. Respond in Polish."
}

review() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not a git repository."
        return 1
    fi

    local changes=$(git diff)
    if [ -z "$changes" ]; then
        changes=$(git diff --cached)
    fi

    if [ -z "$changes" ]; then
        echo "No uncommitted changes found."
        return 1
    fi

    echo "$changes" | aichat "Review these git changes. Identify potential issues and suggest a professional commit message in Conventional Commits format. Respond in Polish."
}
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
explain() {
    if [ $# -eq 0 ]; then
        echo "Usage: explain <command or error message>"
        return 1
    fi

    aichat "Explain the following terminal command or error message in simple terms: '$*'. Respond in Polish."
}
killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port_number>"
        return 1
    fi

    local pid=$(lsof -ti tcp:"$1")
    if [ -z "$pid" ]; then
        echo "No process listening on port $1"
    else
        kill -9 $pid
    fi
}
fastfetch() {
    local random_logo=$(find /home/bob/bobby-dotfiles/FastFetchLogos -maxdepth 1 -type f -name "*.png" | shuf -n 1)
    
    command fastfetch --logo "$random_logo" "$@"
}

CallClearHistory() {
    echo -n > "$HISTFILE"
    local old_histsize=$HISTSIZE
    HISTSIZE=0
    HISTSIZE=$old_histsize
    command rm -rf ~/.cache/cliphist/db
}
cava() {

    cat ~/.config/cava/config ~/.cache/wal/colors-cava > /tmp/cava_pywal_config 2>/dev/null

    command cava -p /tmp/cava_pywal_config
    \cat ~/.cache/wal/sequences
}


BanApp() {
    if [ -z "$1" ]; then echo "Użycie: BanApp <fraza>"; return 1; fi
    
    # Przeszukujemy oba foldery naraz
    local dirs=("/usr/share/applications" "$HOME/.local/share/applications")
    
    for dir in "${dirs[@]}"; do
        [ -d "$dir" ] || continue
        grep -lri "Name=.*$1" "$dir"/*.desktop 2>/dev/null | while read -r file; do
            sudo sed -i '/^NoDisplay=true/d' "$file" 2>/dev/null || sed -i '/^NoDisplay=true/d' "$file"
            sudo sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$file" 2>/dev/null || sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
            echo "Blocked: $(basename "$file") in $dir"
        done
    done

    sudo update-desktop-database /usr/share/applications 2>/dev/null
    update-desktop-database ~/.local/share/applications 2>/dev/null
    killall quickshell >/dev/null 2>&1
    ( ~/.local/bin/start-quickshell.sh & ) >/dev/null 2>&1
    sleep 0.5 && disown 2>/dev/null
    echo "Menu refreshed."
}

AllowApp() {
    if [ -z "$1" ]; then echo "Użycie: AllowApp <fraza>"; return 1; fi
    
    local dirs=("/usr/share/applications" "$HOME/.local/share/applications")
    
    for dir in "${dirs[@]}"; do
        [ -d "$dir" ] || continue
        grep -lri "Name=.*$1" "$dir"/*.desktop 2>/dev/null | while read -r file; do
            sudo sed -i '/^NoDisplay=true/d' "$file" 2>/dev/null || sed -i '/^NoDisplay=true/d' "$file"
            echo "Unlocked: $(basename "$file") in $dir"
        done
    done

    sudo update-desktop-database /usr/share/applications 2>/dev/null
    update-desktop-database ~/.local/share/applications 2>/dev/null
    killall quickshell >/dev/null 2>&1
    ( ~/.local/bin/start-quickshell.sh & ) >/dev/null 2>&1
    sleep 0.5 && disown 2>/dev/null
    echo " Menu refreshed"
}

GitSync() {
	if [ -z "$1" ]; then
	   echo "Add project name"
	   return 1
	fi

    if [ ! -d "$1" ]; then
        mkdir "$1"
    fi

    cd "$1" || return 1
    
	git init
	touch README.md
	git add .
	git commit -m "New Project"
	git branch -M master

	gh repo create "$1" --private --source=. --remote=origin --push

	echo "Done, project $1 created"
}

GitUp() {
	if [ -z "$1" ]; then
	   echo "Add commit message"
	   return 1
	fi

	git add .
	git commit -m "$1"
	git push
	echo "Commit done" 
	
}
