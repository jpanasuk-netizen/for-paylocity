# Publish the Paylocity packet to GitHub Pages.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:GH_TOKEN -ErrorAction SilentlyContinue

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Host "Install GitHub CLI first: https://cli.github.com/"
  exit 1
}

$owner = (gh api user --jq .login)
$repo = "for-paylocity"
$url = "https://$owner.github.io/$repo/"

if (-not (Test-Path .git)) { git init; git checkout -b main }

git add index.html playbook.html loyalty.html cover.html COVER.txt README.md HF_README.md assets .gitignore PUBLISH-GITHUB-PAGES.ps1 JEREMY_PANASUK_PAYLOCITY_MTO.html JEREMY_PANASUK_PAYLOCITY_MTO.pdf JEREMY_PANASUK_PAYLOCITY_COVER.pdf
git status
git commit -m "Paylocity Manager Technical Operations packet" --allow-empty

$exists = gh repo view "$owner/$repo" 2>$null
if ($LASTEXITCODE -ne 0) {
  git remote remove origin 2>$null
  gh repo create $repo --public --source=. --remote=origin --push
} else {
  git remote remove origin 2>$null
  git remote add origin "https://github.com/$owner/$repo.git"
  git push -u origin main
}

gh api --method POST "repos/$owner/$repo/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>$null
Start-Sleep -Seconds 3
gh api --method PUT "repos/$owner/$repo/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null

Write-Host "LIVE: $url"
