# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SPIDER'S LAB — .zshrc                                            ║
# ║                                                                    ║
# ║  "There is no right and wrong. There's only fun and boring."       ║
# ║  — The Plague (wrong about ethics, right about shells)             ║
# ╚══════════════════════════════════════════════════════════════════════╝


# ══════════════════════════════════════════════════════════════════════
#  PATH EXPORT — finding the lost tools
# ══════════════════════════════════════════════════════════════════════
export PATH=$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/bin
export EDITOR='nvim'
export VISUAL='nvim'


# ══════════════════════════════════════════════════════════════════════
#  DIRENV — automatic environment activation
#  When you cd into a project with .envrc, the spider's web catches it.
#  The glitch notification tells you the environment is alive.
# ══════════════════════════════════════════════════════════════════════

# Glitch visual — terminal flicker when devenv activates
_spider_glitch() {
    # Short glitch burst — looks like a CRT signal interference
    local RED='\e[31m'
    local CYAN='\e[36m'
    local DIM='\e[2m'
    local BOLD='\e[1m'
    local RESET='\e[0m'

    # Rapid scanline flicker (3 frames, ~150ms total)
    printf '\e[?5h'    # Reverse video ON
    sleep 0.05
    printf '\e[?5l'    # Reverse video OFF
    sleep 0.03
    printf '\e[?5h'
    sleep 0.02
    printf '\e[?5l'

    echo -e "${DIM}░▒▓${RESET}${RED}${BOLD} SPIDER'S LAB ${RESET}${DIM}▓▒░${RESET} ${CYAN}Environment loaded${RESET}"
}

# Hook direnv into zsh — with glitch notification
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"

    # Wrap direnv's chpwd hook to add the glitch effect
    _spider_direnv_hook() {
        local prev_env="${SPIDER_ENV:-}"
        # Let direnv do its thing (it hooks into precmd already)
        # We just watch for SPIDER_ENV appearing/disappearing
        if [[ -z "$prev_env" && -n "${SPIDER_ENV:-}" ]]; then
            _spider_glitch
        fi
    }

    # Monitor SPIDER_ENV changes after each command
    autoload -Uz add-zsh-hook
    _spider_env_monitor() {
        if [[ -n "${SPIDER_ENV:-}" && -z "${_SPIDER_NOTIFIED:-}" ]]; then
            _spider_glitch
            export _SPIDER_NOTIFIED=1
        elif [[ -z "${SPIDER_ENV:-}" && -n "${_SPIDER_NOTIFIED:-}" ]]; then
            echo -e "\e[2m░▒▓\e[0m\e[31m\e[1m SPIDER'S LAB \e[0m\e[2m▓▒░\e[0m \e[33mEnvironment deactivated\e[0m"
            unset _SPIDER_NOTIFIED
        fi
    }
    add-zsh-hook precmd _spider_env_monitor
fi


# ══════════════════════════════════════════════════════════════════════
#  PATH — spider tools
# ══════════════════════════════════════════════════════════════════════

# Nix profile (single-user install)
if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Nix daemon (multi-user install)
if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# devenv cachix (if available)
if [[ -f "$HOME/.config/nix/nix.conf" ]]; then
    export NIX_CONFIG="extra-experimental-features = nix-command flakes"
fi


# ══════════════════════════════════════════════════════════════════════
#  ALIASES — the spider's shortcuts
# ══════════════════════════════════════════════════════════════════════

alias summon='spider-summon'
alias ss='spider-status 2>/dev/null || echo "Not in a devenv shell"'
alias scan='spider-scan 2>/dev/null || echo "Not in a devenv shell"'
alias ghost='ghost-out'
alias fixme='journalctl -xe --no-pager | tail -30 | spider "Diagnose this system error. Give 3 concise bullet points: cause, fix, prevention."'


# ══════════════════════════════════════════════════════════════════════
#  SPIDER-SENSE — Local AI via Ollama
#  Pipe anything to the spider's neural network.
#  Usage:  spider "explain this code"
#          echo "SELECT * FROM users" | spider "is this safe?"
#          cat error.log | spider "diagnose this"
# ══════════════════════════════════════════════════════════════════════

