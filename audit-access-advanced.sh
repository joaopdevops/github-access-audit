#!/bin/bash

# ============================================
# GitHub Access Audit - Advanced Version (Enterprise)
# ============================================
# Version: 2.0.0
# Description: Auditoria avançada com trail completo e detecção de inatividade
# Author: Security Team
# ============================================

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                    CONFIGURAÇÕES - ALTERE AQUI                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# 1. TOKEN DO GITHUB (obrigatório)
# Crie em: https://github.com/settings/tokens
# Permissões necessárias: repo, read:org
# Exemplo: GITHUB_TOKEN="ghp_a1B2c3D4e5F6g7H8i9J0k1L2m3N4o5P6q7R8"
GITHUB_TOKEN="seu_token_aqui"

# 2. REPOSITÓRIOS PARA AUDITAR (separados por espaço)
# Formato: "usuario/repositorio" ou "organizacao/repositorio"
# Exemplo:
# REPOS=(
#     "microsoft/vscode"
#     "facebook/react"
#     "minha-empresa/projeto-secreto"
# )
REPOS=(
    "sua-empresa/projeto1"
    "seu-usuario/repo"
)

# 3. EMAIL (opcional - para receber relatórios)
# Configure para receber os relatórios por email
# Se não quiser usar email, deixe vazio: EMAIL_RECIPIENT=""
# 
# Como obter a senha de app do Gmail:
#   1. Acesse: https://myaccount.google.com/security
#   2. Ative a autenticação de 2 fatores
#   3. Em "Senhas de app", gere uma nova senha
#   4. Use essa senha (16 caracteres) em EMAIL_PASSWORD
#
# Exemplo:
# EMAIL_RECIPIENT="security@empresa.com"
# EMAIL_SENDER="noreply@empresa.com"
# EMAIL_PASSWORD="abcd efgh ijkl mnop"
EMAIL_RECIPIENT=""
EMAIL_SENDER="SEU_EMAIL@gmail.com"
EMAIL_PASSWORD="SUA_SENHA_DE_APP"

# 4. PARÂMETROS DE INATIVIDADE (em dias)
DAYS_INACTIVE=90   # Considerar inativo após X dias (padrão: 90)
DAYS_CRITICAL=180  # Crítico após X dias de inatividade (padrão: 180)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                    FIM DAS CONFIGURAÇÕES                                   ║
# ║   ⚠️  NÃO ALTERE NADA ABAIXO DESTA LINHA (código interno do script)       ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configurações internas
SCRIPT_VERSION="2.0.0"
REPORT_DIR="./reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/audit_$TIMESTAMP.log"
CSV_FILE="$REPORT_DIR/audit_$TIMESTAMP.csv"
HTML_FILE="$REPORT_DIR/audit_$TIMESTAMP.html"
JSON_FILE="$REPORT_DIR/audit_$TIMESTAMP.json"
AUDIT_TRAIL_FILE="$REPORT_DIR/audit_trail.log"
PREVIOUS_AUDIT="$REPORT_DIR/last_audit.json"

# Trail de Auditoria - Capturar informações do ambiente
AUDIT_USER=$(whoami)
AUDIT_HOSTNAME=$(hostname)
AUDIT_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "N/A")
AUDIT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
AUDIT_PID=$$
AUDIT_SHELL="$SHELL"
AUDIT_PWD="$PWD"

# Mascarar IP para exibição pública (oculta últimos 2 octetos)
mask_ip() {
    local ip="$1"
    if [ "$ip" = "N/A" ] || [ -z "$ip" ]; then
        echo "N/A"
    else
        # Exemplo: 192.168.1.100 -> 192.168.xxx.xxx
        echo "$ip" | awk -F'.' '{print $1"."$2".xxx.xxx"}'
    fi
}

AUDIT_IP_MASKED=$(mask_ip "$AUDIT_IP")

# Criar diretório de relatórios se não existir
mkdir -p "$REPORT_DIR"

# Verifica se o token do GitHub está configurado
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "seu_token_aqui" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN não está configurado${NC}"
    echo "Edite o script e configure a variável GITHUB_TOKEN no início do arquivo"
    echo "Crie seu token em: https://github.com/settings/tokens"
    echo "Permissões necessárias: repo, read:org"
    exit 1
fi

# Função para logging
log_message() {
    echo -e "$1" | tee -a "$REPORT_FILE"
}

