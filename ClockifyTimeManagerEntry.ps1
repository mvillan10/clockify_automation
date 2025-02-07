# Set console window title
[Console]::Title = "Clockify Time Entries Manager"

# File storing last run date
$lastRunDateFile = "$PSScriptRoot\LastRunDate.txt"

# Function to get a valid date from user input
function Get-ValidDate($prompt, $defaultValue = $null) {
    while ($true) {
        $message = $prompt
        if ($defaultValue) { $message += " [$defaultValue]" }  # Show default in brackets
        $dateInput = Read-Host "`n$message"

        if ([string]::IsNullOrWhiteSpace($dateInput)) {
            return [DateTime]::ParseExact($defaultValue, "yyyy-MM-dd", $null)
        }
        try {
            return [DateTime]::ParseExact($dateInput, "yyyy-MM-dd", $null)
        } catch {
            Write-Host "Invalid date format. Please enter in YYYY-MM-DD format.`n" -ForegroundColor Red
        }
    }
}

# Function to read last run date
function Get-LastRunDate {
    if (Test-Path $lastRunDateFile) {
        $dateString = Get-Content $lastRunDateFile -Raw
        try { return [DateTime]::ParseExact($dateString, "yyyy-MM-dd", $null) }
        catch { return $null }
    }
    return $null
}

# Read last run date if available
$lastRunDate = Get-LastRunDate

# Prompt for Start Date (show last run date if available)
$startDate = Get-ValidDate "Enter Start Date (YYYY-MM-DD) or press Enter to use last run date" $lastRunDate.toString("yyyy-MM-dd")

if (-not $startDate) {
    Write-Host "No valid last run date found. You must enter a start date.`n" -ForegroundColor Yellow
    $startDate = Get-ValidDate "Enter Start Date (YYYY-MM-DD)"
}

# Prompt for End Date (default is today's date)
$todayDate = Get-Date
$endDate = Get-ValidDate "Enter End Date (YYYY-MM-DD) or press Enter to use today's date" $todayDate.ToString("yyyy-MM-dd")

# Convert dates to string format
$startDateStr = $startDate.ToString("yyyy-MM-dd")
$endDateStr = $endDate.ToString("yyyy-MM-dd")

# Show confirmation message
Write-Host "`nProcessing entries from $startDateStr to $endDateStr...`n" -ForegroundColor Cyan

# Call main script directly
& "$PSScriptRoot\ClockifyTimeManager.ps1" -ipStartDate $startDateStr -ipEndDate $endDateStr

# Pause to keep console open
Write-Host "`nPress Enter to exit..."
Read-Host
