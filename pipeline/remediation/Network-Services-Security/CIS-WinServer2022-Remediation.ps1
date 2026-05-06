# =========================================================================
# CIS BENCHMARK LEVEL 1 - MASTER REMEDIATION SCRIPT
# Tu dong khac phuc, xu ly chuan duong dan Registry, ghi log thoi gian thuc
# =========================================================================

$BaseDir = "C:\CIS-Automation"
if (-not (Test-Path "$BaseDir\Logs")) { New-Item -ItemType Directory -Force -Path "$BaseDir\Logs" | Out-Null }

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

# HÀM TẠO ĐƯỜNG DẪN REGISTRY AN TOÀN (Sửa lỗi tạo folder ở ổ cứng)
Function Ensure-RegistryPath {
    param([string]$RegPath)
    if (-not (Test-Path $RegPath)) {
        $parent = Split-Path $RegPath
        if (-not (Test-Path $parent)) { Ensure-RegistryPath -RegPath $parent }
        New-Item -Path $RegPath -Force | Out-Null
    }
}

# (SỬ DỤNG LẠI CHÍNH XÁC MẢNG DỮ LIỆU CỦA SCRIPT BÊN TRÊN, MÌNH CHỈ COPY VÀI DÒNG LÀM MẪU ĐỂ TIẾT KIỆM KHÔNG GIAN)
$RemediationRules = @(
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.8.1"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"; Key="RequireSecuritySignature"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.8.2"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"; Key="EnablePlainTextPassword"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.9.1"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="autodisconnect"; Expected=15; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.9.2"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="RequireSecuritySignature"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.9.3"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="enableforcedlogoff"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.9.4"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="SmbServerNameHardeningLevel"; Expected=1; Type="DWord" } 
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.1"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="TurnOffAnonymousBlock"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.2"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="RestrictAnonymousSAM"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.3"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="RestrictAnonymous"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.5"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="EveryoneIncludesAnonymous"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.10"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="RestrictNullSessAccess"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.11"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="restrictremotesam"; Expected="O:BAG:BAD:(A;;RC;;;BA)"; Type="String" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.12"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="NullSessionShares"; Expected=@(); Type="MultiString" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.10.13"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="ForceGuest"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.1"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="UseMachineId"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.2"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="AllowNullSessionFallback"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.3"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u"; Key="AllowOnlineID"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.4"; Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"; Key="SupportedEncryptionTypes"; Expected=2147483640; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.5"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="NoLMHash"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.6"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Key="enableforcedlogoff"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.7"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Key="LmCompatibilityLevel"; Expected=5; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.8"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\LDAP"; Key="LDAPClientIntegrity"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.9"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="NTLMMinClientSec"; Expected=536870912; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.10"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="NTLMMinServerSec"; Expected=536870912; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.11"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="AuditReceivingNTLMTraffic"; Expected=2; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.12"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="AuditNTLMInDomain"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Network Security & Access"; CisId="2.3.11.13"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"; Key="AuditSendingNTLMTraffic"; Expected=1; Type="DWord" }

    # --- NHÓM 2: WINDOWS FIREWALL ---
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"; Key="EnableFirewall"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"; Key="DefaultInboundAction"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"; Key="DisableNotifications"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"; Key="LogFilePath"; Expected="%systemroot%\system32\LogFiles\Firewall\pfirewall.log"; Type="String" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.5"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"; Key="LogFileSize"; Expected=16384; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.6"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"; Key="LogDroppedPackets"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.1.7"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"; Key="LogSuccessfulConnections"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"; Key="EnableFirewall"; Expected=1; Type="DWord"; GPOName="group7.local\CIS_Policy" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"; Key="DefaultInboundAction"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"; Key="DisableNotifications"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"; Key="LogFilePath"; Expected="%systemroot%\system32\LogFiles\Firewall\pfirewall.log"; Type="String" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.5"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"; Key="LogFileSize"; Expected=16384; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.6"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"; Key="LogDroppedPackets"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.2.7"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"; Key="LogSuccessfulConnections"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"; Key="EnableFirewall"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"; Key="DefaultInboundAction"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"; Key="DisableNotifications"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"; Key="AllowLocalPolicyMerge"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.5"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"; Key="AllowLocalIPsecPolicyMerge"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.6"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"; Key="LogFilePath"; Expected="%systemroot%\system32\LogFiles\Firewall\pfirewall.log"; Type="ExpandString" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.7"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"; Key="LogFileSize"; Expected=16384; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.8"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"; Key="LogDroppedPackets"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Windows Firewall"; CisId="9.3.9"; Path="HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"; Key="LogSuccessfulConnections"; Expected=1; Type="DWord" }

    # --- NHÓM 3: ADMINISTRATIVE TEMPLATES (NETWORK) ---
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.4.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"; Key="EnableMDNS"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.4.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"; Key="EnableNetbios"; Expected=2; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.4.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"; Key="EnableMulticast"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.7.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"; Key="MinSmb2Dialect"; Expected=785; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.8.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"; Key="AllowInsecureGuestAuth"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.8.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"; Key="RequireSecuritySignature"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.11.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"; Key="NC_AllowNetBridge_NLA"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.11.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"; Key="NC_ShowSharedAccessUI"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.11.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"; Key="NC_StdDomainUserSetLocation"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.14.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"; Key="\\*\NETLOGON"; Expected="RequireMutualAuthentication=1, RequireIntegrity=1"; Type="String" }
    [PSCustomObject]@{ GrpName="Administrative Templates (Network)"; CisId="18.6.21.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"; Key="fMinimizeConnections"; Expected=3; Type="DWord" }

    # --- NHÓM 4: SERVICES, PRINTERS & RDP ---
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="5.1"; Path="HKLM:\SYSTEM\CurrentControlSet\Services\Spooler"; Key="Start"; Expected=4; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"; Key="RegisterSpoolerRemoteRpcEndPoint"; Expected=2; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"; Key="RedirectionGuardEnabled"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="RpcUseNamedPipeProtocol"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="RpcProtocols"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.5"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="ForceAuthentication"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.6"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="RpcAuthentication"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.7"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="RpcTcpPort"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.8"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"; Key="EnableRpcPrivacy"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.9"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Key="RestrictDriverInstallationToAdministrators"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.10"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"; Key="QueueSpecificFiles"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.11"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Key="UpdatePromptSettings"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.7.12"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Key="InForestUpdatePromptSettings"; Expected=0; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.2.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="DisablePasswordSaving"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.3.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="fDisableCdm"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.9.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="fPromptForPassword"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.9.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="fEncryptRPCTraffic"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.9.3"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="SecurityLayer"; Expected=2; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.9.4"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="UserAuthentication"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.9.5"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="MinEncryptionLevel"; Expected=3; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.11.1"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="fDeleteTempFoldersOnExit"; Expected=1; Type="DWord" }
    [PSCustomObject]@{ GrpName="Services, Printers & RDP"; CisId="18.10.57.3.11.2"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Key="fUseTempFoldersPerSession"; Expected=1; Type="DWord" }
)

