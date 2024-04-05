#!/bin/bash

# 查找所有日志文件并按大小排序
echo "所有日志文件按大小排序："
echo "=================="
find / -type f -name "*.log" -exec du -h {} + | sort -rh
