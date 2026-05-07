$Results = @()

$AuditRules = @(

    [PSCustomObject]@{

        Type = "Registry"
        CisId = "2.3.2.1"
        Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Key = "SCENoApplyLegacyAuditPolicy"
        CompareType = "Equals"
        ExpectedValue = 1
    },

    [PSCustomObject]@{
        Type = "Registry"
        CisId = "2.3.2.2"
        Description = "Ensure 'Audit: Shut down system immediately if unable to log security audits' is set to 'Disabled' (Automated)"
        Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Key = "CrashOnAuditFail"
        CompareType = "Equals"
        ExpectedValue = 0
    }
)

$AdvancedAuditRules = @(
    ##---------------Account Logon----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.1.1"
        Description = "Audit Credential Validation"
        Subcategory = "{0cce923f-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.1.2"
        Description = "Audit Kerberos Authentication Service"
        Subcategory = "{0cce9242-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.1.3"
        Description = "Audit Kerberos Service Ticket Operations"
        Subcategory = "{0cce9240-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    ##---------------Account Management----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.1"
        Description = "Audit Application Group Management"
        Subcategory = "{0cce9239-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.2"
        Description = "Audit Computer Account Management"
        Subcategory = "{0cce9236-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.3"
        Description = "Audit Distribution Group Management"
        Subcategory = "{0cce9238-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.4"
        Description = "Audit Other Account Management Events"
        Subcategory = "{0cce923a-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.5"
        Description = "Audit Security Group Management"
        Subcategory = "{0cce9237-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.2.6"
        Description = "Audit User Account Management"
        Subcategory = "{0cce9235-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    ##---------------Detailed Tracking----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.3.1"
        Description = "Audit PNP Activity"
        Subcategory = "{0cce9248-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.3.2"
        Description = "Audit Process Creation"
        Subcategory = "{0cce922b-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    ##---------------DS Access----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.4.1"
        Description = "Audit Directory Service Access"
        Subcategory = "{0cce923b-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.4.2"
        Description = "Audit Directory Service Changes"
        Subcategory = "{0cce923c-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    ##---------------Log on/Log off----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.1"
        Description = "Audit Account Logout"
        Subcategory = "{0cce9217-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.2"
        Description = "Audit Group Membership"
        Subcategory = "{0cce9249-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.3"
        Description = "Audit Logoff"
        Subcategory = "{0cce9216-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.4"
        Description = "Audit Logon"
        Subcategory = "{0cce9215-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.5"
        Description = "Audit Other Logon/Logoff Events"
        Subcategory = "{0cce921c-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.5.6"
        Description = "Audit Special Logon"
        Subcategory = "{0cce921b-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    ##---------------Object Access----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.6.1"
        Description = "Audit Detailed File System"
        Subcategory = "{0cce9244-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.6.2"
        Description = "Audit File Share"
        Subcategory = "{0cce9224-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.6.3"
        Description = "Audit Other Object Access Events"
        Subcategory = "{0cce9227-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.6.4"
        Description = "Audit Removable Storage"
        Subcategory = "{0cce9245-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    }, 
    ##---------------Policy Change----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.1"
        Description = "Audit Audit Policy Change"
        Subcategory = "{0cce922f-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    }, 
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.2"
        Description = "Audit Authentication Policy Change"
        Subcategory = "{0cce9230-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.3"
        Description = "Audit Other Policy Change Events"
        Subcategory = "{0cce9231-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.4"
        Description = "Audit MPSSVC Rule-Level Policy Change"
        Subcategory = "{0cce9232-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
     [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.4"
        Description = "Audit MPSSVC Rule-Level Policy Change"
        Subcategory = "{0cce9232-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
     [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.4"
        Description = "Audit MPSSVC Rule-Level Policy Change"
        Subcategory = "{0cce9232-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    }, 
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.7.5"
        Description = "Audit Other Policy Change Events"
        Subcategory = "{0cce9234-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Failure"
    }, 
    ##---------------Privilege Use----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.8.1"
        Description = "Audit Sensitive Privilege Use"
        Subcategory = "{0cce9228-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    }, 
    ##---------------System----------------
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.9.1"
        Description = "Audit IPsec Driver"
        Subcategory = "{0cce9213-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    }, 
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.9.2"
        Description = "Audit Other System Events"
        Subcategory = "{0cce9214-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.9.3"
        Description = "Audit Security State Change"
        Subcategory = "{0cce9210-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.9.4"
        Description = "Audit Security System Extension"
        Subcategory = "{0cce9211-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success"
    },
    [PSCustomObject]@{
        Type = "AuditPol"
        CisId = "17.9.5"
        Description = "Audit System Integrity"
        Subcategory = "{0cce9212-69ae-11d9-bed3-505054503030}"
        ExpectedValue = "Success and Failure"
    }
)

