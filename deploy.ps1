# Deploy do Guia da Grana no GitHub Pages
# Pré-requisito: gh auth login (uma única vez)
$gh = "C:\Program Files\GitHub CLI\gh.exe"

& $gh auth status
if (-not $?) {
    Write-Host "Rode primeiro: & '$gh' auth login" -ForegroundColor Yellow
    exit 1
}

# Cria o repositório público e faz o primeiro push
& $gh repo create guia-da-grana --public --source . --remote origin --push --description "Blog de educacao financeira - Guia da Grana"

# Ativa o GitHub Pages servindo a branch main (raiz)
$user = (& $gh api user --jq .login)
& $gh api "repos/$user/guia-da-grana/pages" -X POST -f "source[branch]=main" -f "source[path]=/" 2>$null

Write-Host ""
Write-Host "Site publicado! Em 1-2 minutos estara no ar em:" -ForegroundColor Green
Write-Host "https://$user.github.io/guia-da-grana/" -ForegroundColor Cyan