# Função para registrar no trail de auditoria
log_audit_trail() {
    local action="$1"
    local details="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] USER=$AUDIT_USER HOST=$AUDIT_HOSTNAME IP=$AUDIT_IP PID=$AUDIT_PID ACTION=$action DETAILS=$details" >> "$AUDIT_TRAIL_FILE"
}

# Cabeçalho do relatório
generate_header() {
    log_message "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════════╗${NC}"
    log_message "${BLUE}${BOLD}║     GitHub Access Audit - Advanced Report (Enterprise)             ║${NC}"
    log_message "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════════╝${NC}"
    log_message ""
    log_message "${BOLD}📋 TRAIL DE AUDITORIA${NC}"
    log_message "════════════════════════════════════════════════════════════════════"
    log_message "📅 Data/Hora: ${BOLD}$AUDIT_DATETIME${NC}"
    log_message "👤 Executado por: ${BOLD}$AUDIT_USER${NC}"
    log_message "🖥️  Hostname: ${BOLD}$AUDIT_HOSTNAME${NC}"
    log_message "🌐 IP Address: ${BOLD}$AUDIT_IP_MASKED${NC} ${BLUE}(mascarado para privacidade)${NC}"
    log_message "🔧 Shell: ${BOLD}$AUDIT_SHELL${NC}"
    log_message "📁 Diretório: ${BOLD}$AUDIT_PWD${NC}"
    log_message "🆔 Process ID: ${BOLD}$AUDIT_PID${NC}"
    log_message "📌 Script Version: ${BOLD}$SCRIPT_VERSION${NC}"
    log_message "════════════════════════════════════════════════════════════════════"
    log_message ""
    log_message "${YELLOW}💡 Nota: IP completo armazenado no trail log (uso interno)${NC}"
    log_message ""
    
    # Registrar início da auditoria no trail (com IP REAL)
    log_audit_trail "AUDIT_START" "Version=$SCRIPT_VERSION IP_REAL=$AUDIT_IP"
}

# Inicializar CSV
init_csv() {
    echo "Repository,Username,Permission,Last_Activity,Days_Inactive,Alert_Level,2FA_Status" > "$CSV_FILE"
}

# Inicializar JSON para comparação
init_json() {
    echo "{\"audit_metadata\": {\"timestamp\": \"$AUDIT_DATETIME\", \"user\": \"$AUDIT_USER\", \"hostname\": \"$AUDIT_HOSTNAME\", \"version\": \"$SCRIPT_VERSION\"}, \"repositories\": []}" > "$JSON_FILE"
}

