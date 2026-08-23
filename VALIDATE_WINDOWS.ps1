param(
  [string]$PackagePath = $PSScriptRoot
)
$ErrorActionPreference = "Stop"
$Rscript = (Get-Command Rscript.exe -ErrorAction SilentlyContinue).Source
if (-not $Rscript) {
  $candidates = Get-ChildItem "C:\Program Files\R" -Directory -Filter "R-*" -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending |
    ForEach-Object { Join-Path $_.FullName "bin\Rscript.exe" } |
    Where-Object { Test-Path $_ }
  $Rscript = $candidates | Select-Object -First 1
}
if (-not $Rscript) { throw "Rscript.exe was not found. Install R or add its bin directory to PATH." }
Write-Host "Using $Rscript"
& $Rscript (Join-Path $PackagePath "inst\scripts\validate_local.R") $PackagePath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
