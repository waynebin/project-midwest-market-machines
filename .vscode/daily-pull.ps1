$repoRoot = Split-Path $PSScriptRoot -Parent
$stateFile = Join-Path $PSScriptRoot ".last-pull-date"
$logFile = Join-Path $PSScriptRoot "pull-log.txt"
$today = (Get-Date).ToString("yyyy-MM-dd")

if (Test-Path $stateFile) {
  $lastDate = (Get-Content $stateFile -ErrorAction SilentlyContinue).Trim()
  if ($lastDate -eq $today) {
    exit 0
  }
}

$result = & git -C $repoRoot pull --ff-only 2>&1
$exitCode = $LASTEXITCODE
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if ($result -is [System.Array]) {
  $resultText = ($result -join "`n")
} else {
  $resultText = [string]$result
}

"$timestamp | exit=$exitCode | $resultText" | Add-Content -Path $logFile
$today | Set-Content -Path $stateFile

Add-Type -AssemblyName PresentationFramework
$message = "Daily git pull finished (exit $exitCode).`n`n$resultText"
[System.Windows.MessageBox]::Show($message, "Daily Git Pull") | Out-Null
