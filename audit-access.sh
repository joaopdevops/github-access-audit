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
    echo "$collaborators" | jq -r '.[] | {
        login: .login,
        permissions: .permissions,
        last_active: .updated_at
    }' | while read -r user; do
        login=$(echo "$user" | jq -r '.login')
        permissions=$(echo "$user" | jq -r '.permissions')
        last_active=$(echo "$user" | jq -r '.last_active')
        
        echo -e "${YELLOW}Usuário: $login${NC}"
        echo "Permissões: $permissions"
        echo "Último acesso: $last_active"
        echo "----------------------------------------"
    done
}

# Main
echo -e "${GREEN}=== Auditoria de Acessos GitHub ===${NC}"
echo "Data: $(date)"
echo "----------------------------------------"

# Você pode adicionar mais repositórios à lista
repos=(
    "seu-usuario/seu-repo"
)

for repo in "${repos[@]}"; do
    list_collaborators "$repo"
done
