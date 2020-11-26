#!/bin/bash

# 让脚本遇到错误时停止执行，并指出错误的行数信息。
set -u

# 判断firmadyne.config 是否存在，存在的话便引用它
if [ -e ./firmadyne.config ]; then
    source ./firmadyne.config
elif [ -e ../firmadyne.config ]; then
    source ../firmadyne.config
else
    echo "Error: Could not find 'firmadyne.config'!"
    exit 1
fi

# 如果参数个数不为1，给出错误提示。
if [ $# -ne 1 ]; then
    echo "Usage: $0 <image ID>"
    exit 1
fi

# IID为脚本第一个参数
IID=${1}
# 获取工作目录
WORK_DIR=`get_scratch ${IID}`

#Nmap options to use for scanning:
NMAP_OPTS="-v -n -sSV"

# which指令会在环境变量$PATH设置的目录里查找符合条件的文件
if ! which nmap > /dev/null; then
    echo "[-] missing nmap binary"
    exit 1
fi

# 判断work dir是否为目录
if ! [ -d ${WORK_DIR} ]; then
    echo "[-] missing working directory of image ID ${IID}"
    exit 1
fi

# 判断文件是否为普通文件
if ! [ -f ${WORK_DIR}/run.sh ]; then
    echo "[-] missing start script (run.sh) of image ID ${IID}"
    exit 1
fi

TARGET_IP=`grep "GUESTIP=" "${WORK_DIR}"/run.sh | cut -d= -f2`

if [ -z "${TARGET_IP}" ]; then
    echo "[-] Found no target IP address ..."
    exit 1
fi

echo "[+] Found IP: ${TARGET_IP}"

sudo nmap ${NMAP_OPTS} "${TARGET_IP}" -oA "$WORK_DIR"nmap-basic-tcp | tee "${WORK_DIR}"nmap-basic-tcp.txt 2>&1

echo -e "\nDumped Nmap scan details of ${TARGET_IP} to $WORK_DIR"


