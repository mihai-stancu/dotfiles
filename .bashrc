. /etc/bash.bashrc
. ~/.bash_aliases
. ~/.bash_completions
. ~/.bash_env

# =============================================================== #
# Settings
# --------------------------------------------------------------- #

umask 0002

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set +o noclobber
set -o ignoreeof

# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.

# Disable options:
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.

# =============================================================== #


[[ ! $- =~ "i" ]] && return

test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}";
eval "$(starship init bash)";
[[ -f ~/Dropbox/docs/motd.md ]] && shuf -n1 ~/Dropbox/docs/motd.md

# peon-ping quick controls
alias peon="bash /home/mihai-stancu/.claude/hooks/peon-ping/peon.sh"
[ -f /home/mihai-stancu/.claude/hooks/peon-ping/completions.bash ] && source /home/mihai-stancu/.claude/hooks/peon-ping/completions.bash
