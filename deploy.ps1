$ErrorActionPreference = "Stop"

# Ensure on source branch and up to date
git switch source | Out-Null
git pull

# Install & build
pnpm install
pnpm build

if (-not (Test-Path ".vitepress\dist\index.html")) {
  throw "Build did not produce .vitepress/dist/index.html. Aborting deploy."
}

# Ensure .nojekyll
New-Item -ItemType File -Path ".vitepress\dist\.nojekyll" -Force | Out-Null

# Deploy dist to main
Push-Location ".vitepress\dist"
try {
  if (-not (Test-Path ".git")) {
    git init | Out-Null
  }
  git branch -M main
  git add -A
  git commit -m ("deploy " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) | Out-Null

  # Set remote and force push
  git remote remove origin 2>$null
  git remote add origin "https://github.com/Stomatra/stomatra.github.io.git"
  git push -f origin main
}
finally {
  Pop-Location
}