<#
.SYNOPSIS
  Reads a JSON configuration file, merges it with default values,
  and outputs batch SET commands for each configuration entry.
.PARAMETER ConfigFilePath
  The mandatory path to the config.json file.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ConfigFilePath
)

# Define default configuration
$defaultConfig = @{
    project_name = "Cpp26Project"
    cpp_version = "26"
    llvm_version = "20.1.4"
    cmake_version = "3.27.8"
    vcpkg_commit = "2023.10.19"
    hot_reload_enabled = $true # PowerShell boolean
    modules_enabled = $true    # PowerShell boolean
    setup_date = ""            # Default for setup_date if not present
}

# Initialize the working configuration by copying the defaultConfig
$currentConfig = $defaultConfig.Clone()

# Check if the configuration file exists
if (Test-Path -Path $ConfigFilePath -PathType Leaf) {
    try {
        $jsonContent = Get-Content -Path $ConfigFilePath -Raw -ErrorAction Stop
        $fileConfig = $jsonContent | ConvertFrom-Json -ErrorAction Stop

        # Iterate through the keys in defaultConfig to ensure we only process expected keys
        # and maintain the structure of defaultConfig.
        foreach ($key in $defaultConfig.Keys) {
            if ($fileConfig.PSObject.Properties.Name -contains $key) {
                $currentConfig[$key] = $fileConfig.$key
            }
        }
    }
    catch [System.Management.Automation.PSArgumentException] {
        # Catch errors from Get-Content if file is empty or other read issues before ConvertFrom-Json
        Write-Error "Error: Problem reading file '$ConfigFilePath'. It might be empty or inaccessible."
        exit 1
    }
    catch { # Catches errors from ConvertFrom-Json (e.g., malformed JSON)
        Write-Error "Error: Malformed JSON in '$ConfigFilePath'."
        # Specific error details can be found in $_.Exception.Message
        # For example: Write-Error "Details: $($_.Exception.Message)"
        exit 1
    }
}
# If ConfigFilePath does not exist, we proceed with defaultConfig values.

# Output Batch SET commands
foreach ($key in $currentConfig.Keys) {
    $value = $currentConfig[$key]
    $outputValue = ""

    if ($value -is [bool]) {
        $outputValue = if ($value) { "true" } else { "false" }
    } elseif ($value -eq $null) {
        $outputValue = "" # Output empty string for null values (like setup_date default)
    } else {
        $outputValue = $value.ToString()
    }
    
    # Convert key to uppercase for the SET command variable name
    $envVarName = "CONFIG_" + $key.ToUpper()
    Write-Output "SET $envVarName=$outputValue"
}

exit 0
