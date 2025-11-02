# 🔍 GitHub Access Audit - Script Avançado de Auditoria

## 📋 Índice
- [Sobre o Projeto](#sobre-o-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Como Usar](#como-usar)
- [Relatórios Gerados](#relatórios-gerados)
- [Automatização com Cron](#automatização-com-cron)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Sobre o Projeto

Este script realiza **auditoria automática de acessos** em repositórios GitHub, gerando relatórios detalhados sobre:
- 👥 Usuários com acesso aos repositórios
- 🔑 Níveis de permissão (admin, write, read)
- ⏱️ Última atividade real (via commits e eventos)
- 📅 Dias de inatividade
- 🔐 Status 2FA (quando disponível)
- ⚠️ Alertas de segurança inteligentes
- 📊 Estatísticas e métricas detalhadas
- 🔒 Trail de auditoria completo
- 🔐 Hash SHA256 para garantir integridade

### Por que usar?
- **Segurança**: Identifica acessos indevidos, admins inativos ou repositórios vazios
- **Compliance**: Mantém histórico de auditorias com trail completo
- **Automação**: Economiza tempo em tarefas repetitivas
- **Visibilidade**: Relatórios em múltiplos formatos (LOG, CSV, HTML, JSON)
- **Integridade**: Hash SHA256 garante que relatórios não foram alterados
- **Privacidade**: IP mascarado em relatórios públicos

### ✨ Funcionalidades Avançadas (v2.0.0)

#### 🔍 Detecção de Inatividade Real
- Busca última atividade via API de Events (últimos 90 dias)
- Se não encontrar, busca em Commits (histórico completo)
- Calcula dias reais de inatividade
- Detecta repositórios vazios

#### 🚨 Sistema de Alertas Inteligente
- **CRITICAL**: Admin inativo há mais de 180 dias
- **HIGH**: Admin inativo 90+ dias ou usuário inativo 180+ dias
- **MEDIUM**: Usuário inativo há mais de 90 dias
- **WATCH**: Admin ativo (monitoramento contínuo)
- **LOW**: Usuário ativo normal

#### 📋 Trail de Auditoria Completo
- Quem executou a auditoria
- Quando foi executada (data/hora/timezone)
- Onde foi executada (hostname, IP, diretório)
- Como foi executada (shell, PID, versão do script)
- Hash SHA256 do relatório (integridade)
- Log persistente de todas as ações

#### 🔒 Segurança e Privacidade
- IP mascarado em console e HTML (ex: `192.168.xxx.xxx`)
- IP real armazenado apenas no trail log (uso forense)
- Hash SHA256 para validar integridade dos relatórios
- Detecção de repositórios vazios com alertas

#### 📊 Múltiplos Formatos de Relatório
- **LOG**: Visualização colorida no terminal
- **CSV**: Importação em Excel/Google Sheets
- **HTML**: Relatório visual com cores por criticidade
- **JSON**: Dados estruturados para comparações futuras
- **Trail Log**: Histórico completo de auditorias

---

## 📦 Pré-requisitos

Antes de começar, você precisa ter instalado:

### 1. Sistema Operacional
- Linux (Ubuntu, Debian, CentOS, etc.)
- macOS
- Windows com WSL2

### 2. Ferramentas necessárias
```bash
# Git (para clonar o repositório)
git --version

# curl (para fazer chamadas à API)
curl --version

# jq (para processar JSON)
jq --version
```

### 3. Instalar ferramentas (se necessário)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git curl jq
```

**CentOS/RHEL:**
```bash
sudo yum install -y git curl jq
```

**macOS:**
```bash
brew install git curl jq
```

---

## 🚀 Instalação

### Passo 1: Clonar o repositório
```bash
# Clone o projeto
git clone https://github.com/seu-usuario/github-access-audit.git

# Entre no diretório
cd github-access-audit
```

### Passo 2: Dar permissão de execução
```bash
chmod +x audit-access-advanced.sh
```

---

## ⚙️ Configuração

### Passo 1: Criar um Token do GitHub

1. Acesse: https://github.com/settings/tokens
2. Clique em **"Generate new token"** → **"Generate new token (classic)"**
3. Configure o token:
   - **Nome**: `github-audit-token`
   - **Expiração**: Escolha conforme necessidade (recomendado: 90 dias)
   - **Permissões necessárias**:
     - ✅ `repo` → **Full control of private repositories**
       - ✅ `repo:status` - Ver status de commits
       - ✅ `repo_deployment` - Ver deployments
       - ✅ `public_repo` - Acessar repositórios públicos
       - ✅ `repo:invite` - Ver convites
     - ✅ `read:org` → **Read org and team membership, read org projects**
       - Necessário para auditar repositórios de organizações
     - ✅ `read:user` → **Read user profile data** (opcional)
       - Útil para verificar informações dos colaboradores
4. Clique em **"Generate token"**
5. **IMPORTANTE**: Copie o token (você não verá novamente!)

#### 🔐 Permissões Mínimas Recomendadas

Para máxima segurança, use apenas as permissões necessárias:

| Permissão | Necessária? | Motivo |
|-----------|-------------|--------|
| `repo` | ✅ **Sim** | Listar colaboradores e permissões |
| `read:org` | ✅ **Sim** | Auditar repos de organizações |
| `read:user` | ⚠️ Opcional | Informações extras dos usuários |
| `admin:org` | ❌ Não | Muito privilegiado - evite |
| `delete_repo` | ❌ Não | Script não deleta nada |

#### ⚠️ Importante sobre Permissões

- **Repositórios Pessoais**: Apenas `repo` é suficiente
- **Organizações**: Precisa de `repo` + `read:org`
- **2FA Status**: Requer API Enterprise (não disponível em contas gratuitas)
- **Última Atividade**: Usa Events API (últimos 90 dias) + Commits API (histórico completo)

### Passo 2: Configurar o Token como variável de ambiente

```bash
# Exportar o token (substitua pelo seu token real)
export GITHUB_TOKEN="ghp_seu_token_aqui"

# Verificar se foi configurado corretamente
echo $GITHUB_TOKEN
```

**Dica**: Para tornar permanente, adicione ao seu `~/.bashrc` ou `~/.zshrc`:
```bash
echo 'export GITHUB_TOKEN="ghp_seu_token_aqui"' >> ~/.bashrc
source ~/.bashrc
```

### Passo 3: Configurar os repositórios para auditar

Edite o arquivo `audit-access-advanced.sh`:

```bash
# Use nano (mais simples)
nano audit-access-advanced.sh

# OU use vim (mais avançado)
vim audit-access-advanced.sh
```

Procure pela seção (aproximadamente linha 240):
```bash
# Lista de repositórios para auditar
repos=(
    "sua-empresa/seu-repositorio"
)
```

Altere para seus repositórios:
```bash
repos=(
    "sua-empresa/projeto1"
    "sua-empresa/projeto2"
    "seu-usuario/repositorio-pessoal"
)
```

**Salvar e sair:**
- **nano**: `Ctrl + O` (salvar), `Enter`, `Ctrl + X` (sair)
- **vim**: `Esc`, digite `:wq`, `Enter`

---

## 🎮 Como Usar

### Execução Básica

```bash
# Executar o script
./audit-access-advanced.sh
```

### Salvar output em arquivo separado

```bash
# Redirecionar saída para arquivo
./audit-access-advanced.sh | tee auditoria_manual.log
```

### Executar em horário específico

```bash
# Executar às 8h da manhã
echo "0 8 * * * cd /caminho/para/github-access-audit && ./audit-access-advanced.sh" | crontab -e
```

---

## 📊 Relatórios Gerados

Após a execução, os relatórios são salvos na pasta `reports/`:

### 1. Arquivo LOG (.log)
- **Formato**: Texto colorido com emojis
- **Uso**: Visualização rápida no terminal
- **Exemplo**: `reports/audit_20251102_083015.log`
- **Contém**: Trail de auditoria, IP mascarado, hash SHA256

```bash
# Visualizar o relatório LOG
cat reports/audit_*.log | less -R
```

### 2. Arquivo CSV (.csv)
- **Formato**: Planilha separada por vírgulas
- **Uso**: Importar em Excel, Google Sheets, análise de dados
- **Exemplo**: `reports/audit_20251102_083015.csv`
- **Colunas**: Repository, Username, Permission, Last_Activity, Days_Inactive, Alert_Level, 2FA_Status

```bash
# Abrir CSV no terminal
column -t -s, reports/audit_*.csv | less -S
```

### 3. Arquivo HTML (.html)
- **Formato**: Página web visual responsiva
- **Uso**: Compartilhar com equipes, apresentações
- **Exemplo**: `reports/audit_20251102_083015.html`
- **Recursos**: Cores por criticidade, trail de auditoria, IP mascarado

```bash
# Abrir no navegador
xdg-open reports/audit_*.html  # Linux
open reports/audit_*.html      # macOS
```

### 4. Arquivo JSON (.json)
- **Formato**: Dados estruturados
- **Uso**: Comparações futuras, integração com sistemas
- **Exemplo**: `reports/audit_20251102_083015.json`
- **Contém**: Metadata completa da auditoria

### 5. Trail de Auditoria (audit_trail.log)
- **Formato**: Log persistente acumulativo
- **Uso**: Histórico completo, investigações forenses
- **Localização**: `reports/audit_trail.log`
- **Contém**: Todas as execuções, ações, IP real, hashes

```bash
# Ver histórico completo de auditorias
cat reports/audit_trail.log

# Ver apenas auditorias de hoje
grep "$(date +%Y-%m-%d)" reports/audit_trail.log

# Verificar hash de um relatório específico
grep "REPORT_HASH" reports/audit_trail.log | tail -1
```

### Estrutura dos Relatórios

Cada relatório contém:

#### 📋 Trail de Auditoria
- 📅 Data/hora com timezone
- 👤 Usuário executante
- 🖥️ Hostname da máquina
- 🌐 IP Address (mascarado em público, real no trail)
- � Shell utilizado
- 📁 Diretório de execução
- 🆔 Process ID (PID)
- 📌 Versão do script
- 🔒 Hash SHA256 do relatório

#### 📦 Por Repositório
- 👥 Lista completa de colaboradores
- 🔑 Permissão de cada usuário (admin/write/read)
- 📅 Última atividade (data real via API)
- ⏱️ Dias de inatividade
- 🔐 Status 2FA (quando disponível)
- ⚡ Nível de alerta (CRITICAL/HIGH/MEDIUM/WATCH/LOW)
- 📊 Resumo: total de usuários, admins, alertas críticos

#### 🚨 Alertas Automáticos
- Admins inativos há mais de 180 dias
- Usuários inativos há mais de 90 dias
- Repositórios vazios com acessos
- Permissões administrativas não utilizadas

---

## ⏰ Automatização com Cron

### Configurar auditoria semanal

```bash
# Editar crontab
crontab -e

# Adicionar linha para executar toda segunda-feira às 8h
0 8 * * 1 cd /caminho/completo/para/github-access-audit && /bin/bash ./audit-access-advanced.sh >> /var/log/github-audit.log 2>&1
```

### Exemplos de agendamento Cron

```bash
# Toda segunda-feira às 8h
0 8 * * 1 /caminho/para/script.sh

# Todo dia às 9h
0 9 * * * /caminho/para/script.sh

# Primeiro dia de cada mês às 7h
0 7 1 * * /caminho/para/script.sh

# A cada 6 horas
0 */6 * * * /caminho/para/script.sh
```

### Verificar se o cron está funcionando

```bash
# Ver tarefas agendadas
crontab -l

# Ver logs do cron
tail -f /var/log/syslog | grep CRON  # Ubuntu/Debian
tail -f /var/log/cron                # CentOS/RHEL
```

---

## 🔧 Troubleshooting

### Problema: "GITHUB_TOKEN não está configurado"

**Solução:**
```bash
export GITHUB_TOKEN="seu-token-aqui"
```

---

### Problema: "command not found: jq"

**Solução:**
```bash
# Ubuntu/Debian
sudo apt install jq

# CentOS/RHEL
sudo yum install jq

# macOS
brew install jq
```

---

### Problema: "Permission denied"

**Solução:**
```bash
# Dar permissão de execução
chmod +x audit-access-advanced.sh
```

---

### Problema: Erro 401 ou 403 da API

**Possíveis causas:**
1. Token inválido ou expirado
2. Token sem permissões necessárias
3. Repositório não existe ou você não tem acesso

**Solução:**
1. Verifique se o token está correto:
```bash
echo $GITHUB_TOKEN
```

2. Teste o token manualmente:
```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

3. Gere um novo token com as permissões corretas

---

### Problema: "Nenhum colaborador encontrado"

**Possíveis causas:**
1. Repositório não existe
2. Nome do repositório incorreto
3. Token sem permissão de leitura

**Solução:**
Verifique se o nome do repositório está correto no formato `usuario/repositorio`

---

### Problema: Relatórios não são gerados

**Solução:**
```bash
# Verificar se a pasta reports existe
ls -la reports/

# Criar manualmente se necessário
mkdir -p reports

# Verificar permissões
chmod 755 reports
```

---

## 📝 Níveis de Alerta

O script classifica usuários em 5 níveis baseado em inatividade e permissões:

| Nível | Cor | Descrição | Critério | Ação Recomendada |
|-------|-----|-----------|----------|------------------|
| 🔴 **CRITICAL** | Vermelho | Admin inativo crítico | Admin há 180+ dias inativo | ⚠️ **REVISAR IMEDIATAMENTE** - Remover acesso |
| 🟣 **HIGH** | Roxo | Risco alto | Admin 90+ dias OU usuário 180+ dias | ⚠️ Revisar e considerar remoção urgente |
| 🟡 **MEDIUM** | Amarelo | Risco moderado | Usuário inativo há 90+ dias | 👀 Monitorar e revisar em breve |
| � **WATCH** | Azul | Monitoramento | Admin ativo | 👁️ Manter em observação contínua |
| �🟢 **LOW** | Verde | Normal | Usuário ativo | ✅ Nenhuma ação necessária |

### 🚨 Alertas Especiais

O script também detecta e alerta sobre:

- **📦 Repositórios Vazios**: Repos sem commits mas com admins
- **👤 Usuários Externos**: Colaboradores de fora da organização (quando detectável)
- **🔑 Permissões Administrativas**: Todos os admins são destacados

### 💡 Interpretação dos Alertas

**Exemplo de Output:**
```
👤 Usuário: joao-silva
   🔑 Permissão: admin
   📅 Última atividade: Nunca (repo vazio)
   ⏱️  Dias inativo: 999
   🔐 2FA: unknown
   ⚡ Nível: CRITICAL
   🚨 CRÍTICO: Admin inativo há mais de 180 dias!
   ℹ️  Repositório sem commits - considere remover acesso ou arquivar
```

**Interpretação:**
1. Usuário tem permissão de **admin**
2. **Nunca teve atividade** no repositório
3. **Repositório está vazio** (sem commits)
4. **AÇÃO**: Remover acesso ou arquivar o repositório

---

## 🤝 Cenários de Uso

### 1. Empresa de Tecnologia
- Auditoria semanal automática
- Time de segurança revisa relatórios
- Remove ex-funcionários com acesso

### 2. Compliance/Governança
- Histórico de auditorias para auditorias externas
- Demonstra conformidade com políticas de segurança
- Evidências para certificações (ISO 27001, SOC 2)

### 3. Gerenciamento de Acesso
- Identifica permissões excessivas
- Revisa acessos de contractors/terceiros
- Mantém princípio de menor privilégio

---

## 🔒 Boas Práticas de Segurança

### 🔐 Gerenciamento de Tokens

1. **Nunca compartilhe seu token** em código, mensagens ou repositórios públicos
2. Use tokens com **permissões mínimas** necessárias (princípio do menor privilégio)
3. **Rotacione tokens** periodicamente (recomendado: a cada 90 dias)
4. Armazene tokens em **variáveis de ambiente**, nunca em arquivos commitados
5. Use tokens diferentes para **ambientes diferentes** (dev, homolog, prod)
6. **Revogue tokens** imediatamente se comprometidos ou não mais necessários
7. Configure **expiração automática** nos tokens (máximo 90 dias)

### 📋 Trail de Auditoria e Compliance

1. Mantenha **logs de auditoria** por tempo adequado (recomendado: 1-2 anos)
2. Use o **hash SHA256** para garantir integridade dos relatórios
3. **Verifique hashes** antes de usar relatórios antigos:
   ```bash
   # Hash gerado pelo script
   grep "REPORT_HASH" reports/audit_trail.log | tail -1
   
   # Verificar manualmente
   sha256sum reports/audit_20251102_083015.log
   ```
4. Armazene relatórios em **local seguro** com backup
5. **Revise relatórios** regularmente (semanal ou mensal)

### 🌐 Privacidade e Proteção de Dados

1. **IP mascarado** em relatórios públicos (HTML, LOG visível)
2. **IP real** mantido apenas no trail log (uso forense/interno)
3. Não compartilhe relatórios com dados sensíveis externamente
4. Use **criptografia** ao transmitir relatórios (HTTPS, SSH, VPN)

### 🚨 Resposta a Incidentes

1. Se detectar **acesso não autorizado**:
   - Remova o acesso imediatamente
   - Revogue tokens comprometidos
   - Investigue usando o trail de auditoria
   - Documente o incidente

2. Para **admins inativos críticos**:
   - Notifique o time de segurança
   - Remova permissões administrativas
   - Downgrade para read-only se necessário
   - Documente a decisão

3. Para **repositórios vazios**:
   - Avalie se ainda são necessários
   - Arquive ou delete se não usados
   - Remova acessos desnecessários

### ✅ Checklist de Segurança

- [ ] Token com permissões mínimas configurado
- [ ] Auditoria agendada (cron) funcionando
- [ ] Relatórios sendo revisados regularmente
- [ ] Trail de auditoria sendo armazenado com segurança
- [ ] Processo definido para resposta a alertas CRITICAL
- [ ] Hashes sendo verificados antes de usar relatórios antigos
- [ ] Backups dos relatórios configurados

---

## 📧 Suporte

- **Issues**: https://github.com/seu-usuario/github-access-audit/issues
- **Documentação**: Este README

---

## 📄 Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## ✨ Contribuindo

Contribuições são bem-vindas! Por favor:
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---
