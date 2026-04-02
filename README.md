# Intune-Dashboard
Custom-built Intune reporting dashboard
****
Intune Dashboard (PowerShell + Microsoft Graph)
A custom-built Intune reporting dashboard written in PowerShell that uses Microsoft Graph and PSWriteHTML to generate a modern, interactive HTML overview of all Intune‑managed devices.
This script was fully rewritten and extended to provide a single‑page, executive‑friendly dashboard while still offering deep, audit‑ready device inventory tables for administrators.

✨ Features

📊 At‑a‑glance dashboard

Device counts by OS (Windows, macOS, Android, iOS, Linux)
Inactive devices (≥ 30 days)
Devices with low disk space


🖥️ Full device inventory

Includes Serial Number in all tables
Device name, model, OS version, primary user, and more


🛡️ Security & compliance visibility

Defender disabled devices
BitLocker / disk encryption status
Non‑compliant devices
Azure AD registered vs unregistered devices


👤 Ownership insights

Company vs personal devices


🎨 Modern UI

Unicode emoji icons for OS visualization
Collapsible sections
Searchable, pageable data tables


🔐 Secure authentication

Uses Microsoft Graph app‑only authentication (client credentials)
No interactive login required


📄 Portable output

Generates a standalone HTML file
Easy to host, email, or archive




🔧 How It Works

Authenticates to Microsoft Graph using an Azure AD app registration
Retrieves all Intune managed devices via Get-MgDeviceManagementManagedDevice
Processes and categorizes devices (OS, compliance, encryption, activity, storage)
Builds a rich, interactive HTML dashboard using PSWriteHTML
Outputs a single HTML file for viewing or sharing


📦 Requirements

PowerShell 5.1 or PowerShell 7+
Microsoft Graph PowerShell SDK
PSWriteHTML module
Azure AD App Registration with at least:

DeviceManagementManagedDevices.Read.All




🚀 Use Cases

Daily or weekly Intune health reporting
Security and compliance reviews
Helpdesk and desktop team visibility
Management‑level device overview
Pre‑audit and hygiene checks


📝 Notes

This script is not an official Microsoft solution
It is intended as an admin‑driven reporting and visibility tool
Designed to be easily extended for additional metrics or filters


🙌 Credits

Microsoft Graph for Intune data access
PSWriteHTML by Przemysław Kłys (Evotec) for the HTML framework
