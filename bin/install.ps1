#!/usr/bin/env pwsh
# Prismstack installer for PowerShell
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$Target = if ($env:TARGET) { $env:TARGET } else { Join-Path $HOME ".claude/skills/prismstack" }

Write-Host "Installing Prismstack to $Target..."

New-Item -ItemType Directory -Force -Path $Target | Out-Null

$skillDirs = Get-ChildItem -Path (Join-Path $RepoDir "skills") -Directory
foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    if ($skillName -eq "shared") { continue }

    $dest = Join-Path $Target $skillName
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    $skillMd = Join-Path $skillDir.FullName "SKILL.md"
    if (Test-Path $skillMd) {
        Copy-Item $skillMd -Destination $dest -Force
    }

    $refsDir = Join-Path $skillDir.FullName "references"
    if (Test-Path $refsDir) {
        Copy-Item $refsDir -Destination $dest -Recurse -Force
    }

    $scriptsDir = Join-Path $skillDir.FullName "scripts"
    if (Test-Path $scriptsDir) {
        Copy-Item $scriptsDir -Destination $dest -Recurse -Force
    }

    Write-Host "  ✓ $skillName"
}

$sharedDest = Join-Path $Target "shared"
New-Item -ItemType Directory -Force -Path $sharedDest | Out-Null
$sharedSrc = Join-Path $RepoDir "skills/shared/*"
if (Test-Path (Join-Path $RepoDir "skills/shared")) {
    Copy-Item $sharedSrc -Destination $sharedDest -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "  ✓ shared resources"

Write-Host ""
Write-Host "Prismstack installed successfully."
$skillCount = (Get-ChildItem -Path $Target -Directory | Where-Object { $_.Name -ne "shared" }).Count
Write-Host "Skills available: $skillCount"