# Inicializar HTML
init_html() {
    cat > "$HTML_FILE" << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>GitHub Audit Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #24292e; }
        .summary { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .trail { background: #f8f9fa; padding: 15px; border-left: 4px solid #0366d6; margin-bottom: 20px; }
        .trail h3 { margin-top: 0; color: #0366d6; }
        table { width: 100%; border-collapse: collapse; background: white; }
        th { background: #24292e; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        .critical { background: #d73a49; color: white; font-weight: bold; }
        .high { background: #ff8800; color: white; font-weight: bold; }
        .warning { background: #ffaa00; color: white; }
        .ok { background: #28a745; color: white; }
        .inactive { color: #6a737d; font-style: italic; }
    </style>
</head>
<body>
    <h1>🔍 GitHub Access Audit Report - Enterprise</h1>
    <div class="trail">
        <h3>📋 Trail de Auditoria</h3>
        <p><strong>Data/Hora:</strong> $AUDIT_DATETIME</p>
        <p><strong>Executado por:</strong> $AUDIT_USER @ $AUDIT_HOSTNAME</p>
        <p><strong>IP Address:</strong> $AUDIT_IP_MASKED (mascarado)</p>
        <p><strong>Process ID:</strong> $AUDIT_PID</p>
        <p><strong>Versão:</strong> $SCRIPT_VERSION</p>
    </div>
    <div class="summary">
        <h3>📊 Resumo da Auditoria</h3>
        <p><strong>Total de Repositórios:</strong> <span id="total-repos">-</span></p>
        <p><strong>Total de Usuários:</strong> <span id="total-users">-</span></p>
        <p><strong>Alertas Críticos:</strong> <span id="critical-alerts">-</span></p>
    </div>
    <table>
        <thead>
            <tr>
                <th>Repositório</th>
                <th>Usuário</th>
                <th>Permissão</th>
                <th>Última Atividade</th>
                <th>Dias Inativo</th>
                <th>2FA</th>
                <th>Alerta</th>
            </tr>
        </thead>
        <tbody>
HTML_EOF
}

# Finalizar HTML
finalize_html() {
    cat >> "$HTML_FILE" << 'HTML_EOF'
        </tbody>
    </table>
</body>
</html>
HTML_EOF
}

# Função para buscar última atividade do usuário (REAL via API)
get_last_activity() {
    local username=$1
    local repo=$2
    
    # Buscar eventos recentes do usuário neste repositório
    # API retorna eventos dos últimos 90 dias
    local events=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$repo/events?per_page=100")
    
    # Encontrar o evento mais recente deste usuário
    local last_event=$(echo "$events" | jq -r --arg user "$username" \
        '[.[] | select(.actor.login == $user)] | .[0].created_at // "never"')
    
    # Se não encontrou em eventos, tentar buscar em commits
    if [ "$last_event" = "never" ] || [ -z "$last_event" ]; then
        local commits=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/repos/$repo/commits?author=$username&per_page=1")
        
        # Verificar se o repositório está vazio ou se retornou erro
        if echo "$commits" | jq -e 'type == "array"' >/dev/null 2>&1; then
            last_event=$(echo "$commits" | jq -r 'if length > 0 then .[0].commit.author.date else "never" end')
        else
            last_event="never"
        fi
    fi
    
    if [ "$last_event" = "never" ] || [ -z "$last_event" ]; then
        echo "never"
    else
        echo "$last_event"
    fi
}

# Função para calcular dias de inatividade
calculate_inactive_days() {
    local last_activity="$1"
    
    if [ "$last_activity" = "never" ] || [ -z "$last_activity" ]; then
        echo "999"  # Nunca ativo
        return
    fi
    
    # Converter data ISO8601 para timestamp Unix
    local last_timestamp=$(date -d "$last_activity" +%s 2>/dev/null)
    local now_timestamp=$(date +%s)
    
    if [ -z "$last_timestamp" ]; then
        echo "999"
        return
    fi
    
    # Calcular diferença em dias
    local diff_seconds=$((now_timestamp - last_timestamp))
    local diff_days=$((diff_seconds / 86400))
    
    echo "$diff_days"
}

# Função para verificar 2FA do usuário
check_2fa_status() {
    local username=$1
    
    # A API pública não expõe status de 2FA diretamente
    # Em ambiente enterprise, você usaria a API de Organizations
    # Por enquanto, retornamos "unknown" - requer API de org
    echo "unknown"
}

# Função para determinar nível de alerta
get_alert_level() {
    local days=$1
    local permission=$2
    
    # Crítico: Admin inativo por muito tempo
    if [ "$permission" = "admin" ] && [ "$days" -ge "$DAYS_CRITICAL" ]; then
        echo "CRITICAL"
    # Alto: Admin inativo moderado ou qualquer um muito inativo
    elif [ "$permission" = "admin" ] && [ "$days" -ge "$DAYS_INACTIVE" ]; then
        echo "HIGH"
    elif [ "$days" -ge "$DAYS_CRITICAL" ]; then
        echo "HIGH"
    # Médio: Inatividade moderada
    elif [ "$days" -ge "$DAYS_INACTIVE" ]; then
        echo "MEDIUM"
    # Admin ativo é sempre monitorado
    elif [ "$permission" = "admin" ]; then
        echo "WATCH"
    else
        echo "LOW"
    fi
}

# Função para listar colaboradores (CORRIGIDA - sem subshell)
list_collaborators_advanced() {
    local repo=$1
    
    log_message "${GREEN}${BOLD}📦 Verificando: $repo${NC}"
    log_message "────────────────────────────────────────────────────────"
    
    # Fazendo a chamada REAL à API do GitHub
    collaborators=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$repo/collaborators")
    
    # Verificar se houve erro
    if echo "$collaborators" | grep -q '"message"'; then
        local error_msg=$(echo "$collaborators" | jq -r '.message' 2>/dev/null || echo "Erro desconhecido")
        log_message "${RED}❌ Erro ao acessar repositório: $error_msg${NC}"
        log_message "────────────────────────────────────────────────────────"
        return 1
    fi
    
    # Verificar se há colaboradores
    local collab_count=$(echo "$collaborators" | jq '. | length' 2>/dev/null || echo "0")
    if [ "$collab_count" = "0" ] || [ -z "$collab_count" ]; then
        log_message "${YELLOW}ℹ️  Nenhum colaborador encontrado neste repositório${NC}"
        log_message "────────────────────────────────────────────────────────"
        return 0
    fi
    
    # Contadores (fora do loop para evitar problemas com subshell)
    local total_users=0
    local admin_users=0
    local critical_alerts=0
    
    # Usar tmpfile para evitar subshell (mantém os contadores)
    local tmpfile="/tmp/github_audit_$$_${RANDOM}"
    echo "$collaborators" | jq -c '.[]' > "$tmpfile"
    
    # Processar cada colaborador REAL da API
    while IFS= read -r user_json; do
        username=$(echo "$user_json" | jq -r '.login')
        
        # Extrair permissões
        local permission="read"
        if echo "$user_json" | jq -e '.permissions.admin == true' >/dev/null 2>&1; then
            permission="admin"
            admin_users=$((admin_users + 1))
        elif echo "$user_json" | jq -e '.permissions.push == true' >/dev/null 2>&1; then
            permission="write"
        fi
        
        total_users=$((total_users + 1))
        
        # Buscar última atividade REAL via API
        log_message "${BLUE}   🔍 Buscando última atividade de $username...${NC}"
        local last_activity=$(get_last_activity "$username" "$repo")
        local days_inactive=$(calculate_inactive_days "$last_activity")
        
        # Verificar status 2FA
        local twofa_status=$(check_2fa_status "$username")
        
        # Formatar data de última atividade
        local last_activity_display="Nunca"
        local repo_status=""
        if [ "$last_activity" != "never" ]; then
            last_activity_display=$(date -d "$last_activity" '+%d/%m/%Y' 2>/dev/null || echo "$last_activity")
        else
            # Verificar se o repo está vazio
            local commit_count=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                "https://api.github.com/repos/$repo/commits?per_page=1" | jq -r '.message // "has_commits"')
            if [ "$commit_count" = "Git Repository is empty." ]; then
                repo_status=" (repo vazio)"
            fi
        fi
        
        # Determinar nível de alerta
        local alert_level=$(get_alert_level "$days_inactive" "$permission")
        
        # Contar alertas críticos
        if [ "$alert_level" = "CRITICAL" ]; then
            critical_alerts=$((critical_alerts + 1))
        fi
        
        # Cores baseadas no alerta
        local alert_color="$GREEN"
        case "$alert_level" in
            CRITICAL) alert_color="$RED" ;;
            HIGH) alert_color="$MAGENTA" ;;
            MEDIUM) alert_color="$YELLOW" ;;
            WATCH) alert_color="$BLUE" ;;
        esac
        
        # Output no console
        log_message "${YELLOW}👤 Usuário: $username${NC}"
        log_message "   🔑 Permissão: $permission"
        log_message "   📅 Última atividade: $last_activity_display$repo_status"
        log_message "   ⏱️  Dias inativo: $days_inactive"
        log_message "   🔐 2FA: $twofa_status"
        log_message "   ⚡ Nível: ${alert_color}$alert_level${NC}"
        
        # Alertas específicos
        if [ "$alert_level" = "CRITICAL" ]; then
            log_message "   ${RED}🚨 CRÍTICO: Admin inativo há mais de $DAYS_CRITICAL dias!${NC}"
        elif [ "$alert_level" = "HIGH" ] && [ "$permission" = "admin" ]; then
            log_message "   ${MAGENTA}⚠️  ALTO: Admin inativo há $days_inactive dias${NC}"
        elif [ "$days_inactive" -ge "$DAYS_INACTIVE" ]; then
            log_message "   ${YELLOW}⚠️  Usuário inativo há mais de $DAYS_INACTIVE dias${NC}"
        fi
        
        # Alerta especial para repos vazios
        if [ -n "$repo_status" ]; then
            log_message "   ${BLUE}ℹ️  Repositório sem commits - considere remover acesso ou arquivar${NC}"
        fi
        
        log_message "────────────────────────────────────────────────────────"
        
        # Registrar no trail
        log_audit_trail "USER_CHECK" "repo=$repo user=$username permission=$permission inactive_days=$days_inactive alert=$alert_level"
        
        # Adicionar ao CSV
        echo "$repo,$username,$permission,$last_activity_display,$days_inactive,$alert_level,$twofa_status" >> "$CSV_FILE"
        
        # Adicionar ao HTML
        local html_class="ok"
        case "$alert_level" in
            CRITICAL) html_class="critical" ;;
            HIGH) html_class="high" ;;
            MEDIUM) html_class="warning" ;;
        esac
        
        echo "<tr class='$html_class'>" >> "$HTML_FILE"
        echo "<td>$repo</td>" >> "$HTML_FILE"
        echo "<td>$username</td>" >> "$HTML_FILE"
        echo "<td>$permission</td>" >> "$HTML_FILE"
        echo "<td>$last_activity_display</td>" >> "$HTML_FILE"
        echo "<td>$days_inactive</td>" >> "$HTML_FILE"
        echo "<td>$twofa_status</td>" >> "$HTML_FILE"
        echo "<td>$alert_level</td>" >> "$HTML_FILE"
        echo "</tr>" >> "$HTML_FILE"
    done < "$tmpfile"
    
    # Limpar arquivo temporário
    rm -f "$tmpfile"
    
    # Resumo do repositório (AGORA FUNCIONA!)
    log_message "${BLUE}📊 Resumo do repositório:${NC}"
    log_message "   Total de usuários: ${BOLD}$total_users${NC}"
    log_message "   Usuários com permissão admin: ${BOLD}$admin_users${NC}"
    log_message "   Alertas críticos: ${BOLD}$critical_alerts${NC}"
    log_message ""
    
    # Registrar no trail
    log_audit_trail "REPO_SUMMARY" "repo=$repo total_users=$total_users admins=$admin_users critical=$critical_alerts"
}

