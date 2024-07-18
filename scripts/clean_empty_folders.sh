#!/bin/bash

# 이 스크립트는 주어진 경로의 폴더를 재귀적으로 탐색하며 빈 폴더를 모두 삭제합니다.
# 자식 폴더가 모두 비워져 삭제된 후, 자신도 비어있다면 자신 또한 삭제됩니다.

# 예제 폴더 구조:
# 초기 폴더 구조:
# /target_folder
#     /folder1
#         (empty)
#     /folder2
#         /subfolder1
#             (empty)
#         /subfolder2
#             file.txt
#     /folder3
#         /subfolder3
#             /subfolder4
#                 (empty)
#
# 결과 폴더 구조:
# /target_folder
#     /folder2
#         /subfolder2
#             file.txt

# 사용법: clean_empty_folders.sh /path/to/target_folder

target_folder="$1"

if [ ! -d "$target_folder" ]; then
    echo "Target folder does not exist."
    exit 1
fi

# 빈 폴더를 재귀적으로 삭제하는 함수
delete_empty_folders() {
    local folder="$1"
    local is_empty=1

    # 하위 폴더를 먼저 탐색
    for subfolder in "$folder"/*/; do
        [ -d "$subfolder" ] || continue
        delete_empty_folders "$subfolder"
    done

    # 현재 폴더가 비어 있는지 확인
    if [ "$(ls -A "$folder")" ]; then
        is_empty=0
    fi

    # 현재 폴더가 비어 있으면 삭제
    if [ $is_empty -eq 1 ]; then
        rmdir "$folder"
        echo "Deleted empty folder: $folder"
    fi
}

# 대상 폴더에서 빈 폴더 삭제 시작
delete_empty_folders "$target_folder"

echo "Empty folders deleted successfully."
