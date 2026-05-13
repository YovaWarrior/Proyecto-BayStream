# Extract RF data from docx and save to JSON for later use by Word COM script
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead("c:\Proyectos\proyecto-baystream\docs\Primer Entregable.docx")
$entry = $zip.Entries | Where-Object { $_.FullName -eq "word/document.xml" }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$content = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()

$plainText = $content -replace '<[^>]+>', ' '
$plainText = $plainText -replace '\s+', ' '

# Find all RF blocks
$allRfStarts = @()
$si = 0
while (($i = $plainText.IndexOf('ID: RF-', $si)) -ge 0) { $allRfStarts += $i; $si = $i + 1 }

# Also find RNF blocks
$allRnfStarts = @()
$si = 0
while (($i = $plainText.IndexOf('ID: RNF-', $si)) -ge 0) { $allRnfStarts += $i; $si = $i + 1 }

Write-Host "Found $($allRfStarts.Count) RFs, $($allRnfStarts.Count) RNFs"

# Parse each RF
function Parse-Requirement($text) {
    $data = @{}
    if ($text -match 'ID:\s*(R[NF]+-\d{3})') { $data.id = $Matches[1] }
    if ($text -match 'Nombre:\s*(.*?)\s*Descripci') { $data.nombre = $Matches[1].Trim() }
    if ($text -match 'Descripci[oó]n\s*:?\s*(.*?)\s*Entrada\s*:') { $data.descripcion = $Matches[1].Trim() }
    if ($text -match 'Entrada\s*:\s*(.*?)\s*Proceso\s*:') { $data.entrada = $Matches[1].Trim() }
    if ($text -match 'Proceso\s*:\s*(.*?)\s*Salida\s*:') { $data.proceso = $Matches[1].Trim() }
    if ($text -match 'Salida\s*:\s*(.*?)\s*Criterios de Aceptaci') { $data.salida = $Matches[1].Trim() }
    if ($text -match 'Criterios de Aceptaci[oó]n\s*:?\s*(.*?)\s*Prioridad\s*:') { $data.criterios = $Matches[1].Trim() }
    if ($text -match 'Prioridad\s*:\s*(.*?)\s*\.?\s*Observaciones\s*:') { $data.prioridad = $Matches[1].Trim() }
    if ($text -match 'Observaciones\s*:\s*(.*)') { $data.observaciones = $Matches[1].Trim() }
    return $data
}

$rfList = @()
for ($k = 0; $k -lt $allRfStarts.Count; $k++) {
    $start = $allRfStarts[$k]
    $end = if ($k+1 -lt $allRfStarts.Count) { $allRfStarts[$k+1] } else { $plainText.IndexOf('Requerimientos No Funcionales', $start) }
    if ($end -le $start) { $end = $start + 5000 }
    $rfText = $plainText.Substring($start, [Math]::Min($end - $start, 5000))
    $parsed = Parse-Requirement $rfText
    $rfList += $parsed
    Write-Host "  $($parsed.id): $($parsed.nombre)"
}

$rnfList = @()
for ($k = 0; $k -lt $allRnfStarts.Count; $k++) {
    $start = $allRnfStarts[$k]
    $end = if ($k+1 -lt $allRnfStarts.Count) { $allRnfStarts[$k+1] } else { $plainText.IndexOf('Alcances y', $start) }
    if ($end -le $start) { $end = $start + 5000 }
    $rnfText = $plainText.Substring($start, [Math]::Min($end - $start, 5000))
    $parsed = Parse-Requirement $rnfText
    $rnfList += $parsed
    Write-Host "  $($parsed.id): $($parsed.nombre)"
}

$allData = @{ rfs = $rfList; rnfs = $rnfList }
$allData | ConvertTo-Json -Depth 4 | Out-File "c:\Proyectos\proyecto-baystream\docs\rf_data.json" -Encoding UTF8
Write-Host "`nSaved $($rfList.Count) RFs and $($rnfList.Count) RNFs to rf_data.json"
