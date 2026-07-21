# Guia da Grana

Blog estático de educação financeira (finanças pessoais para o brasileiro do dia a dia), pronto para monetização com Google AdSense.

- **Stack:** HTML + CSS puros, zero dependências, zero build.
- **Hospedagem:** GitHub Pages (branch `main`, raiz) com domínio próprio via arquivo `CNAME`.
- **URL:** https://guiadagrana.uniqsystems.com.br/ (fallback: https://hnmcano.github.io/guia-da-grana/)

## Estrutura

```
index.html            Home com os cards dos artigos
artigos/*.html        8 artigos evergreen de finanças pessoais
sobre|contato|privacidade|termos.html   Páginas obrigatórias p/ AdSense
css/style.css         Folha de estilo única
ads.txt               Placeholder — colocar o pub ID após aprovação
robots.txt, sitemap.xml
```

## Deploy

Primeira vez (requer `gh auth login` feito):

```powershell
.\deploy.ps1
```

Atualizações depois: `git add -A; git commit -m "..."; git push`.

## Ativar o AdSense (passos manuais do dono)

1. **DNS:** criar registro CNAME no DNS de `uniqsystems.com.br`:
   `guiadagrana` → `hnmcano.github.io` (o arquivo `CNAME` do repo já cuida do
   lado do GitHub Pages; depois ativar "Enforce HTTPS" nas settings do repo).
2. Criar conta em https://adsense.google.com cadastrando o domínio raiz
   `uniqsystems.com.br` (AdSense não aceita subdomínio `github.io`; com o raiz
   cadastrado, os anúncios rodam no subdomínio do blog).
3. Após aprovação, em **todas** as páginas HTML, descomentar o bloco
   `GOOGLE ADSENSE` no `<head>` e trocar `ca-pub-XXXXXXXXXXXXXXXX` pelo ID real.
4. Atualizar o `ads.txt` com a linha real do editor.
5. Cadastrar o sitemap no Google Search Console.
