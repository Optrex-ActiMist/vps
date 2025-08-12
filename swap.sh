#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本（使用 sudo）。"
  exit 1
fi

# 第一步：检查当前 swap
echo "检查当前 swap 情况..."
swapon --show
if [ $? -ne 0 ]; then
  echo "未检测到当前启用的 swap 文件。"
fi
read -p "按 Enter 继续..." dummy

# 询问用户目标 swap 大小
echo "请输入您想将 swap 扩展到的大小（单位：GB，例如 4 表示 4GB。建议为内存的2倍）："
read target_size
if ! [[ "$target_size" =~ ^[0-9]+$ ]] || [ "$target_size" -le 0 ]; then
  echo "输入无效，请输入一个正整数。"
  exit 1
fi

# 二次确认
echo "您输入的目标 swap 大小为 ${target_size}GB。"
read -p "请再次确认是否正确？(y/n): " confirm_size
if [ "$confirm_size" != "y" ]; then
  echo "操作已取消。"
  exit 0
fi

# 提示用户确认操作
echo "此脚本将替换现有的 swap 文件为 ${target_size}GB。"
echo "当前 swap 文件将被禁用并删除，请确保系统有足够磁盘空间。"
read -p "是否继续？(y/n): " confirm
if [ "$confirm" != "y" ]; then
  echo "操作已取消。"
  exit 0
fi

# 第二步：禁用当前 swap
echo "正在禁用当前 swap 文件..."
swapoff /swapfile 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Swap 已禁用。"
else
  echo "没有活动的 swap 文件或禁用失败，继续进行下一步。"
fi
read -p "按 Enter 继续..." dummy

# 第三步：删除旧 swap 文件
echo "正在删除旧的 swap 文件（如果存在）..."
rm -f /swapfile
if [ $? -eq 0 ]; then
  echo "旧 swap 文件已删除（或不存在）。"
else
  echo "删除失败，请检查权限或磁盘状态。"
  exit 1
fi
read -p "按 Enter 继续..." dummy

# 第四步：创建新的 swap 文件
echo "正在创建新的 ${target_size}GB swap 文件..."
fallocate -l "${target_size}G" /swapfile || {
  echo "fallocate 失败，尝试使用 dd 创建..."
  dd if=/dev/zero of=/swapfile bs=1M count=$((target_size * 1024))
}
if [ $? -eq 0 ]; then
  echo "新 swap 文件创建成功。"
else
  echo "创建失败，请检查磁盘空间。"
  exit 1
fi
read -p "按 Enter 继续..." dummy

# 第五步：设置权限
echo "设置 swap 文件权限..."
chmod 600 /swapfile
if [ $? -eq 0 ]; then
  echo "权限设置完成。"
else
  echo "权限设置失败。"
  exit 1
fi
read -p "按 Enter 继续..." dummy

# 第六步：格式化为 swap
echo "正在格式化 swap 文件..."
mkswap /swapfile
if [ $? -eq 0 ]; then
  echo "格式化完成。"
else
  echo "格式化失败。"
  exit 1
fi
read -p "按 Enter 继续..." dummy

# 第七步：启用新的 swap
echo "正在启用新的 swap 文件..."
swapon /swapfile
if [ $? -eq 0 ]; then
  echo "Swap 已启用，检查当前状态："
  swapon --show
else
  echo "启用失败，请检查错误。"
  exit 1
fi
read -p "请确认 swap 大小为 ${target_size}G，按 Enter 继续..." dummy

# 第八步：验证 /etc/fstab
echo "检查 /etc/fstab 中的 swap 配置..."
grep "/swapfile" /etc/fstab
if grep -q "/swapfile" /etc/fstab; then
  echo "当前 /etc/fstab 已包含 swap 配置，无需修改。"
else
  echo "未找到 swap 配置，正在添加..."
  echo "/swapfile    none    swap    sw    0    0" >> /etc/fstab
  echo "已添加到 /etc/fstab。"
fi

# 最后确认
echo "Swap 扩展完成！当前内存和 swap 状态："
free -h
echo "操作已完成，请检查以上输出确认 swap 大小为 ${target_size}GB。"
