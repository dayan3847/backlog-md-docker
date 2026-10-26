# Bash completion for backlog-md-docker: Backlog.md's own completion, asked through the command, plus the
# command's own options. install.sh puts it in ~/.local/share/bash-completion/completions.

_backlog_md_docker() {
    local cur="${COMP_WORDS[COMP_CWORD]}" completions completion
    # Backlog.md completes from the line and the cursor and skips the first word, so the line goes as is.
    # No stdin: with a TTY, docker exec would end every line with \r.
    completions="$(backlog-md-docker completion __complete "$COMP_LINE" "$COMP_POINT" </dev/null 2>/dev/null)" || return 0
    [ "$COMP_CWORD" -eq 1 ] && completions+=$'\n--stop\n--self-update\n--install-claude\n--init'
    COMPREPLY=()
    while IFS= read -r completion; do
        [[ -n "$completion" && "$completion" == "$cur"* ]] && COMPREPLY+=("$completion")
    done <<<"$completions"
}

complete -F _backlog_md_docker backlog-md-docker
