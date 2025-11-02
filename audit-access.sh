#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se o token do GitHub está configurado
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN não está configurado${NC}"
    echo "Execute: export GITHUB_TOKEN=seu-token-aqui"
    exit 1
fi

# Função para listar colaboradores de um repositório
list_collaborators() {
    local repo=$1
    echo -e "${GREEN}Verificando acessos para: $repo${NC}"
    echo "----------------------------------------"
    
    # Fazendo a chamada à API do GitHub
    collaborators=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$repo/collaborators")
    
    # Verifica se houve erro na chamada
    if [[ $collaborators == *"message"* && $collaborators == *"Not Found"* ]]; then
        echo -e "${RED}Erro: Repositório não encontrado ou sem acesso${NC}"
        return 1
    fi
    
    # Processa cada colaborador
    echo "$collaborators" | jq -c '.[]' | while read -r user; do
        login=$(echo "$user" | jq -r '.login')
        
        # Extrair permissões
        if echo "$user" | jq -e '.permissions.admin == true' >/dev/null 2>&1; then
            permissions="admin"
        elif echo "$user" | jq -e '.permissions.push == true' >/dev/null 2>&1; then
            permissions="write"
        else
            permissions="read"
        fi
        
        echo -e "${YELLOW}Usuário: $login${NC}"
        echo "Permissões: $permissions"
        echo "----------------------------------------"
    done
}

# Main
echo -e "${GREEN}=== Auditoria de Acessos GitHub ===${NC}"
echo "Data: $(date)"
echo "----------------------------------------"

# Você pode adicionar mais repositórios à lista
repos=(
    "seu-usuario/seu-repositorio"
)

for repo in "${repos[@]}"; do
    list_collaborators "$repo"
done
