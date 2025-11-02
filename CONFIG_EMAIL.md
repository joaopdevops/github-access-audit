# 📧 Como Configurar Email Real

## 🎯 Passo a Passo Completo

### **1️⃣ Criar Senha de App do Gmail**

⚠️ **IMPORTANTE**: Não use sua senha normal do Gmail! Use "Senha de App"

1. Acesse: https://myaccount.google.com/security
2. Em "Como fazer login no Google", ative **"Verificação em duas etapas"**
3. Depois de ativar 2FA, volte e procure **"Senhas de app"**
4. Clique em "Senhas de app"
5. Selecione:
   - **App**: Outro (nome personalizado)
   - **Nome**: "GitHub Audit Script"
6. Clique em **"Gerar"**
7. **COPIE A SENHA** de 16 caracteres (ex: `abcd efgh ijkl mnop`)

---

### **2️⃣ Editar o Script**

Abra o script e procure por estas linhas (estão dentro da função `send_email_notification`):

```python
sender_email = "SEU_EMAIL@gmail.com"  # <<<< ALTERE AQUI
sender_password = "SUA_SENHA_DE_APP"   # <<<< ALTERE AQUI
```

**Substitua por:**

```python
sender_email = "seu-email@gmail.com"
sender_password = "abcd efgh ijkl mnop"  # Sua senha de app gerada
```

---

### **3️⃣ Salvar e Testar**

```bash
# Rodar o script
./audit-access-advanced.sh

# Se der erro, verifique:
# 1. Senha de app está correta (sem espaços)
# 2. 2FA está ativo no Gmail
# 3. Python3 está instalado
python3 --version
```

---

## 🔧 Método Alternativo (Edição Rápida via Terminal)

```bash
# Editar diretamente no terminal
nano audit-access-advanced.sh

# Ou com sed (substitua os valores):
sed -i 's/SEU_EMAIL@gmail.com/seu-email@gmail.com/g' audit-access-advanced.sh
sed -i 's/SUA_SENHA_DE_APP/sua_senha_aqui/g' audit-access-advanced.sh
```

---

## 🎯 Para Fazer Commit no Repo da Organização

Se quiser testar a detecção de atividade:

```bash
# Clone o repo da organização
cd /tmp
git clone https://github.com/sua-org/seu-repo.git
cd seu-repo

# Configure seu user (importante!)
git config user.name "seu-usuario"
git config user.email "seu-email@gmail.com"

# Crie um arquivo qualquer
echo "# Test" > README.md
git add README.md
git commit -m "docs: Adicionar README"
git push

# Aguarde 1-2 minutos para a API do GitHub atualizar
# Depois rode o audit novamente
```

Agora vai mostrar atividade recente! ✅

---

## ✅ Checklist Final

- [ ] Senha de app do Gmail criada
- [ ] Script editado com email e senha
- [ ] Python3 instalado (`python3 --version`)
- [ ] Commit feito no repo da organização (opcional)
- [ ] Script testado (`./audit-access-advanced.sh`)
- [ ] Email recebido

---

## 🆘 Problemas Comuns

### Email não chega?
- ✅ Verifique caixa de SPAM
- ✅ Senha de app sem espaços
- ✅ 2FA ativo no Gmail
- ✅ Email remetente correto

### Python não encontrado?
```bash
sudo apt update
sudo apt install python3
```

### Erro de autenticação?
- Recrie a senha de app
- Use a senha EXATA (copie e cole)
- Não use senha normal do Gmail
