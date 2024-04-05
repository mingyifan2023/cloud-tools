#!/bin/bash
# 每月清空日志的计划任务 0 8 1 * * /bin/bash /path/to/your/script.sh

# 找到所有大于 1KB 的日志文件并清空
echo "清空超过 1KB 的日志文件："
echo "=================="

# 查找大于 5KB 的日志文件，并保存到变量 logs 中
logs=$(find / -type f -name "*.log" -size +1k)

# 遍历 logs 中的每个日志文件，并使用 cat /dev/null 来清空它们
for log in $logs; do
    echo "clean logs: $log"
    cat /dev/null > "$log"
done
