$targetPath = "<path>" # Change this to your folder path
$checksumNotes = "[empty_checksum_notes]"
$notes = "[empty_notes]"

$files = Get-ChildItem -Path $targetPath -Recurse -File
$totalFiles = $files.Count
$counter = 0

# 4. Process files with Progress Bar
$results = foreach ($file in $files) {
    $counter++
    $percent = ($counter / $totalFiles) * 100

    # Update the Progress Bar in the console
    Write-Progress -Activity "Generating Hashes..." -Status "Processing: $($file.Name)" -PercentComplete $percent

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
        "Checksum UTC Timestamp" = $timestampUnix
        "Checksum Notes"     = $checksumNotes
        "Notes"              = $notes
    }
}

# 5. Convert to HTML and Fix Tags
$results | ConvertTo-Html -As Table | ForEach-Object {
    $_.Replace("&lt;", "<").Replace("&gt;", ">")
} | Out-File "HashReport.html"

Write-Host "`nFinished! Processed $totalFiles files." -ForegroundColor Green
Write-Host "Report saved to: $(Get-Location)\HashReport-$($timestampUnix).html" -ForegroundColor Cyan
