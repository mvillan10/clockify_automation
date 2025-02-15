param (
    [string]$ipStartDate,
    [string]$ipEndDate
)

# Load environment variables from .env file
$envFilePath = "$PSScriptRoot\.env"
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        if ($_ -match "^\s*([^#\s]+?)\s*=\s*(.+?)\s*$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
} else {
    Write-Host "Environment file (.env) not found." -ForegroundColor Red
    exit
}

# Define Clockify workspace, user, project, and task IDs
$apiKey = [System.Environment]::GetEnvironmentVariable("API_KEY")
$workspaceId = [System.Environment]::GetEnvironmentVariable("WORKSPACE_ID")
$userId = [System.Environment]::GetEnvironmentVariable("USER_ID")
$projectId = [System.Environment]::GetEnvironmentVariable("PROJECT_ID")
$taskId = [System.Environment]::GetEnvironmentVariable("TASK_ID")

# Define API URLs
$baseUrl = "https://api.clockify.me/api/v1"
$fetchUrl = "$baseUrl/workspaces/$workspaceId/user/$userId/time-entries"
$addUrl = "$baseUrl/workspaces/$workspaceId/time-entries"

# File to store last run date
$lastRunDateFile = "$PSScriptRoot\LastRunDate.txt"

# API Headers
$headers = @{
    "Content-Type" = "application/json"
    "x-api-key" = $apiKey
}

# Validate and convert dates
try {
    $startDate = [DateTime]::ParseExact($ipStartDate, "yyyy-MM-dd", $null)
    $endDate = [DateTime]::ParseExact($ipEndDate, "yyyy-MM-dd", $null)
} catch {
    Write-Host "Invalid date format. Please ensure dates are in YYYY-MM-DD format.`n" -ForegroundColor Red
    exit
}

# Step 1: Fetch all existing entries
$fetchStartDate = $startDate.ToString("yyyy-MM-dd")
$fetchEndDate = $endDate.ToString("yyyy-MM-dd")

Write-Host "Fetching existing entries from $fetchStartDate to $fetchEndDate...`n" -ForegroundColor Cyan
try {
    $entries = Invoke-RestMethod -Uri "${fetchUrl}?start=$fetchStartDate`T00:00:00Z&end=$fetchEndDate`T23:59:59Z" -Method Get -Headers $headers
    $entryIds = $entries | ForEach-Object { $_.id }
    if ($entryIds.Count -eq 0) {
        Write-Host "Fetched no entries.`n" -ForegroundColor Cyan
    } else {
        Write-Host "Fetched $($entryIds.Count) entries.`n" -ForegroundColor Green
    }
} catch {
    Write-Host "Error fetching entries: $($_.Exception.Message)`n" -ForegroundColor Red
    Write-Host "API URL: ${fetchUrl}?start=$fetchStartDate`T00:00:00Z&end=$fetchEndDate`T23:59:59Z`n" -ForegroundColor Cyan
    $entryIds = @()
}

# Step 2: Delete all fetched entries
if ($entryIds.Count -gt 0) {
    Write-Host "Deleting entries...`n" -ForegroundColor Yellow
    try {
        $deleteUrl = "${fetchUrl}?time-entry-ids=" + ($entryIds -join "&time-entry-ids=")
        $deleteResonse = Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
        Write-Host "Deleted all fetched entries successfully.`n" -ForegroundColor Green
    } catch {
        Write-Host "Error deleting entries: $($_.Exception.Message)`n" -ForegroundColor Red
        Write-Host "API URL: $deleteUrl`n" -ForegroundColor Cyan
    }
} else {
    Write-Host "No entries to delete.`n" -ForegroundColor Green
}

# Step 3: Add new entries for weekdays
Write-Host "Adding new entries...`n" -ForegroundColor Cyan
$currentDate = $startDate
while ($currentDate -le $endDate) {
    $formattedDate = $currentDate.ToString("yyyy-MM-dd")

    if ($currentDate.DayOfWeek -notin @("Saturday", "Sunday")) {
        $body = @{
            "billable" = $true
            "start" = "${formattedDate}T06:30:00Z"
            "end" = "${formattedDate}T15:30:00Z"
            "projectId" = $projectId
            "taskId" = $taskId
            "type" = "REGULAR"
        } | ConvertTo-Json -Depth 3

        try {
            $addResponse = Invoke-RestMethod -Uri ${addUrl} -Method Post -Headers $headers -Body $body
            Write-Host "Added entry for ${formattedDate}`n" -ForegroundColor Green
            $formattedDate | Out-File -FilePath $lastRunDateFile -NoNewline
        } catch {
            Write-Host "Error adding entry for ${formattedDate}: $($_.Exception.Message)`n" -ForegroundColor Red
            Write-Host "API URL: $addUrl Body: $body`n" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Skipping weekend: ${formattedDate}`n" -ForegroundColor Gray
    }
    $currentDate = $currentDate.AddDays(1)
}

Write-Host "`nScript execution completed." -ForegroundColor Green
