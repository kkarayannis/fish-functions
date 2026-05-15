function branch-worktree
    if test (count $argv) -ne 1
        echo "Usage: branch-worktree <branch-name>" >&2
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
        echo "Error: not inside a git repository" >&2
        return 1
    end

    set -l repo_name (basename "$repo_root")
    set -l branch_suffix (string replace -a "/" "-" -- "$branch")
    set branch_suffix (string replace -r -a '[[:space:]]+' '-' -- "$branch_suffix")
    set -l worktree_path (path normalize "$repo_root/../$repo_name-$branch_suffix")

    if test -e "$worktree_path"
        echo "Error: worktree path already exists: $worktree_path" >&2
        return 1
    end

    set -l base_branch
    set -l remote_head (git -C "$repo_root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)

    if test -n "$remote_head"
        set base_branch (string replace -r '^origin/' '' -- "$remote_head")
    else if git -C "$repo_root" show-ref --verify --quiet refs/heads/main
        set base_branch main
    else if git -C "$repo_root" show-ref --verify --quiet refs/heads/master
        set base_branch master
    else
        set base_branch (git -C "$repo_root" branch --show-current)
    end

    if test -z "$base_branch"
        echo "Error: could not determine a base branch" >&2
        return 1
    end

    if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"
        git -C "$repo_root" worktree add "$worktree_path" "$branch"; or return 1
    else
        git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$base_branch"; or return 1
    end

    cd "$worktree_path"; or return 1

    if test -f .gitmodules
        git submodule update --init --recursive; or return 1
    end

    echo "Worktree created at $worktree_path"
end
