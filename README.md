
# Power BI REST API PowerShell Toolkit

## Overview
This repository contains a **PowerShell-based toolkit** designed to automate and simplify tasks for **Power BI** using the **Power BI REST API**.  
It is built around a **main script** that acts as a menu-driven interface. From this interface, users can select different actions, which then trigger other PowerShell scripts to perform specific operations.

## How It Works
1. **Main Script as Entry Point**  
   - The toolkit starts with a single main script that presents a **menu** of available actions.
   - Based on the user’s selection, the main script calls the corresponding PowerShell sub-script.

2. **Authentication Options**  
   The toolkit supports two authentication modes:
   - **Administrator Login**  
     - Log in interactively with your Power BI admin account.
   - **Registered App Authentication**  
     - Uses an **Azure AD registered app** to obtain tokens for the Power BI REST API.
     - Secrets for the registered app (Client ID, Client Secret, etc.) are stored securely in **Azure Key Vault**.

3. **Azure Key Vault Integration**  
   - When using registered app authentication, the script retrieves credentials from **Azure Key Vault**.
   - Required parameters include:
     - **Key Vault name**
     - **Secret names** for the registered app credentials
   - The user running the script must have **access to the Key Vault**.  
     *(The app itself does not access the vault; the logged-in user does.)*

4. **Configuration File**  
   - The repository includes an example configuration file named:  
     `example-configuration-file.json`
   - If you are using **registered app authentication** and **Azure Key Vault**, you must:
     - Rename this file to:  
       `configuration-file.json`
     - Update the example values with your actual configuration details.
   - The main script will look for this file in the **root of the repository** to read parameters such as Key Vault name and secret names.

5. **Token Retrieval and API Calls**  
   - After obtaining credentials, the script requests an **access token** from **Microsoft Entra ID**.
   - The token is then used to authenticate against the **Power BI REST API**.
   - Subsequent scripts perform the selected operations using this token.

## Requirements
- **PowerShell 5.1 or later**
- **Power BI PowerShell module** (e.g., `MicrosoftPowerBIMgmt`)
- **Azure Key Vault** for storing secrets
- Access to **Azure AD** for authentication

## Getting Started
1. Clone this repository.
2. Ensure you have **PowerShell 5.1+** and the required modules installed.
3. Configure your **Azure Key Vault** and store the necessary secrets.
4. Rename and edit the configuration file:
   - From `example-configuration-file.json`  
   - To `configuration-file.json`  
   - Update it with your actual Key Vault and secret details.
5. Run the main script and follow the menu prompts.