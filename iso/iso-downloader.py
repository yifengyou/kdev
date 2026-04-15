#!/usr/bin/python3

import os
import re
import subprocess
import sys
import platform
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

# ================= 配置区域 =================
MAX_WORKERS = 5  # 同时下载的最大任务数
SCRIPT_NAME = "build-vm.sh"

# 正则：提取下载链接 (支持 ISOURL=xxx 或 DOWNLOAD_URL=xxx 等)
URL_REGEX = r'(?:ISOURL|DOWNLOAD_URL|IMAGE_URL)\s*=\s*["\']?([^"\'\s]+)["\']?'
# 正则：提取架构变量 (支持 ARCH=xxx 或 TARGET_ARCH=xxx 等)
ARCH_REGEX = r'(?:ARCH|TARGET_ARCH|PLATFORM)\s*=\s*["\']?([^"\'\s]+)["\']?'


# ===========================================

def get_host_arch():
    """获取当前机器的架构"""
    machine = platform.machine()
    # 标准化架构名称映射 (处理常见的别名)
    arch_map = {
        'x86_64': 'x86_64',
        'AMD64': 'x86_64',
        'aarch64': 'aarch64',
        'arm64': 'aarch64',
        'armv7l': 'armv7',
    }
    return arch_map.get(machine, machine)


def analyze_script(script_path, host_arch):
    """
    分析脚本：提取 URL 和 目标架构
    返回: (url, target_arch, is_compatible)
    """
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()

            # 1. 提取 URL
            url_match = re.search(URL_REGEX, content)
            if not url_match:
                return None, None, False

            url = url_match.group(1).strip()

            # 2. 提取脚本中声明的目标架构 (如果有的话)
            arch_match = re.search(ARCH_REGEX, content)
            target_arch = None
            if arch_match:
                target_arch = arch_match.group(1).strip()
                # 简单标准化
                if target_arch in ['arm64']: target_arch = 'aarch64'
                if target_arch in ['AMD64', 'x64']: target_arch = 'x86_64'

            # 3. 兼容性判断逻辑
            # 如果脚本中没有指定架构，或者架构包含在文件名中，我们假设它是兼容的
            # 或者你可以选择通过 URL 字符串来判断 (例如 url 中包含 'aarch64' 但本机是 'x86_64')

            is_compatible = True
            skip_reason = ""

            # 策略 A: 优先检查脚本内显式声明的 ARCH 变量
            if target_arch:
                if target_arch != host_arch:
                    is_compatible = False
                    skip_reason = f"架构不匹配 (脚本声明: {target_arch}, 本机: {host_arch})"

            # 策略 B: 如果脚本没声明 ARCH，尝试从 URL 链接字符串中推断 (可选增强)
            elif not target_arch:
                # 检查 URL 中是否包含明显的互斥架构关键词
                if host_arch == 'x86_64' and ('aarch64' in url or 'arm64' in url):
                    is_compatible = False
                    skip_reason = "URL 包含互斥架构关键词"
                elif host_arch == 'aarch64' and ('x86_64' in url or 'amd64' in url):
                    is_compatible = False
                    skip_reason = "URL 包含互斥架构关键词"

            return url, target_arch, is_compatible, skip_reason

    except Exception as e:
        print(f"❌ 读取 {script_path} 失败: {e}")
        return None, None, False, str(e)


def download_iso(url, target_dir):
    """调用 aria2c 进行下载"""
    # 确保目标目录存在
    os.makedirs(target_dir, exist_ok=True)

    # 构建 aria2c 命令
    cmd = [
        "aria2c",
        "-c",  # 断点续传
        "-x", "4",  # 每个文件最大连接数
        "-d", target_dir,  # 指定下载目录
        "--quiet=true",  # 减少输出干扰 (可选)
        url
    ]

    # 显示简短的下载提示
    print(f"🚀 正在下载: {os.path.basename(url)} ...", end="", flush=True)

    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("✅ 完成")
        return True
    except subprocess.CalledProcessError as e:
        print("❌ 失败")
        # print(f"   错误: {e.stderr.decode()}") # 调试时可开启
        return False


def main():
    # 1. 获取本机架构
    host_arch = get_host_arch()
    print(f"💻 当前机器架构: \033[1;33m{host_arch}\033[0m")
    print("-" * 40)

    # 2. 查找所有脚本
    scripts = []
    for root, dirs, files in os.walk("."):
        if SCRIPT_NAME in files:
            scripts.append(os.path.join(root, SCRIPT_NAME))

    if not scripts:
        print("未找到 build-vm.sh，退出。")
        sys.exit(0)

    # 3. 筛选任务
    tasks = []
    skipped_count = 0

    for script_path in scripts:
        result = analyze_script(script_path, host_arch)
        url, target_arch, is_compatible, reason = result

        if not url: continue

        target_dir = os.path.dirname(os.path.abspath(script_path))

        if is_compatible:
            tasks.append((url, target_dir))
        else:
            skipped_count += 1
            # 使用黄色高亮显示跳过信息
            print(f"⏭️  跳过: {script_path} ({reason})")

    print("-" * 40)
    print(f"📋 待下载: {len(tasks)} 个, 已跳过: {skipped_count} 个")

    if not tasks:
        print("没有需要下载的任务。")
        return

    # 4. 并发执行
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_task = {
            executor.submit(download_iso, url, dir_path): url
            for url, dir_path in tasks
        }

        for future in as_completed(future_to_task):
            # 这里可以处理最终的结果统计，目前 download_iso 内部已处理打印
            pass


if __name__ == "__main__":
    main()
