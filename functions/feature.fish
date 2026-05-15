function feature
    if test (count $argv) -ne 1
        echo "Usage: feature <branch-name>" >&2
        return 1
    end

    set -l branch (string trim -- "$argv[1]")
    set branch (string replace -r -a '[[:space:]]+' '-' -- "$branch")

    if test -z "$branch"
        echo "Error: branch name resolves to empty value" >&2
        return 1
    end

    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: feature must be run inside a git repository" >&2
        return 1
    end

    set -l repo_name (basename "$repo_root")
    set -l branch_suffix (string replace -a "/" "-" -- "$branch")
    set branch_suffix (string replace -r -a '[[:space:]]+' '-' -- "$branch_suffix")
    set -l worktree_path (path normalize "$repo_root/../$repo_name-$branch_suffix")

    set -l original_dir (pwd)
    branch-worktree "$branch"
    set -l worktree_status $status
    cd "$original_dir"; or return 1

    if test $worktree_status -ne 0
        return $worktree_status
    end

    if not command -q zellij
        return 0
    end

    if not set -q ZELLIJ
        return 0
    end

    zellij action new-tab --name "$branch"
    zellij action write-chars "cd '$worktree_path'"
    zellij action write 13
    zellij action new-pane --direction right
    zellij action write-chars "cd '$worktree_path'"
    zellij action write 13
    if command -q openxcode
        zellij action write-chars openxcode
        zellij action write 13
    end
end
