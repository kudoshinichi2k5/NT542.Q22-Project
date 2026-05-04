# =========================================================================
# CIS BENCHMARK - DRIFT MANAGEMENT & AUTO-HEALING ORCHESTRATOR
# Tự động phát hiện sai lệch cấu hình, phục hồi và xuất báo cáo Delta
# =========================================================================

$BaseDir = "C:\CIS-Automation"
$ScriptsDir = "$BaseDir\Scripts"
$JsonDir = "$BaseDir\Reports\JSON"
$HtmlDir = "$BaseDir\Reports\HTML"

$StartTime = Get-Date
$Timestamp = $StartTime.ToString("yyyyMMdd_HHmmss")
$DisplayTime = $StartTime.ToString("MM/dd/yyyy HH:mm:ss")
$OSInfo = (Get-CimInstance Win32_OperatingSystem).Caption

Write-Host "[*] BẮT ĐẦU LUỒNG TỰ ĐỘNG HÓA PHỤC HỒI CẤU HÌNH..." -ForegroundColor Cyan

# 1. PRE-AUDIT (Quét hiện trạng)
Write-Host "[1/5] Dang chay Pre-Audit..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptsDir\CIS-WinServer2022-Audit.ps1`"" -Wait

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
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptsDir\CIS-WinServer2022-Remediation.ps1`"" -Wait

# 4. POST-AUDIT (Kiểm tra lại sau khi khắc phục)
Write-Host "[4/5] Dang chay Post-Audit de xac minh..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptsDir\CIS-WinServer2022-Audit.ps1`"" -Wait

$PostAuditFile = Get-ChildItem -Path $JsonDir -Filter "*.json" | Sort-Object CreationTime -Descending | Select-Object -First 1
$PostData = Get-Content $PostAuditFile.FullName -Raw | ConvertFrom-Json

# 5. DELTA REPORTING (Tạo báo cáo Auto-Healing chuyên biệt)
Write-Host "[5/5] Dang tao Báo cáo Auto-Healing (HTML)..." -ForegroundColor Yellow

$HtmlHeader = @"
<style>
    body { font-family: Arial, Tahoma, sans-serif; font-size: 14px; margin: 20px; color: #000; background-color: #f8f9fa; }
    h2 { color: #5a2a82; text-align: center; text-transform: uppercase; font-weight: bold; margin-bottom: 10px; }
    .meta-info { text-align: center; margin-bottom: 20px; color: #555; }
    .alert-box { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold; text-align: center; }
    table { width: 100%; border-collapse: collapse; border: 1px solid #a0a0a0; background-color: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    th { background-color: #5a2a82; color: #ffffff; border: 1px solid #a0a0a0; padding: 12px; font-weight: bold; text-align: center; }
    td { border: 1px solid #a0a0a0; padding: 10px; color: #333; }
    .col-id { text-align: center; font-weight: bold; width: 80px; }
    .col-status { text-align: center; font-weight: bold; width: 120px; }
    .txt-drift { color: #dc3545; }
    .txt-healed { color: #28a745; background-color: #e8f5e9; padding: 4px 8px; border-radius: 4px; }
    .txt-failed { color: #dc3545; background-color: #fde8e8; padding: 4px 8px; border-radius: 4px; }
    .footer { text-align: center; margin-top: 30px; font-style: italic; color: #666; font-size: 13px; }
</style>
"@

$HtmlBody = "<h2>CIS BENCHMARK: AUTO-HEALING REPORT</h2>"
$HtmlBody += "<div class='meta-info'><b>Time:</b> $DisplayTime &nbsp;|&nbsp; <b>OS:</b> $OSInfo</div>"
$HtmlBody += "<div class='alert-box'>DETECTED AND ATTEMPTED TO RECOVER $($DriftedItems.Count) DRIFTED POLICIES</div>"
$HtmlBody += "<table>"
$HtmlBody += "<thead><tr><th>CIS ID</th><th>Description</th><th style='text-align: left;'>Before (Drifted Value)</th><th style='text-align: left;'>After (Restored Value)</th><th>Healing Status</th></tr></thead><tbody>"

$HealedCount = 0
$FailedCount = 0

foreach ($PreItem in $DriftedItems) {
    # Tìm kiếm Item tương ứng ở bảng PostData
    $PostItem = $PostData | Where-Object { $_.CisId -eq $PreItem.CisId }
    
    $HealingStatus = "FAILED"
    $StatusClass = "txt-failed"
    
    if ($PostItem.Status -eq "Pass") {
        $HealingStatus = "SUCCESS"
        $StatusClass = "txt-healed"
        $HealedCount++
    } else {
        $FailedCount++
    }

    $HtmlBody += "<tr>"
    $HtmlBody += "<td class='col-id'>$($PreItem.CisId)</td>"
    $HtmlBody += "<td>$($PreItem.Desc)</td>"
    $HtmlBody += "<td class='txt-drift' style='font-weight: bold;'>$($PreItem.Current)</td>"
    $HtmlBody += "<td style='font-weight: bold;'>$($PostItem.Current)</td>"
    $HtmlBody += "<td class='col-status'><span class='$StatusClass'>$HealingStatus</span></td>"
    $HtmlBody += "</tr>"
}

$HtmlBody += "</tbody></table>"

$FinalHtml = "<!DOCTYPE html><html><head><title>CIS Auto-Healing Report</title>$HtmlHeader</head><body>$HtmlBody</body></html>"
$ReportPath = "$HtmlDir\CIS-AutoHealing-$Timestamp.html"
$FinalHtml | Out-File $ReportPath -Encoding UTF8

Write-Host "[*] DA KHOI PHUC THANH CONG: $HealedCount / $($DriftedItems.Count)" -ForegroundColor Green
if ($FailedCount -gt 0) { Write-Host "[!] CO $FailedCount MUC KHONG THE KHOI PHUC TUDONG!" -ForegroundColor Red }
Write-Host "[*] Báo cáo Auto-Healing lưu tại: $ReportPath" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan