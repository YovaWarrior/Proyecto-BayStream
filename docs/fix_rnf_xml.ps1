# =============================================================================
# Fix RNF section by directly manipulating document.xml (no Word COM)
# =============================================================================
$ErrorActionPreference = "Stop"
$docxPath = "c:\Proyectos\proyecto-baystream\docs\Primer Entregable.docx"
$jsonPath = "c:\Proyectos\proyecto-baystream\docs\rf_data.json"
$tempDir = "c:\Proyectos\proyecto-baystream\docs\temp_docx"

$allData = Get-Content $jsonPath -Raw | ConvertFrom-Json
Write-Host "Loaded $($allData.rnfs.Count) RNFs"

# --- Step 1: Extract docx (it's a ZIP) ---
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($docxPath, $tempDir)
Write-Host "Extracted docx to $tempDir"

$xmlPath = Join-Path $tempDir "word\document.xml"
$xml = [System.IO.File]::ReadAllText($xmlPath)
Write-Host "document.xml size: $($xml.Length) chars"

# --- Step 2: Extract an existing RF table as template ---
# Find first <w:tbl> that contains "RF-001" to use as template
$rf001Idx = $xml.IndexOf('RF-001</w:t>')
if ($rf001Idx -lt 0) { $rf001Idx = $xml.IndexOf('RF-001') }
Write-Host "RF-001 text at index: $rf001Idx"

# Go backward to find the table start
$tblStart = $xml.LastIndexOf('<w:tbl>', $rf001Idx)
$tblEnd = $xml.IndexOf('</w:tbl>', $tblStart) + 8
$templateXml = $xml.Substring($tblStart, $tblEnd - $tblStart)
Write-Host "Template table: $($templateXml.Length) chars (from $tblStart to $tblEnd)"

# --- Step 3: Find the RNF section boundaries in XML ---
$rf035Idx = $xml.LastIndexOf('RF-035')
Write-Host "RF-035 last occurrence at: $rf035Idx"
$rf035TblEnd = $xml.IndexOf('</w:tbl>', $rf035Idx) + 8
Write-Host "RF-035 table ends at: $rf035TblEnd"

# End boundary: paragraph containing "Tipo de Muestreo" (next section after RNFs)
$tipoIdx = $xml.IndexOf('Tipo de Muestreo', $rf035TblEnd)
if ($tipoIdx -lt 0) {
    Write-Host "ERROR: Cannot find 'Tipo de Muestreo' end boundary"
    exit 1
}
$alcancesPStart = $xml.LastIndexOf('<w:p ', $tipoIdx)
Write-Host "End boundary paragraph at: $alcancesPStart"

$rnfContent = $xml.Substring($rf035TblEnd, $alcancesPStart - $rf035TblEnd)
Write-Host "RNF section to replace: $($rnfContent.Length) chars"

# --- Step 4: Build table XML for each RNF using template structure ---
# Parse the template to understand its structure, then generate new tables

