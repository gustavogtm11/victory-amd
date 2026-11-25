param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GameExe,

    [ValidateSet("performance", "stable")]
    [string]$Mode = "performance"
)

$ErrorActionPreference = "Stop"

$VictoryExe = Join-Path $PSScriptRoot "victory.exe"
if (-not (Test-Path -LiteralPath $VictoryExe -PathType Leaf)) {
    throw "victory.exe nao foi encontrado ao lado deste script. Baixe o pacote Windows x64 completo."
}

if (-not (Test-Path -LiteralPath $GameExe -PathType Leaf)) {
    throw "Executavel do jogo nao encontrado: $GameExe"
}
$GameExe = (Resolve-Path -LiteralPath $GameExe).Path

# Start from a clean set of emulator overrides so old terminal settings
# cannot silently change this launch.
@(
    "VICTORY_LATE_WAIT",
    "VICTORY_RELAY",
    "VICTORY_WIDE_BACK",
    "VICTORY_CARD_BUFFERS_MIN_MB",
    "VICTORY_CARD_BUFFERS_MB",
    "VICTORY_GPU_TIMING"
) | ForEach-Object {
    Remove-Item -Path "Env:$_" -ErrorAction SilentlyContinue
}

if ($Mode -eq "performance") {
    # Best-performing combination documented by this fork's measured runs.
    # The 512 MiB card-buffer budget is deliberately conservative for an
    # 8 GiB GPU such as the RTX 2060 SUPER.
    $env:VICTORY_LATE_WAIT = "3"
    $env:VICTORY_RELAY = "2"
    $env:VICTORY_WIDE_BACK = "1"
    $env:VICTORY_CARD_BUFFERS_MIN_MB = "1"
    $env:VICTORY_CARD_BUFFERS_MB = "512"
}

Write-Host "VIctory - modo: $Mode" -ForegroundColor Cyan
Write-Host "Jogo: $GameExe"
Write-Host "GPU: use o driver NVIDIA atualizado e feche aplicativos pesados."
if ($Mode -eq "performance") {
    Write-Host "Perfil experimental de desempenho ativado. Se houver travamentos, tente -Mode stable." -ForegroundColor Yellow
} else {
    Write-Host "Perfil estavel: sincronizacao padrao, sem relay experimental."
}

& $VictoryExe run $GameExe --execute --console series-x
exit $LASTEXITCODE
