param(
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    [Parameter(Mandatory=$true)]
    [int]$dataset_num
)
Write-Host "Starting..."

$checksumNotes = "[empty_checksum_notes]"
$notes = "[empty_notes]"
$BaseDOJLink = "https://www.justice.gov/epstein/files/DataSet%20$($dataset_num)/"


Write-Host "Getting file list..."
$files = Get-ChildItem -Path $targetPath -Recurse -File
$totalFiles = $files.Count
Write-Host "$($totalFiles) files found. Beginning run..."
$counter = 0

# 4. Process files with Progress Bar
$results = foreach ($file in $files) {
    $counter++
    $percent = ($counter / $totalFiles) * 100

    # Update the Progress Bar in the console
    Write-Progress -Activity "Generating Hash $($counter) of $($totalFiles) ..." -Status "Processing: $($file.Name)" -PercentComplete $percent

    $relativePath = Resolve-Path $file.FullName -Relative
    $timestamp = [DateTime]::UtcNow.ToString('u')
    $timestampUnix = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()

    [PSCustomObject]@{
        "File Name"          = $file.Name
        "Relative Path"      = $relativePath
        "Size (in bytes)"    = $file.Length
        "MD5"                = "<code>$((Get-FileHash $file.FullName -Algorithm MD5).Hash)</code>"
        "SHA1"               = "<code>$((Get-FileHash $file.FullName -Algorithm SHA1).Hash)</code>"
        "Checksum UTC Timestamp" = $timestamp
        "Checksum Unix Timestamp" = $timestampUnix
        "Checksum Notes"     = $checksumNotes
        "Notes"              = $notes
        "Theoretical DOJ Link" = '<a href='+$($BaseDOJLink + $file.Name)+'>'+$($file.Name)+'</a>'
    }
}

# 5. Convert to HTML and Fix Tags
$results | ConvertTo-Html -As Table | ForEach-Object {
    $_.Replace("&lt;", "<").Replace("&gt;", ">")
} | Out-File "HashReport-$($timestampUnix).html"

Write-Host "`nFinished! Processed $totalFiles files." -ForegroundColor Green
Write-Host "Report saved to: $(Get-Location)\HashReport-$($timestampUnix).html" -ForegroundColor Cyan