spider() {
    local model="${SPIDER_MODEL:-llama3.2}"

    # Check if Ollama is available
    if ! command -v ollama &>/dev/null; then
        echo -e "\e[31m[SPIDER-SENSE]\e[0m Ollama not installed. Run: curl -fsSL https://ollama.com/install.sh | sh"
        return 1
    fi

    # Check if Ollama service is running
    if ! pgrep -x ollama &>/dev/null && ! systemctl is-active --quiet ollama 2>/dev/null; then
        echo -e "\e[31m[SPIDER-SENSE]\e[0m Ollama not running. Starting..."
        systemctl start ollama 2>/dev/null || ollama serve &>/dev/null &
        sleep 2
    fi

    local prompt=""
    local piped_input=""

    # Read piped input if available
    if [[ ! -t 0 ]]; then
        piped_input=$(cat)
    fi

    # Build the prompt
    if [[ -n "$1" ]]; then
        prompt="$*"
    else
        prompt="Analyze the following and provide a concise, technical response:"
    fi

    # Combine piped input with prompt
    if [[ -n "$piped_input" ]]; then
        prompt="${prompt}\n\n--- INPUT ---\n${piped_input}\n--- END ---"
    fi

    # System prompt with live context injection
    local system_prompt="You are Spider-Sense, a cybersecurity-focused AI assistant embedded in Spider's LAB.
Current time: $(date '+%H:%M:%S') | Date: $(date '+%A, %d %B %Y')
User: $USER@${HOST} | System: $(uname -sr) | Shell: $SHELL
Working dir: $PWD
Be concise, technical, and direct. Use terminal-friendly formatting. When analyzing code, prioritize security implications. Assume the user is an experienced developer."

    echo -e "\e[2m░▒▓\e[0m\e[36m\e[1m SPIDER-SENSE \e[0m\e[2m▓▒░\e[0m \e[2mThinking...\e[0m"
    echo ""

    # Call Ollama — inject system context as prompt prefix
    local full_prompt="[SYSTEM INSTRUCTIONS: ${system_prompt}]\n\n${prompt}"
    echo -e "${full_prompt}" | ollama run "$model" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        echo -e "\e[31m[SPIDER-SENSE]\e[0m Model '${model}' not available. Pull it: ollama pull ${model}"
        return 1
    fi
}


# ══════════════════════════════════════════════════════════════════════
#  PROMPT — the spider's face
# ══════════════════════════════════════════════════════════════════════

autoload -Uz colors && colors
setopt PROMPT_SUBST

# Git branch in prompt (if in a repo)
_spider_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    echo " %F{red}⎇ ${branch}%f"
}

# ══════════════════════════════════════════════════════════════════════
#  ANIMATED SPIDER-PULSE — cycles every second
# ══════════════════════════════════════════════════════════════════════

_spider_frames=("🕸" "🕷" "🕸" "🕷")
_spider_frame_colors=(red magenta red cyan)

_spider_pulse() {
    local idx=$(( SECONDS % 4 + 1 ))
    printf "%%F{${_spider_frame_colors[$idx]}}${_spider_frames[$idx]}%%f"
}

# Refresh prompt every second for animation
TMOUT=1
TRAPALRM() {
    zle reset-prompt 2>/dev/null
}

# ┌─[🕷]─[user@host]─[~/path] ⎇ branch
# └──╼
PROMPT='
%F{236}┌─[%f$(_spider_pulse)%F{236}]─[%f%F{red}%n%f%F{236}@%f%F{cyan}%m%f%F{236}]─[%f%F{white}%~%f%F{236}]%f$(_spider_git_branch)
%F{236}└──╼%f '

# Right prompt — timestamp
RPROMPT='%F{236}%*%f'


# ══════════════════════════════════════════════════════════════════════
#  HISTORY — remember everything. Evidence matters.
# ══════════════════════════════════════════════════════════════════════

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY


# ── End of .zshrc ──────────────────────────────────────────────────
# "Mess with the best, die like the rest." — Zero Cool
