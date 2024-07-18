#!/bin/bash

# 이 스크립트는 주어진 경로의 폴더 내에 위치한 폴더들의 내부 파일/폴더들을 밖으로 꺼내며,
# 동일한 이름의 폴더가 있다면 재귀적으로 병합하고, 동일한 이름의 파일이 있다면
# 둘 중 하나의 이름에 (1)을 붙여서 병합합니다.

# 예제 폴더 구조
# 초기 폴더 구조:
# /target_folder
#     /folder1
#         fileA.txt
#         fileB.txt
#         /subfolder1
#             fileC.txt
#     /folder2
#         fileA.txt
#         fileD.txt
#         /subfolder1
#             fileE.txt
#     /folder3
#         fileF.txt
#
# 결과 폴더 구조:
# /target_folder
#     fileA.txt
#     fileA (1).txt
#     fileB.txt
#     fileD.txt
#     fileF.txt
#     /subfolder1
#         fileC.txt
#         fileE.txt

# 사용법: merge_folders.sh /path/to/target_folder

target_folder="$1"

if [ ! -d "$target_folder" ]; then
    echo "Target folder does not exist."
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
    src_folder="$1"
    dest_folder="$2"

    for item in "$src_folder"/*; do
        item_name=$(basename "$item")

        if [ -d "$item" ]; then
            # 디렉토리인 경우, 대상 폴더에 동일한 이름의 디렉토리가 있으면 재귀적으로 병합
            if [ -d "$dest_folder/$item_name" ]; then
                move_items "$item" "$dest_folder/$item_name"
                rmdir "$item"
            else
                mv "$item" "$dest_folder/"
            fi
        elif [ -f "$item" ]; then
            # 파일인 경우, 동일한 이름의 파일이 있으면 이름을 변경하여 이동
            base_name="${item_name%.*}"
            ext="${item_name##*.}"
            if [ -f "$dest_folder/$item_name" ]; then
                new_name=$(generate_unique_filename "$dest_folder" "$base_name" "$ext")
                mv "$item" "$dest_folder/$new_name"
            else
                mv "$item" "$dest_folder/"
            fi
        fi
    done
}

# 대상 폴더의 각 하위 폴더에서 항목을 이동
for folder in "$target_folder"/*/; do
    [ -d "$folder" ] || continue
    move_items "$folder" "$target_folder"
    rmdir "$folder"
done

echo "Folders merged successfully."
