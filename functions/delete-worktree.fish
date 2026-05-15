function delete-worktree
    set -l branch (git branch --show-current)

    if test -z "$branch"
        echo "Error: not on a branch" >&2
        return 1
    end

    if test "$branch" = main -o "$branch" = master
        echo "Error: refusing to delete $branch" >&2
        return 1
    end

    set -l normalized_branch (string replace -r -a '[[:space:]]+' '-' -- "$branch")
    set -l branch_suffix (string replace -a "/" "-" -- "$normalized_branch")
    set branch_suffix (string replace -r -a '[[:space:]]+' '-' -- "$branch_suffix")

    set -l worktree_path (pwd)
    set -l current_dir (basename "$worktree_path")
    set -l suffix "-$branch_suffix"

    if not string match -q -- "*$suffix" "$current_dir"
        echo "Error: current directory '$current_dir' does not match expected '-$branch_suffix' suffix" >&2
        return 1
    end

    set -l current_len (string length -- "$current_dir")
    set -l suffix_len (string length -- "$suffix")
    set -l repo_len (math "$current_len - $suffix_len")

    if test $repo_len -le 0
        echo "Error: failed to derive main repo directory from '$current_dir'" >&2
        return 1
    end

    set -l repo_name (string sub -s 1 -l "$repo_len" -- "$current_dir")
    set -l main_dir (path normalize "$worktree_path/../$repo_name")

    if not test -d "$main_dir"
        echo "Error: main directory $main_dir not found" >&2
        return 1
    end

    cd "$main_dir"; or return 1
    git worktree remove --force "$worktree_path"; or return 1
    git branch -D "$branch"; or return 1

    echo "Deleted worktree and branch $branch"
end
