function openxcode --description 'Find and open an Xcode project in this directory tree'
    set -l search_root .

    if test (count $argv) -gt 0
        if test -d "$argv[1]"
            set search_root "$argv[1]"
            set -e argv[1]
        end
    end

    set -l projects (find "$search_root" \
        -type d \
        -name "*.xcodeproj" \
        -not -path "*/.git/*" \
        -not -path "*/DerivedData/*" \
        -not -path "*/.derivedData*/*" \
        -not -path "*/Pods/*" \
        | sort)

    if test (count $projects) -eq 0
        echo "openxcode: no .xcodeproj found under '$search_root'" >&2
        return 1
    end

    set -l selected "$projects[1]"
    for project in $projects
        if test (string length -- "$project") -lt (string length -- "$selected")
            set selected "$project"
        end
    end

    if test (count $projects) -gt 1
        echo "openxcode: multiple projects found, opening nearest: $selected"
    end

    open "$selected" $argv
end
