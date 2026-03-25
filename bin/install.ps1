#!/usr/bin/env pwsh
# Prismstack installer for PowerShell
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir

# --- Mode detection ---
$Mode = if ($args.Count -gt 0) { $args[0] } else { "" }

function Copy-Skill {
    param([string]$SkillDir, [string]$Dest)
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    $skillMd = Join-Path $SkillDir "SKILL.md"
    if (Test-Path $skillMd) { Copy-Item $skillMd -Destination $Dest -Force }
    $refsDir = Join-Path $SkillDir "references"
    if (Test-Path $refsDir) { Copy-Item $refsDir -Destination $Dest -Recurse -Force }
    $scriptsDir = Join-Path $SkillDir "scripts"
    if (Test-Path $scriptsDir) { Copy-Item $scriptsDir -Destination $Dest -Recurse -Force }
}

switch ($Mode) {
    "--global" {
        $Target = if ($env:TARGET) { $env:TARGET } else { Join-Path $HOME ".claude/skills" }
        $InstallMode = "global"
    }
    "--project" {
        $ProjectRoot = try { git rev-parse --show-toplevel 2>$null } catch { Get-Location }
        $Target = if ($env:TARGET) { $env:TARGET } else { Join-Path $ProjectRoot ".claude/skills/prismstack" }
        $InstallMode = "project"
    }
    default {
        Write-Host "Prismstack Installer"
        Write-Host ""
        Write-Host "Usage:"
        Write-Host "  pwsh install.ps1 --project    Install to current project (recommended)"
        Write-Host "                                 -> .claude/skills/prismstack/"
        Write-Host ""
        Write-Host "  pwsh install.ps1 --global     Install to global ~/.claude/skills/"
        Write-Host "                                 -> Each skill as independent global skill"
        Write-Host ""
        Write-Host "  `$env:TARGET='/path' pwsh install.ps1 --project   Override target"
        exit 0
    }
}

Write-Host "Installing Prismstack ($InstallMode mode) to $Target..."
Write-Host ""

$skillDirs = Get-ChildItem -Path (Join-Path $RepoDir "skills") -Directory

if ($InstallMode -eq "project") {
    # --- Project mode: nested under prismstack/ ---
    New-Item -ItemType Directory -Force -Path $Target | Out-Null

    foreach ($skillDir in $skillDirs) {
        if ($skillDir.Name -eq "shared") { continue }
        Copy-Skill -SkillDir $skillDir.FullName -Dest (Join-Path $Target $skillDir.Name)
        Write-Host "  ✓ $($skillDir.Name)"
    }

    # Root SKILL.md = routing entry point
    Copy-Item (Join-Path $RepoDir "skills/prism-routing/SKILL.md") -Destination (Join-Path $Target "SKILL.md") -Force
    Write-Host "  ✓ root SKILL.md (routing entry point)"

    # Shared resources
    $sharedDest = Join-Path $Target "shared"
    New-Item -ItemType Directory -Force -Path $sharedDest | Out-Null
    Copy-Item (Join-Path $RepoDir "skills/shared/*") -Destination $sharedDest -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ shared resources"

} else {
    # --- Global mode: flat, each skill independent ---
    foreach ($skillDir in $skillDirs) {
        if ($skillDir.Name -eq "shared") { continue }

        if ($skillDir.Name -eq "prism-routing") {
            $dest = Join-Path $Target "prismstack"
        } else {
            $dest = Join-Path $Target $skillDir.Name
        }

        Copy-Skill -SkillDir $skillDir.FullName -Dest $dest
        Write-Host "  ✓ $($skillDir.Name) -> $(Split-Path -Leaf $dest)/"
    }

    # Shared resources under prismstack/
    $sharedDest = Join-Path $Target "prismstack/shared"
    New-Item -ItemType Directory -Force -Path $sharedDest | Out-Null
    Copy-Item (Join-Path $RepoDir "skills/shared/*") -Destination $sharedDest -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ shared resources -> prismstack/shared/"
}

Write-Host ""
Write-Host "Prismstack installed successfully ($InstallMode mode)."

if ($InstallMode -eq "project") {
    Write-Host "Skills will be available in this project after restarting Claude Code."
    Write-Host "Sub-skills are auto-discovered via recursive scan."
} else {
    Write-Host "Skills will be available globally after restarting Claude Code."
    Write-Host "Each skill is independently discoverable as a slash command."
}
