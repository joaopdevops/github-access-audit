# Automação de Auditoria de Acessos GitHub

## 🎯 Objetivo
Aplicar meus estudos em Shell Script (Bash), GitHub API, AWS EC2 (VM Ubuntu), SSH - 

Script de automação para auditoria de acessos a repositórios GitHub, útil para gerenciar acessos de ex-colaboradores e manter a segurança dos repositórios da empresa.

## 🛠️ Tecnologias Utilizadas
- Shell Script (Bash)
- GitHub API
- AWS EC2 (VM Ubuntu)
- SSH

## �� Pré-requisitos
- Conta AWS com acesso EC2
- GitHub Token com permissões adequadas
- Chave SSH configurada
- Ubuntu (local ou VM)

## 🚀 Passo a Passo

### 1. Configuração do Ambiente

#### 1.1 Conectando à VM via SSH
```bash
# Exemplo de comando de conexão SSH (substitua pelos seus dados)
ssh -i "endereço da sua-chave.pem" ubuntu@ ip publico-xx-xx-xx-xx.
```

#### 1.2 Configuração do Token GitHub
```bash
# Exportar o token como variável de ambiente
export GITHUB_TOKEN="seu-token-aqui"
```

### 2. Clonando o Repositório
```bash
# Clone do repositório com o script de automação
git clone https://github.com/seu-usuario/seu-repo.git
cd seu-repo
```

### 3. Executando o Script de Auditoria
```bash
# Dar permissão de execução ao script
chmod +x audit-access.sh

# Executar o script
./audit-access.sh
```

### 4. Interpretando os Resultados
O script irá gerar um relatório com:
- Lista de usuários com acesso ao repositório
- Nível de permissão de cada usuário
- Data do último acesso
- Status da conta (ativa/inativa)

## 📊 Exemplo de Output
```
Repository: empresa/projeto-importante
Last Audit: 2025-11-01

Users with access:
1. john_doe (Admin)
   - Last access: 2025-10-30
   - Status: Active

2. ex_employee (Write)
   - Last access: 2025-09-15
   - Status: Inactive
   ⚠️ ATTENTION: Inactive user with repository access
```

## 🔒 Boas Práticas de Segurança
- Sempre revogue acessos imediatamente após a saída de um colaborador
- Faça auditorias regulares (recomendado: mensalmente)
- Mantenha logs das alterações de permissão
- Use tokens com o mínimo de permissões necessárias

## 🤝 Contribuindo
Sinta-se à vontade para contribuir com melhorias! Abra uma issue ou envie um pull request.



---