$EventLogServiceAudit = @(
    [PSCustomObject]@{
        Type = "Registry"
        CisId = "18.10.26.1.1"
        Description = "Application: Control Event Log behavior when the log file reaches its maximum size"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
        Key = "Retention"
        PropertyType = "DWORD"
        CompareType = "Equals"
        ExpectedValue = 0
    },
    [PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.1.2"
    Description = "Application: Specify the maximum log file size (KB)"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
    Key = "MaxSize"
    PropertyType = "DWORD"
    CompareType = "Equals"
    ExpectedValue = 32768
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.2.1"
    Description = "Security: Control Event Log behavior when the log file reaches its maximum size"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
    Key = "Retention"
    PropertyType = "DWORD"
    CompareType = "Equals"
    ExpectedValue = 0
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.2.2"
    Description = "Security: Specify the maximum log file size (KB)"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
    Key = "MaxSize"
    PropertyType = "DWORD"
    CompareType = "Equals"
    ExpectedValue = 196608
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.3.1"
    Description = "Setup: Control Event Log behavior when the log file reaches its maximum size"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup"
    Key = "Retention"
    PropertyType = "DWORD"
    CompareType = "Equals"
    ExpectedValue = 0
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.3.2"
    Description = "Setup: Specify the maximum log file size (KB)"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup"
    Key = "MaxSize"
    PropertyType = "DWORD"
    CompareType = "EqualsorGreater"
    ExpectedValue = 32768
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.4.1"
    Description = "System: Control Event Log behavior when the log file reaches its maximum size"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"
    Key = "Retention"
    PropertyType = "DWORD"
    CompareType = "Equals"
    ExpectedValue = 0
},

[PSCustomObject]@{
    Type = "Registry"
    CisId = "18.10.26.4.2"
    Description = "System: Specify the maximum log file size (KB)"
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"
    Key = "MaxSize"
    PropertyType = "DWORD"
    CompareType = "EqualsorGreater"
    ExpectedValue = 32768
}

)
$Rules = $AuditRules + $AdvancedAuditRules + $EventLogServiceAudit

foreach ($Rule in $Rules) {

    $CurrentValue = $null
    $Status = "FAIL"

    if ($Rule.Type -eq "Registry") {

        try {

            $CurrentValue = Get-ItemPropertyValue `
                -Path $Rule.Path `
                -Name $Rule.Key `
                -ErrorAction Stop

            switch ($Rule.CompareType) {

                "Equals" {
                    if ($CurrentValue -eq $Rule.ExpectedValue) {
                        $Status = "PASS"
                    }
                }
                "EqualsOrGreater" {
                    if ($CurrentValue -ge $Rule.ExpectedValue) {
                        $Status = "PASS"
                    }
                }
            }
        }
        catch {
            $CurrentValue = "Not Found"
        }
    }

    elseif ($Rule.Type -eq "AuditPol") {

        try {

            $CurrentValue = auditpol /get /subcategory:"$($Rule.Subcategory)"
            $CurrentValue = ($CurrentValue | Out-String)

            if ($CurrentValue -match [regex]::Escape($Rule.ExpectedValue)) {
                $Status = "PASS"
            }
        }
        catch {
            $CurrentValue = "Error"
        }
    }

    $Results += [PSCustomObject]@{
        CIS_ID  = $Rule.CisId
        Type    = $Rule.Type
        Expected = $Rule.ExpectedValue
        Current = $CurrentValue
        Status  = $Status
    }
}

# =========================================
# SHOW RESULT
# =========================================
Write-Host "`n====================="
Write-Host "AUDIT COMPLETE"
Write-Host "Total Rules: $($Rules.Count)"
Write-Host "Total Results: $($Results.Count)"
Write-Host "====================="
$Results | Format-Table CIS_ID,Type,Expected,Status -AutoSize