#!/bin/bash
prefix=""    # 前缀
base="test"  # 默认字符串
suffix=""    # 后缀
upper=off    # 是否大写
# 解析命令行参数
while [ -n "$1" ]
do
    case "$1" in
        -a) suffix="$2"
            shift ;;
        -b) prefix="$2"
            shift ;;
        -s) base="$2"
            shift ;;
        -u) upper=on ;;
         *) echo "$1 is not an option"
            exit 1 ;;  # 发现未知参数，直接退出
    esac
    shift
done
# 添加前缀和后缀
output="${prefix:+${prefix}_}${base}${suffix:+_${suffix}}"

# 判断是否要全大写输出
if [ $upper = on ]
then
    #output=${output^^} #bash4.0语法
    typeset -u myUpper
        myUpper=$output
        echo $myUpper
fi
# 输出结果
echo "$output"
# ./paras.sh -a after
# ./paras.sh -s hello -b befor
# ./paras.sh -s hello -u -a after -b befor

