# =========================================================================
# CIS BENCHMARK - DRIFT MANAGEMENT & AUTO-HEALING ORCHESTRATOR
# Tự động phát hiện sai lệch cấu hình, phục hồi và xuất báo cáo Delta
# =========================================================================

$BaseDir = "C:\CIS-Automation"
$ProjectRoot = $PSScriptRoot
$TemplateDir = Join-Path $ProjectRoot "templates"
$CssTemplatePath = Join-Path $TemplateDir "autohealing-report.css"
$HtmlTemplatePath = Join-Path $TemplateDir "autohealing-report.html.tpl"

$AuditScript = Join-Path $ProjectRoot "audit\Network-Services-Security\CIS-WinServer2022-Audit.ps1"
$RemediationScript = Join-Path $ProjectRoot "remediation\Network-Services-Security\CIS-WinServer2022-Remediation.ps1"
$JsonDir = "$BaseDir\Reports\JSON"
$HtmlDir = "$BaseDir\Reports\HTML"

$RequiredDirs = @(
    "$BaseDir\Reports\JSON",
    "$BaseDir\Reports\HTML",
    "$BaseDir\Logs"
)
foreach ($dir in $RequiredDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

$StartTime = Get-Date
$Timestamp = $StartTime.ToString("yyyyMMdd_HHmmss")
$DisplayTime = $StartTime.ToString("MM/dd/yyyy HH:mm:ss")
$OSInfo = (Get-CimInstance Win32_OperatingSystem).Caption

Write-Host "[*] BẮT ĐẦU LUỒNG TỰ ĐỘNG HÓA PHỤC HỒI CẤU HÌNH..." -ForegroundColor Cyan

if (-not (Test-Path $AuditScript)) {
    throw "Audit script not found: $AuditScript"
}
if (-not (Test-Path $RemediationScript)) {
    throw "Remediation script not found: $RemediationScript"
}
if (-not (Test-Path $CssTemplatePath)) {
    throw "CSS template not found: $CssTemplatePath"
}
if (-not (Test-Path $HtmlTemplatePath)) {
    throw "HTML template not found: $HtmlTemplatePath"
}

# 1. PRE-AUDIT (Quét hiện trạng)
Write-Host "[1/5] Dang chay Pre-Audit..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$AuditScript`"" -Wait

# Lấy file JSON mới nhất vừa tạo
$PreAuditFile = Get-ChildItem -Path $JsonDir -Filter "*.json" | Sort-Object CreationTime -Descending | Select-Object -First 1
$PreData = Get-Content $PreAuditFile.FullName -Raw | ConvertFrom-Json

# 2. DRIFT DETECTION (Lọc các mục bị sai lệch)
$DriftedItems = $PreData | Where-Object { $_.Status -eq "Fail" }

if ($DriftedItems.Count -eq 0) {
    Write-Host "[*] He thong hoan toan dat chuan. Khong co sai lech. Ngung luong (Exit)." -ForegroundColor Green
    exit
}

Write-Host "[2/5] Phat hien $($DriftedItems.Count) muc bi sai lech (Drifted)!" -ForegroundColor Red

# 3. AUTO-HEALING (Tiến hành khắc phục)
Write-Host "[3/5] Dang kich hoat luong Tu dong phuc hoi (Remediation)..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$RemediationScript`"" -Wait

# 4. POST-AUDIT (Kiểm tra lại sau khi khắc phục)
Write-Host "[4/5] Dang chay Post-Audit de xac minh..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$AuditScript`"" -Wait

$PostAuditFile = Get-ChildItem -Path $JsonDir -Filter "*.json" | Sort-Object CreationTime -Descending | Select-Object -First 1
$PostData = Get-Content $PostAuditFile.FullName -Raw | ConvertFrom-Json

# 5. DELTA REPORTING (Tạo báo cáo Auto-Healing chuyên biệt)
Write-Host "[5/5] Dang tao Báo cáo Auto-Healing (HTML)..." -ForegroundColor Yellow

$CssContent = Get-Content -Path $CssTemplatePath -Raw
$HtmlTemplate = Get-Content -Path $HtmlTemplatePath -Raw
$StyleBlock = "<style>`n$CssContent`n</style>"

$TableRows = New-Object System.Collections.Generic.List[string]

$HealedCount = 0
$FailedCount = 0

foreach ($PreItem in $DriftedItems) {
    # Tìm kiếm Item tương ứng ở bảng PostData
    $PostItem = $PostData | Where-Object { $_.CisId -eq $PreItem.CisId }

    $HealingStatus = "FAILED"
    $StatusClass = "txt-failed"

    if ($null -ne $PostItem -and $PostItem.Status -eq "Pass") {
        $HealingStatus = "SUCCESS"
        $StatusClass = "txt-healed"
        $HealedCount++
    } else {
        $FailedCount++
    }

    $AfterValue = if ($null -ne $PostItem) { $PostItem.Current } else { "N/A" }

    $TableRows.Add("<tr><td class='col-id'>$($PreItem.CisId)</td><td>$($PreItem.Desc)</td><td class='txt-drift' style='font-weight: bold;'>$($PreItem.Current)</td><td style='font-weight: bold;'>$AfterValue</td><td class='col-status'><span class='$StatusClass'>$HealingStatus</span></td></tr>")
}

$FinalHtml = $HtmlTemplate
$Replacements = @{
    "{{TITLE}}"        = "CIS Auto-Healing Report"
    "{{STYLE_BLOCK}}"  = $StyleBlock
    "{{REPORT_TITLE}}" = "CIS BENCHMARK: AUTO-HEALING REPORT"
    "{{DISPLAY_TIME}}" = $DisplayTime
    "{{OS_INFO}}"      = $OSInfo
    "{{DRIFTED_COUNT}}" = [string]$DriftedItems.Count
    "{{TABLE_ROWS}}"   = ($TableRows -join [Environment]::NewLine)
}

foreach ($k in $Replacements.Keys) {
    $FinalHtml = $FinalHtml.Replace($k, $Replacements[$k])
}

$ReportPath = "$HtmlDir\CIS-AutoHealing-$Timestamp.html"
$FinalHtml | Out-File $ReportPath -Encoding UTF8

Write-Host "[*] DA KHOI PHUC THANH CONG: $HealedCount / $($DriftedItems.Count)" -ForegroundColor Green
if ($FailedCount -gt 0) { Write-Host "[!] CO $FailedCount MUC KHONG THE KHOI PHUC TUDONG!" -ForegroundColor Red }
Write-Host "[*] Báo cáo Auto-Healing lưu tại: $ReportPath" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