# Helper function to build a requirement table XML
function Build-TableXml {
    param($id, $nombre, $descripcion, $entrada, $proceso, $salida, $criterios, $prioridad, $observaciones)
    
    # Escape XML special characters
    function Esc($t) { 
        if (-not $t) { return "" }
        $t = $t.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
        return $t
    }
    
    $id = Esc $id
    $nombre = Esc $nombre
    $descripcion = Esc $descripcion
    $entrada = Esc $entrada
    $proceso = Esc $proceso
    $salida = Esc $salida
    $criterios = Esc $criterios
    $prioridad = Esc $prioridad
    $observaciones = Esc $observaciones

    # Common run properties
    $boldWhiteRpr = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:b/><w:bCs/><w:color w:val="FFFFFF"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    $boldBlackRpr = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    $normalRpr = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    
    # Gray cell properties
    $grayCellPr = '<w:shd w:val="clear" w:color="auto" w:fill="808080"/>'
    
    # Table properties
    $tblPr = '<w:tblPr><w:tblStyle w:val="Tablaconcuadrcula"/><w:tblW w:w="5000" w:type="pct"/><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto"/></w:tblBorders><w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/></w:tblPr>'
    
    $tblGrid = '<w:tblGrid><w:gridCol w:w="2265"/><w:gridCol w:w="2265"/><w:gridCol w:w="2265"/><w:gridCol w:w="2265"/></w:tblGrid>'
    
    # Helper to make a header cell (gray bg, white bold text)
    function HeaderCell($text, $span) {
        $tcPr = "<w:tcPr>"
        if ($span -gt 1) { $tcPr += "<w:gridSpan w:val=`"$span`"/>" }
        $tcPr += "$grayCellPr<w:vAlign w:val=`"center`"/></w:tcPr>"
        return "<w:tc>$tcPr<w:p><w:pPr><w:jc w:val=`"center`"/>$boldWhiteRpr</w:pPr><w:r>$boldWhiteRpr<w:t xml:space=`"preserve`">$text</w:t></w:r></w:p></w:tc>"
    }
    
    # Helper to make a label cell (bold, centered)
    function LabelCell($text) {
        return "<w:tc><w:tcPr><w:vAlign w:val=`"center`"/></w:tcPr><w:p><w:pPr><w:jc w:val=`"center`"/>$boldBlackRpr</w:pPr><w:r>$boldBlackRpr<w:t xml:space=`"preserve`">$text</w:t></w:r></w:p></w:tc>"
    }
    
    # Helper to make a value cell (normal, spanning 3 cols)
    function ValueCell($text) {
        return "<w:tc><w:tcPr><w:gridSpan w:val=`"3`"/></w:tcPr><w:p><w:pPr>$normalRpr</w:pPr><w:r>$normalRpr<w:t xml:space=`"preserve`">$text</w:t></w:r></w:p></w:tc>"
    }
    
    # Row 1: Header row (ID: | value | Nombre: | value)
    $row1 = "<w:tr>" + (HeaderCell "ID:" 1) + (HeaderCell $id 1) + (HeaderCell "Nombre:" 1) + (HeaderCell $nombre 1) + "</w:tr>"
    
    # Rows 2-7: Label | Value (3 cols merged)
    $labels = @("Descripción", "Entrada", "Proceso", "Salida", "Criterios de Aceptación", "Prioridad")
    $values = @($descripcion, $entrada, $proceso, $salida, $criterios, $prioridad)
    
    $rows2to7 = ""
    for ($i = 0; $i -lt 6; $i++) {
        $rows2to7 += "<w:tr>" + (LabelCell $labels[$i]) + (ValueCell $values[$i]) + "</w:tr>"
    }
    
    # Row 8: Observaciones header (all 4 merged)
    $row8 = "<w:tr>" + (HeaderCell "Observaciones" 4) + "</w:tr>"
    
    # Row 9: Observaciones content (all 4 merged)
    $row9 = "<w:tr><w:tc><w:tcPr><w:gridSpan w:val=`"4`"/></w:tcPr><w:p><w:pPr>$normalRpr</w:pPr><w:r>$normalRpr<w:t xml:space=`"preserve`">$observaciones</w:t></w:r></w:p></w:tc></w:tr>"
    
    return "<w:tbl>$tblPr$tblGrid$row1$rows2to7$row8$row9</w:tbl>"
}

# --- Step 5: Generate replacement XML for entire RNF section ---
$replacementXml = ""

# Common paragraph properties for headings
$headingPpr = '<w:pPr><w:spacing w:before="240" w:after="120"/><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:pPr>'
$headingRpr = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'

foreach ($rnf in $allData.rnfs) {
    $headingText = "$($rnf.id) `u{2014} $($rnf.nombre)"
    $headingText = $headingText.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
    
    # Heading paragraph
    $replacementXml += "<w:p>$headingPpr<w:r>$headingRpr<w:t xml:space=`"preserve`">$headingText</w:t></w:r></w:p>"
    
    # Table
    $tableXml = Build-TableXml -id $rnf.id -nombre $rnf.nombre `
        -descripcion $rnf.descripcion -entrada $rnf.entrada `
        -proceso $rnf.proceso -salida $rnf.salida `
        -criterios $rnf.criterios -prioridad $rnf.prioridad `
        -observaciones $rnf.observaciones
    $replacementXml += $tableXml
    
    # Spacing paragraph after table
    $replacementXml += '<w:p><w:pPr><w:spacing w:after="120"/></w:pPr></w:p>'
    
    Write-Host "  Generated XML for $($rnf.id)"
}

Write-Host "Total replacement XML: $($replacementXml.Length) chars"

# --- Step 6: Replace RNF content in document.xml ---
$before = $xml.Substring(0, $rf035TblEnd)
$after = $xml.Substring($alcancesPStart)
$newXml = $before + $replacementXml + $after

Write-Host "New document.xml size: $($newXml.Length) chars (was $($xml.Length))"

# Save modified XML
[System.IO.File]::WriteAllText($xmlPath, $newXml, [System.Text.Encoding]::UTF8)
Write-Host "Saved modified document.xml"

# --- Step 7: Repack using BACKUP as ZIP base, replacing only document.xml ---
# The backup has proper forward-slash ZIP paths; we just swap document.xml
$backupPath = "c:\Proyectos\proyecto-baystream\docs\Primer Entregable_BACKUP.docx"

# Copy backup to output
$outputPath = "${docxPath}.new"
Copy-Item $backupPath $outputPath -Force

# Open as writable ZIP and replace document.xml
$zipArchive = [System.IO.Compression.ZipFile]::Open($outputPath, [System.IO.Compression.ZipArchiveMode]::Update)
$docEntry = $zipArchive.Entries | Where-Object { $_.FullName -eq "word/document.xml" }

if ($docEntry) {
    $docEntry.Delete()
    $newEntry = $zipArchive.CreateEntry("word/document.xml", [System.IO.Compression.CompressionLevel]::Optimal)
    $entryStream = $newEntry.Open()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($newXml)
    $entryStream.Write($bytes, 0, $bytes.Length)
    $entryStream.Close()
    Write-Host "Replaced document.xml ($($bytes.Length) bytes)"
} else {
    Write-Host "ERROR: document.xml not found in backup ZIP"
    $zipArchive.Dispose()
    exit 1
}

$zipArchive.Dispose()

# Replace original with new file
Remove-Item $docxPath -Force
Move-Item $outputPath $docxPath -Force
Write-Host "Final docx saved."

# Cleanup temp dir
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
Write-Host "Cleaned up"
Write-Host "`nDONE! All 8 RNFs have been inserted as tables."
