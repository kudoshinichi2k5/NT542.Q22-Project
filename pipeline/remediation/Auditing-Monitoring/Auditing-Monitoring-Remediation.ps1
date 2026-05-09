# =========================================================================
# CIS BENCHMARK LEVEL 1 - MASTER REMEDIATION SCRIPT
# Tu dong khac phuc Registry + Audit Policy + Ghi log thoi gian thuc
# =========================================================================

# =========================================
# IMPORT RULES
# =========================================

. .\audit.ps1

# =========================================
# INIT LOGGING
# =========================================

$BaseDir = "C:\CIS-Automation"

if (-not (Test-Path "$BaseDir\Logs")) {
    New-Item -ItemType Directory -Force -Path "$BaseDir\Logs" | Out-Null
}

$StartTime = Get-Date
$TimestampFile = $StartTime.ToString("yyyyMMdd_HHmmss")
$TimestampDisplay = $StartTime.ToString("dd/MM/yyyy HH:mm:ss")

$LogFile = "$BaseDir\Logs\Remediation-$TimestampFile.log"

Start-Transcript -Path $LogFile -Force

Clear-Host

Write-Host "===============================================================================" -ForegroundColor Green
Write-Host " BAT DAU KHAC PHUC (REMEDIATION) THEO CHUAN CIS BENCHMARK V5.0.0" -ForegroundColor White -BackgroundColor DarkGreen
Write-Host " Thoi gian bat dau : $TimestampDisplay" -ForegroundColor Green
Write-Host "===============================================================================`n" -ForegroundColor Green

# =========================================
# SAFE REGISTRY PATH CREATOR
# =========================================

Function Ensure-RegistryPath {

    param([string]$RegPath)

    if (-not (Test-Path $RegPath)) {

        $parent = Split-Path $RegPath

        if (-not (Test-Path $parent)) {

            Ensure-RegistryPath -RegPath $parent
        }

        New-Item -Path $RegPath -Force | Out-Null
    }
}

# =========================================
# GROUP RULES
# =========================================

$GroupedRules = $Rules | Group-Object Group

foreach ($Group in $GroupedRules) {

    Write-Host "`n>> $($Group.Name)" -ForegroundColor Yellow

    foreach ($Rule in $Group.Group) {

        $TimeNow = Get-Date -Format "HH:mm:ss"

        try {

            # ============================================================
            # REGISTRY REMEDIATION
            # ============================================================

            if ($Rule.Type -eq "Registry") {

                Ensure-RegistryPath -RegPath $Rule.Path

                # Xac dinh Registry Type
                $RegType = switch ($Rule.ValueType) {

                    "DWord"       { "DWord" }
                    "String"      { "String" }
                    "ExpandString"{ "ExpandString" }
                    "MultiString" { "MultiString" }

                    default       { "DWord" }
                }

                # Tao value neu chua ton tai
                if (-not (Get-ItemProperty -Path $Rule.Path -Name $Rule.Key -ErrorAction SilentlyContinue)) {

                    New-ItemProperty `
                        -Path $Rule.Path `
                        -Name $Rule.Key `
                        -PropertyType $RegType `
                        -Value $Rule.ExpectedValue `
                        -Force | Out-Null
                }

                # Cap nhat gia tri
                Set-ItemProperty `
                    -Path $Rule.Path `
                    -Name $Rule.Key `
                    -Value $Rule.ExpectedValue `
                    -Force

                Write-Host "[$TimeNow] [ PASS ] $($Rule.CisId) -> Registry fixed ($($Rule.Key) = $($Rule.ExpectedValue))" -ForegroundColor Green
            }

            # ============================================================
            # AUDIT POLICY REMEDIATION
            # ============================================================

            elseif ($Rule.Type -eq "AuditPol") {

                switch ($Rule.ExpectedValue) {

                    "Success" {

                        auditpol /set `
                            /subcategory:"$($Rule.Subcategory)" `
                            /success:enable `
                            /failure:disable | Out-Null
                    }

                    "Failure" {

                        auditpol /set `
                            /subcategory:"$($Rule.Subcategory)" `
                            /success:disable `
                            /failure:enable | Out-Null
                    }

                    "Success and Failure" {

                        auditpol /set `
                            /subcategory:"$($Rule.Subcategory)" `
                            /success:enable `
                            /failure:enable | Out-Null
                    }

                    "No Auditing" {

                        auditpol /set `
                            /subcategory:"$($Rule.Subcategory)" `
                            /success:disable `
                            /failure:disable | Out-Null
                    }
                }

                Write-Host "[$TimeNow] [ PASS ] $($Rule.CisId) -> Audit Policy fixed ($($Rule.Subcategory))" -ForegroundColor Green
            }

            # ============================================================
            # UNKNOWN TYPE
            # ============================================================

            else {

                Write-Host "[$TimeNow] [ SKIP ] $($Rule.CisId) -> Unknown rule type" -ForegroundColor DarkYellow
            }
        }

        catch {

            Write-Host "[$TimeNow] [ FAIL ] $($Rule.CisId) -> $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# =========================================
# APPLY GROUP POLICY
# =========================================

Write-Host "`n[+] Dang ap dung chinh sach Group Policy (gpupdate) xuong he thong..." -ForegroundColor Cyan

gpupdate /force /wait:0 | Out-Null

# =========================================
# FINISH
# =========================================

$EndTime = Get-Date.ToString("dd/MM/yyyy HH:mm:ss")

Write-Host "`n===============================================================================" -ForegroundColor Green
Write-Host " HOAN TAT KHAC PHUC CIS BENCHMARK!" -ForegroundColor Green
Write-Host " Thoi gian ket thuc : $EndTime" -ForegroundColor Green
Write-Host " File log : $LogFile" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Green

Stop-Transcript