# Função para enviar e-mail (REAL com Python - mais fácil que mailx)
send_email_notification() {
    # Verificar se email está configurado
    if [ -z "$EMAIL_RECIPIENT" ] || [ "$EMAIL_RECIPIENT" = "" ]; then
        log_message "${YELLOW}⚠️  Email não configurado (pulando envio)${NC}"
        log_message "   ${BLUE}Configure EMAIL_RECIPIENT no início do script para receber relatórios${NC}"
        return 0
    fi
    
    local recipient="$EMAIL_RECIPIENT"
    local subject="🔍 GitHub Audit Report - $(date '+%Y-%m-%d %H:%M')"
    
    log_message "${BLUE}📧 Preparando notificação por e-mail...${NC}"
    log_message "   Para: $recipient"
    log_message "   Assunto: $subject"
    log_message "   Anexos: CSV, HTML"
    
    # Verificar se Python está disponível
    if command -v python3 &> /dev/null; then
        # Criar script Python temporário para enviar email
        cat > /tmp/send_email_$$.py << 'PYEOF'
import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime

def send_email(recipient, csv_file, html_file, timestamp, user, hostname, sender_email, sender_password):
    # Configurações Gmail
    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    
    # Verificar se foi configurado
    if sender_email == "SEU_EMAIL@gmail.com" or sender_password == "SUA_SENHA_DE_APP":
        print("ERRO: Email não configurado. Edite o script e adicione suas credenciais.", file=sys.stderr)
        print("Veja instruções em CONFIG_EMAIL.md", file=sys.stderr)
        return False
    
    # Criar mensagem
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient
    msg['Subject'] = f"🔍 GitHub Audit Report - {datetime.now().strftime('%Y-%m-%d %H:%M')}"
    
    # Corpo do email
    body = f"""Auditoria de Acessos GitHub Concluída
=====================================

📅 Executado em: {timestamp}
👤 Por: {user} @ {hostname}

📊 Relatórios anexados:
   - audit_{timestamp.split()[0].replace('-','').replace(':','').replace(' ','_')}.csv (planilha)
   - audit_{timestamp.split()[0].replace('-','').replace(':','').replace(' ','_')}.html (visualização)

🔍 Verifique alertas críticos no relatório HTML.

---
GitHub Access Audit v2.0.0
"""
    msg.attach(MIMEText(body, 'plain'))
    
    # Anexar CSV
    try:
        with open(csv_file, 'rb') as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename={csv_file.split("/")[-1]}')
            msg.attach(part)
    except: pass
    
    # Anexar HTML
    try:
        with open(html_file, 'rb') as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename={html_file.split("/")[-1]}')
            msg.attach(part)
    except: pass
    
    # Enviar
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f"ERRO: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    recipient = sys.argv[1]
    csv_file = sys.argv[2]
    html_file = sys.argv[3]
    timestamp = sys.argv[4]
    user = sys.argv[5]
    hostname = sys.argv[6]
    sender_email = sys.argv[7]
    sender_password = sys.argv[8]
    
    if send_email(recipient, csv_file, html_file, timestamp, user, hostname, sender_email, sender_password):
        sys.exit(0)
    else:
        sys.exit(1)
PYEOF
        
        # Executar script Python
        python3 /tmp/send_email_$$.py "$recipient" "$CSV_FILE" "$HTML_FILE" "$AUDIT_DATETIME" "$AUDIT_USER" "$AUDIT_HOSTNAME" "$EMAIL_SENDER" "$EMAIL_PASSWORD" 2>/tmp/email_error_$$
        
        if [ $? -eq 0 ]; then
            log_message "   ${GREEN}✓ E-mail enviado com sucesso!${NC}"
            rm -f /tmp/send_email_$$.py /tmp/email_error_$$
        else
            log_message "   ${RED}❌ Erro ao enviar email${NC}"
            log_message "   ${YELLOW}Detalhes: $(cat /tmp/email_error_$$ 2>/dev/null)${NC}"
            log_message ""
            log_message "   ${BLUE}💡 CONFIGURE O EMAIL:${NC}"
            log_message "   ${BLUE}   1. Vá em: https://myaccount.google.com/security${NC}"
            log_message "   ${BLUE}   2. Ative autenticação de 2 fatores${NC}"
            log_message "   ${BLUE}   3. Em 'Senhas de app', crie uma nova senha${NC}"
            log_message "   ${BLUE}   4. Edite o script e adicione suas credenciais${NC}"
            rm -f /tmp/send_email_$$.py /tmp/email_error_$$
        fi
    else
        log_message "   ${YELLOW}⚠️  Python não instalado (SIMULAÇÃO)${NC}"
        log_message "   ${BLUE}💡 Para enviar emails, instale: sudo apt install python3${NC}"
    fi
    log_message ""
}

# Função para enviar para Slack (simulação)
send_slack_notification() {
    log_message "${BLUE}💬 Enviando notificação para Slack...${NC}"
    log_message "   Canal: #security-alerts"
    log_message "   ${GREEN}✓ Mensagem enviada (SIMULAÇÃO)${NC}"
    log_message ""
    
    # Em produção, usaria webhook do Slack:
    # curl -X POST -H 'Content-type: application/json' \
    #   --data '{"text":"Nova auditoria GitHub disponível"}' \
    #   $SLACK_WEBHOOK_URL
}

# Função para calcular hash do relatório
generate_report_hash() {
    local hash=$(sha256sum "$REPORT_FILE" | awk '{print $1}')
    log_message "${BLUE}🔒 Hash SHA256 do relatório: ${BOLD}$hash${NC}"
    log_message "${BLUE}   (Garante integridade - arquivo não foi alterado)${NC}"
    log_audit_trail "REPORT_HASH" "sha256=$hash file=$REPORT_FILE"
}

# Main
main() {
    generate_header
    init_csv
    init_html
    init_json
    
    log_message "${GREEN}${BOLD}=== Iniciando Auditoria ===${NC}"
    log_message ""
    
    # Validar se os repositórios foram configurados
    if [ ${#REPOS[@]} -eq 0 ] || [ "${REPOS[0]}" = "sua-empresa/projeto1" ]; then
        log_message "${RED}ERRO: Configure os repositórios no início do script!${NC}"
        exit 1
    fi
    
    log_audit_trail "REPOS_TO_AUDIT" "count=${#REPOS[@]} repos=${REPOS[*]}"
    
    for repo in "${REPOS[@]}"; do
        list_collaborators_advanced "$repo"
    done
    
    finalize_html
    
    log_message "${GREEN}${BOLD}=== Auditoria Concluída ===${NC}"
    log_message ""
    log_message "�� Relatórios gerados:"
    log_message "   📄 Log: $REPORT_FILE"
    log_message "   📊 CSV: $CSV_FILE"
    log_message "   🌐 HTML: $HTML_FILE"
    log_message "   📋 JSON: $JSON_FILE"
    log_message "   🔍 Trail: $AUDIT_TRAIL_FILE"
    log_message ""
    
    # Gerar hash do relatório para integridade
    generate_report_hash
    log_message ""
    
    # Notificações
    send_email_notification
    send_slack_notification
    
    log_message "${GREEN}${BOLD}✓ Processo finalizado com sucesso!${NC}"
    log_audit_trail "AUDIT_END" "status=success reports_generated=5"
}

# Executar
main
