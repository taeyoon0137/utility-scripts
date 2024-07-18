#!/bin/bash

# 이 스크립트는 주어진 두 개의 폴더를 병합합니다.
# 두 번째 인자의 폴더를 첫 번째 인자의 폴더로 병합합니다.
# 동일한 이름의 폴더가 있다면 재귀적으로 병합하고, 동일한 이름의 파일이 있다면
# 둘 중 하나의 이름에 (1)을 붙여서 병합합니다.
# 이동이 완료된 두 번째 폴더는 삭제됩니다.

# 예제:
# 초기 폴더 구조:
# /folder1
#     fileA.txt
#     /subfolder1
#         fileB.txt
# /folder2
#     fileA.txt
#     /subfolder1
#         fileC.txt
#     fileD.txt
#
# 결과 폴더 구조:
# /folder1
#     fileA.txt
#     fileA (1).txt
#     /subfolder1
#         fileB.txt
#         fileC.txt
#     fileD.txt

# 사용법: merge_folders.sh /path/to/folder1 /path/to/folder2

src_folder="$2"
dest_folder="$1"

if [ ! -d "$src_folder" ]; then
    echo "Source folder does not exist."
    exit 1
fi

if [ ! -d "$dest_folder" ]; then
    echo "Destination folder does not exist."
    exit 1
fi

# 고유한 파일 이름을 생성하는 함수
generate_unique_filename() {
    dir="$1"
    base_name="$2"
    ext="$3"

    if [ ! -f "$dir/$base_name.$ext" ]; then
        echo "$base_name.$ext"
        return
    fi

    count=1
    while [ -f "$dir/$base_name ($count).$ext" ]; do
        count=$((count + 1))
    done

    echo "$base_name ($count).$ext"
}

# 파일과 폴더를 이동하는 함수
move_items() {
    src="$1"
    dest="$2"

    for item in "$src"/*; do
        item_name=$(basename "$item")

        if [ -d "$item" ]; then
            # 디렉토리인 경우, 대상 폴더에 동일한 이름의 디렉토리가 있으면 재귀적으로 병합
            if [ -d "$dest/$item_name" ]; then
                echo "Merging directory: $item into $dest/$item_name"
                move_items "$item" "$dest/$item_name"
                rmdir "$item"
            else
                echo "Moving directory: $item to $dest/"
                mv "$item" "$dest/"
            fi
        elif [ -f "$item" ]; then
            # 파일인 경우, 동일한 이름의 파일이 있으면 이름을 변경하여 이동
            base_name="${item_name%.*}"
            ext="${item_name##*.}"
            if [ -f "$dest/$item_name" ]; then
                new_name=$(generate_unique_filename "$dest" "$base_name" "$ext")
                echo "File exists: $item_name, renaming and moving to $new_name"
                mv "$item" "$dest/$new_name"
            else
                echo "Moving file: $item to $dest/"
                mv "$item" "$dest/"
            fi
        fi
    done
}

# src_folder의 항목을 dest_folder로 이동
move_items "$src_folder" "$dest_folder"

# 이동이 완료된 src_folder 삭제
rmdir "$src_folder" && echo "Deleted source folder: $src_folder" || echo "Failed to delete source folder: $src_folder"

echo "Folders merged successfully."