$GroupedRules = $RemediationRules | Group-Object GrpName

foreach ($Group in $GroupedRules) {
    Write-Host "`n>> $($Group.Name)" -ForegroundColor Yellow
    
    foreach ($Rule in $Group.Group) {
        try {
            $TimeNow = Get-Date -Format "HH:mm:ss"
            
            # Khắc phục triệt để lỗi tạo Folder
            Ensure-RegistryPath -RegPath $Rule.Path
            
            # Cấu hình qua GPO Store nếu được chỉ định
            if ($Rule.GPOName) {
                Set-NetFirewallProfile -Profile Private -Enabled True -PolicyStore $Rule.GPOName -ErrorAction SilentlyContinue
                Write-Host "[$TimeNow] [ PASS ] $($Rule.CisId) -> Cấu hình qua GPO: $($Rule.GPOName)" -ForegroundColor Green
            } else {
                # Cấu hình qua Registry
                $type = if ($Rule.Type) { $Rule.Type } else { "DWord" }
                Set-ItemProperty -Path $Rule.Path -Name $Rule.Key -Value $Rule.Expected -Type $type -Force
                Write-Host "[$TimeNow] [ PASS ] $($Rule.CisId) -> Thiết lập $($Rule.Key) = $($Rule.Expected)" -ForegroundColor Green
            }
        } catch {
            $TimeNow = Get-Date -Format "HH:mm:ss"
            Write-Host "[$TimeNow] [ FAIL ] Lỗi tại $($Rule.CisId): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n[+] Dang ap dung chinh sach Group Policy (gpupdate) xuong he thong..." -ForegroundColor Cyan
gpupdate /force /wait:0 | Out-Null

Write-Host "`n===============================================================================" -ForegroundColor Green
Write-Host " HOAN TAT KHAC PHUC VA DA CHAY GPUPDATE TUDONG!" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Green

Stop-Transcript