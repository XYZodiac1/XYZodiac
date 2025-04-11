# SMB Share Enumerator

A simple Bash script to enumerate SMB shares on a target system, identifying **readable** and/or **writable** shares. It uses `smbclient` under the hood and supports **anonymous** or **credentialed** access.

---

## 🔍 Purpose

This tool helps security professionals, penetration testers, and red teamers **quickly identify misconfigured SMB shares** that allow:

- Unauthorized **read** access (sensitive data disclosure)
- Unauthorized **write** access (potential for privilege escalation, lateral movement, or persistence)

It simplifies and automates a common SMB enumeration workflow that would normally require manual steps.

---

## 🚀 Features

- 📡 Accepts an IP target as first parameter
- 🔐 Supports anonymous access or `-u USER -p PASS` credentials
- 📂 Lists only shares that are **readable** or **writable**
- 🧾 Prints contents of readable shares
- 🛠️ Cleans up test files from writable shares
- ✅ Works with Kali Linux, Parrot OS, Ubuntu, etc.

---

## 🧰 Requirements

- `smbclient` must be installed
- Bash environment (Linux or WSL)

Install `smbclient` if needed:
```bash
sudo apt install smbclient
```

## 🧪 Usage

Using the tool:
```bash
chmod +x smb_enum_flex.sh
./smb_enum_flex.sh <IP> [-u username -p password]
```

Example:
```bash
./smb_enum_flex.sh 10.10.10.10
./smb_enum_flex.sh 10.10.10.10 -u admin -p admin
```
