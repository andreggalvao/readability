# Guia para Subir como Fork no GitHub

## Passo 1: Criar Fork no GitHub

1. Acesse https://github.com/keepcosmos/readability
2. Clique no botão "Fork" no canto superior direito
3. Escolha sua conta/organização onde quer criar o fork
4. Aguarde o GitHub criar o fork

## Passo 2: Configurar Remote do Seu Fork

Depois de criar o fork, você terá uma URL como:
`https://github.com/SEU_USUARIO/readability.git`

Execute no terminal (substitua SEU_USUARIO):

```bash
# Adicionar seu fork como um novo remote chamado "fork"
git remote add fork https://github.com/SEU_USUARIO/readability.git

# OU se preferir usar SSH:
git remote add fork git@github.com:SEU_USUARIO/readability.git

# Verificar os remotes configurados
git remote -v
```

## Passo 3: Fazer Commit das Mudanças

```bash
# Adicionar todos os arquivos modificados e novos
git add .

# Fazer commit com mensagem descritiva
git commit -m "feat: Add markdown support, JSON-LD extraction, blacklist, and other improvements

- Add markdown conversion via html2markdown
- Add JSON-LD metadata extraction
- Add lead image extraction (og:image, twitter:image)
- Add reading time calculation
- Add text direction detection
- Add blacklist support (CSS selectors and text patterns)
- Improve URL resolution for images and links
- Update dependencies (floki, jason, html2markdown)"
```

## Passo 4: Fazer Push para Seu Fork

```bash
# Push da branch atual para seu fork
git push fork feat/improve

# OU se quiser criar uma branch master/main no seu fork:
git checkout -b master
git push fork master
```

## Passo 5: Usar em Outros Projetos

No `mix.exs` do seu outro projeto:

```elixir
def deps do
  [
    {:readability, git: "https://github.com/SEU_USUARIO/readability.git", branch: "feat/improve"}
    # OU se você fez push para master:
    # {:readability, git: "https://github.com/SEU_USUARIO/readability.git", branch: "master"}
  ]
end
```

Depois execute:
```bash
mix deps.get
```

## Opcional: Criar Pull Request

Se quiser contribuir de volta para o projeto original:

1. Vá para https://github.com/keepcosmos/readability
2. Clique em "Pull requests" > "New pull request"
3. Selecione seu fork e branch
4. Descreva as mudanças

