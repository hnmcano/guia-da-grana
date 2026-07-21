# Aplica os codigos do Google (AdSense e Search Console) em todas as paginas do blog.
#
# Uso:
#   .\configurar.ps1 -AdSense "ca-pub-1234567890123456"
#   .\configurar.ps1 -SearchConsole "AbCdEf...token..."
#   .\configurar.ps1 -AdSense "ca-pub-..." -SearchConsole "..."   (os dois de uma vez)
#
# O script edita os arquivos, faz commit e da push. O site atualiza em ~1 minuto.

param(
    [string]$AdSense = "",
    [string]$SearchConsole = ""
)

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$mudancas = @()

if (-not $AdSense -and -not $SearchConsole) {
    Write-Host "Nada a fazer. Informe -AdSense e/ou -SearchConsole." -ForegroundColor Yellow
    Write-Host 'Exemplo: .\configurar.ps1 -AdSense "ca-pub-1234567890123456"' -ForegroundColor Cyan
    exit 1
}

# --- Validacao basica dos formatos ---
if ($AdSense -and $AdSense -notmatch '^ca-pub-\d{16}$') {
    Write-Host "ID do AdSense parece invalido: '$AdSense'" -ForegroundColor Red
    Write-Host "Formato esperado: ca-pub- seguido de 16 digitos." -ForegroundColor Yellow
    exit 1
}

$paginas = Get-ChildItem -Path $raiz -Filter *.html -Recurse | Where-Object { $_.FullName -notlike "*\.git\*" }
Write-Host "Encontradas $($paginas.Count) paginas HTML." -ForegroundColor Cyan

foreach ($p in $paginas) {
    $texto = [System.IO.File]::ReadAllText($p.FullName)
    $original = $texto

    # --- AdSense: troca o bloco comentado pelo script ativo ---
    if ($AdSense) {
        $scriptAtivo = '  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=' + $AdSense + '" crossorigin="anonymous"></script>'

        if ($texto -match '(?s)  <!-- GOOGLE ADSENSE:.*?-->') {
            $texto = [regex]::Replace($texto, '(?s)  <!-- GOOGLE ADSENSE:.*?-->', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $scriptAtivo })
        }
        elseif ($texto -match 'adsbygoogle\.js\?client=ca-pub-\d{16}') {
            # ja estava ativo: apenas atualiza o ID
            $texto = [regex]::Replace($texto, 'adsbygoogle\.js\?client=ca-pub-\d{16}', "adsbygoogle.js?client=$AdSense")
        }
    }

    # --- Search Console: meta tag de verificacao (apenas na home) ---
    if ($SearchConsole -and $p.Name -eq "index.html" -and $p.DirectoryName -eq $raiz) {
        $meta = '  <meta name="google-site-verification" content="' + $SearchConsole + '">'
        if ($texto -match '<meta name="google-site-verification"[^>]*>') {
            $texto = [regex]::Replace($texto, '\s*<meta name="google-site-verification"[^>]*>', "`n$meta")
        } else {
            $texto = $texto -replace '(?m)^(\s*<meta name="viewport"[^>]*>)', "`$1`n$meta"
        }
    }

    if ($texto -ne $original) {
        [System.IO.File]::WriteAllText($p.FullName, $texto, $utf8)
        $mudancas += $p.Name
    }
}

# --- ads.txt ---
if ($AdSense) {
    $pub = $AdSense -replace '^ca-', ''   # ca-pub-123... -> pub-123...
    $linha = "google.com, $pub, DIRECT, f08c47fec0942fa0"
    [System.IO.File]::WriteAllText((Join-Path $raiz "ads.txt"), "$linha`n", $utf8)
    $mudancas += "ads.txt"

    Write-Host ""
    Write-Host "IMPORTANTE - ads.txt do dominio raiz:" -ForegroundColor Yellow
    Write-Host "Como o blog e um subdominio, o Google procura o ads.txt em" -ForegroundColor Yellow
    Write-Host "  https://uniqsystems.com.br/ads.txt" -ForegroundColor Cyan
    Write-Host "Adicione esta linha no projeto da homepage (pasta public/ na Vercel):" -ForegroundColor Yellow
    Write-Host "  $linha" -ForegroundColor Green
}

if ($mudancas.Count -eq 0) {
    Write-Host "Nenhum arquivo precisou ser alterado." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Arquivos alterados: $($mudancas.Count)" -ForegroundColor Green

$msg = @()
if ($AdSense)       { $msg += "ativa AdSense ($AdSense)" }
if ($SearchConsole) { $msg += "adiciona verificacao do Search Console" }
$commitMsg = "Config Google: " + ($msg -join " e ")

git -C $raiz add -A
git -C $raiz commit -m $commitMsg
git -C $raiz push

Write-Host ""
Write-Host "Publicado! O site atualiza em ~1 minuto:" -ForegroundColor Green
Write-Host "https://guiadagrana.uniqsystems.com.br/" -ForegroundColor Cyan
