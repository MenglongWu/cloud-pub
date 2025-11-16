#!/bin/bash

ACME_SH=/root/.acme.sh/acme.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if command -v $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 选择1：安装acme.sh
install_acme() {
    print_info "开始安装 acme.sh..."
    
    if [ -d "$HOME/.acme.sh" ]; then
        print_warning "acme.sh 已经安装"
        return 0
    fi
    
    if curl https://get.acme.sh | sh; then
        print_success "acme.sh 安装成功"
        
        # 检查并source环境文件
        if [ -f "$HOME/.acme.sh/acme.sh.env" ]; then
            source ~/.acme.sh/acme.sh.env
            print_success "已加载 acme.sh 环境变量"
        else
            print_warning "未找到 acme.sh.env 文件，尝试手动设置 PATH"
            export PATH="$HOME/.acme.sh:$PATH"
        fi
        
        return 0
    else
        print_error "acme.sh 安装失败"
        return 1
    fi
}

# 选择2：注册acme账号
register_account() {
    print_info "开始注册 acme 账号..."
    
    # 检查是否已经设置了必要的环境变量
    if [ -z "$CF_Key" ] || [ -z "$CF_Email" ]; then
        print_warning "未找到 Cloudflare API 环境变量"
        print_warning "export CF_Key=xxxxx"
        print_warning "export CF_Email=your@mail.com"
        
        # 提示输入邮箱
        read -p "请输入您的邮箱地址: " email
        
        if [ -z "$email" ]; then
            print_error "邮箱地址不能为空"
            return 1
        fi
        
        # 提示输入CF_Key
        read -p "请输入 Cloudflare API Key: " cf_key
        
        if [ -z "$cf_key" ]; then
            print_error "Cloudflare API Key 不能为空"
            return 1
        fi
        
        export CF_Email="$email"
        export CF_Key="$cf_key"
        
        print_success "环境变量已设置"
        print_warning "请注意：这些环境变量仅在当前会话中有效"
    else
        print_success "检测到已设置的环境变量:"
        echo "CF_Email: $CF_Email"
        echo "CF_Key: ${CF_Key:0:10}******"  # 只显示前10位，保护敏感信息
    fi
    
    # 注册账号
    if ${ACME_SH} --register-account -m "$CF_Email"; then
        print_success "ACME 账号注册成功"
        return 0
    else
        print_error "ACME 账号注册失败"
        return 1
    fi
}

check_CF_env() {
    # 检查环境变量
    if [ -z "$CF_Key" ] || [ -z "$CF_Email" ]; then
        print_error "未设置 Cloudflare API 环境变量，请先注册账号"
        print_warning "export CF_Key=xxxxx"
        print_warning "export CF_Email=your@mail.com"
        exit 0
    fi
    
}
# 选择3：生成域名证书
issue_certificate() {
    print_info "开始生成域名证书..."
    
    # 检查acme.sh是否可用
    if ! check_command ${ACME_SH}; then
        print_error "acme.sh 命令未找到，请先安装"
        return 1
    fi
    
    # 检查环境变量
    if [ -z "$CF_Key" ] || [ -z "$CF_Email" ]; then
        print_error "未设置 Cloudflare API 环境变量，请先注册账号"
        print_warning "export CF_Key=xxxxx"
        print_warning "export CF_Email=your@mail.com"
        return 1
    fi
    
    # 提示输入域名
    read -p "请输入要申请证书的域名: " domain
    
    if [ -z "$domain" ]; then
        print_error "域名不能为空"
        return 1
    fi
    
    # 生成证书
    print_info "正在为域名 $domain 生成证书..."
    if ${ACME_SH} --issue --dns dns_cf -d "$domain"; then
        print_success "域名证书生成成功"
        print_info "证书位置: $HOME/.acme.sh/$domain/"
        return 0
    else
        print_error "域名证书生成失败"
        return 1
    fi
}

# 自动执行所有步骤
auto_setup() {
    check_CF_env
    print_info "开始自动安装和配置..."
    
    # 步骤1：安装acme.sh
    if ! install_acme; then
        print_error "自动安装失败"
        return 1
    fi
    
    # 等待一下确保安装完成
    sleep 2
    
    # 步骤2：注册账号
    if ! register_account; then
        print_error "账号注册失败"
        return 1
    fi
    
    # 步骤3：生成证书
    if ! issue_certificate; then
        print_error "证书生成失败"
        return 1
    fi
    
    print_success "所有步骤已完成！"
}

# 显示菜单
show_menu() {
    echo
    echo "==================================="
    echo "    ACME.SH 自动化脚本"
    echo "==================================="
    echo "1. 安装 acme.sh"
    echo "2. 注册 ACME 账号"
    echo "3. 生成域名证书"
    echo "a. 自动执行所有步骤 (1->2->3)"
    echo "q. 退出"
    echo "==================================="
}

# 主函数
main() {
    # 检查curl是否安装
    if ! check_command curl; then
        print_error "请先安装 curl"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "请选择操作 [1-3/a/q]: " choice
        
        case $choice in
            1)
                install_acme
                ;;
            2)
                register_account
                ;;
            3)
                issue_certificate
                ;;
            a|A)
                auto_setup
                ;;
            q|Q)
                print_info "再见！"
                exit 0
                ;;
            *)
                print_error "无效选择，请重新输入"
                ;;
        esac
        
        echo
        read -p "按回车键继续..."
    done
}

# 运行主函数
main "$@"