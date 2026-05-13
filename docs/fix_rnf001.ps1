$ErrorActionPreference = "Stop"
$filePath = "c:\Proyectos\proyecto-baystream\docs\Primer Entregable.docx"
$jsonPath = "c:\Proyectos\proyecto-baystream\docs\rf_data.json"
$allData = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$rnf001 = $allData.rnfs | Where-Object { $_.id -eq "RNF-001" }

Write-Host "RNF-001: $($rnf001.nombre)"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Open($filePath)
    Write-Host "Opened doc: $($doc.Paragraphs.Count) paragraphs"

    $grayBg = 8421504
    $whiteColor = 16777215
    $blackColor = 0

    # Find RNF-002 heading to insert RNF-001 before it
    $findRange = $doc.Content.Duplicate
    $findRange.Find.ClearFormatting()
    $findRange.Find.Text = "RNF-002"
    $findRange.Find.Forward = $true
    $findRange.Find.Wrap = 0

    $found = $false
    while ($findRange.Find.Execute()) {
        $pText = $findRange.Paragraphs(1).Range.Text.Trim()
        if ($pText -match 'PAGEREF') {
            $findRange.Start = $findRange.End
            $findRange.End = $doc.Content.End
            continue
        }
        try {
            $dummy = $findRange.Tables(1)
            $findRange.Start = $findRange.End
            $findRange.End = $doc.Content.End
            continue
        } catch {}
        $found = $true
        break
    }

    if (-not $found) {
        Write-Host "ERROR: Could not find RNF-002 heading"
        return
    }

    $rnf002Para = $findRange.Paragraphs(1)
    $insertPos = $rnf002Para.Range.Start
    Write-Host "Found RNF-002 heading at pos: $insertPos"

    # Insert heading for RNF-001
    $headingRange = $doc.Range($insertPos, $insertPos)
    $headingRange.InsertBefore("RNF-001 " + [char]0x2014 + " " + $rnf001.nombre + "`r")
    $headingRange = $doc.Range($insertPos, $insertPos + ("RNF-001 " + [char]0x2014 + " " + $rnf001.nombre).Length + 1)
    $headingRange.Font.Name = "Arial"
    $headingRange.Font.Size = 12
    $headingRange.Font.Bold = $true
    $headingRange.Font.Color = $blackColor
    $headingRange.ParagraphFormat.SpaceBefore = 12
    $headingRange.ParagraphFormat.SpaceAfter = 6
    Write-Host "Inserted RNF-001 heading"

    # Now insert table after heading
    $tablePos = $headingRange.End + 1
    $tableRange = $doc.Range($tablePos, $tablePos)

    $table = $doc.Tables.Add($tableRange, 9, 4)
    $table.Borders.Enable = $true
    $table.Borders.OutsideLineStyle = 1
    $table.Borders.InsideLineStyle = 1
    $table.AllowAutoFit = $true
    try {
        $table.Columns(1).PreferredWidth = 25
        $table.Columns(2).PreferredWidth = 25
        $table.Columns(3).PreferredWidth = 25
        $table.Columns(4).PreferredWidth = 25
    } catch {}

    # Row 1: Header
    for ($c = 1; $c -le 4; $c++) {
        $cell = $table.Cell(1, $c)
        $cell.Shading.BackgroundPatternColor = $grayBg
        $cell.Range.Font.Bold = $true
        $cell.Range.Font.Color = $whiteColor
        $cell.Range.Font.Name = "Arial"
        $cell.Range.Font.Size = 12
        $cell.VerticalAlignment = 1
    }
    $table.Cell(1, 1).Range.Text = "ID:"
    $table.Cell(1, 1).Range.ParagraphFormat.Alignment = 1
    $table.Cell(1, 2).Range.Text = $rnf001.id
    $table.Cell(1, 3).Range.Text = "Nombre:"
    $table.Cell(1, 3).Range.ParagraphFormat.Alignment = 1
    $table.Cell(1, 4).Range.Text = $rnf001.nombre

    $labels = @("Descripcion", "Entrada", "Proceso", "Salida", "Criterios de Aceptacion", "Prioridad")
    $values = @(
        $(if($rnf001.descripcion){$rnf001.descripcion}else{""}),
        $(if($rnf001.entrada){$rnf001.entrada}else{""}),
        $(if($rnf001.proceso){$rnf001.proceso}else{""}),
        $(if($rnf001.salida){$rnf001.salida}else{""}),
        $(if($rnf001.criterios){$rnf001.criterios}else{""}),
        $(if($rnf001.prioridad){$rnf001.prioridad}else{""})
    )

    for ($r = 2; $r -le 7; $r++) {
        $table.Cell($r, 2).Merge($table.Cell($r, 4))
        $labelCell = $table.Cell($r, 1)
        $labelCell.Range.Font.Bold = $true
        $labelCell.Range.Font.Name = "Arial"
        $labelCell.Range.Font.Size = 12
        $labelCell.Range.Font.Color = $blackColor
        $labelCell.VerticalAlignment = 1
        $labelCell.Range.ParagraphFormat.Alignment = 1
        $labelCell.Range.Text = $labels[$r - 2]

        $valueCell = $table.Cell($r, 2)
        $valueCell.Range.Font.Bold = $false
        $valueCell.Range.Font.Name = "Arial"
        $valueCell.Range.Font.Size = 12
        $valueCell.Range.Font.Color = $blackColor
        $valueCell.Range.Text = $values[$r - 2]
    }

    $table.Cell(8, 1).Merge($table.Cell(8, 2))
    $obsH = $table.Cell(8, 1)
    $obsH.Shading.BackgroundPatternColor = $grayBg
    $obsH.Range.Font.Bold = $true
    $obsH.Range.Font.Color = $whiteColor
    $obsH.Range.Font.Name = "Arial"
    $obsH.Range.Font.Size = 12
    $obsH.Range.ParagraphFormat.Alignment = 1
    $obsH.Range.Text = "Observaciones"

    $table.Cell(9, 1).Merge($table.Cell(9, 2))
    $obsC = $table.Cell(9, 1)
    $obsC.Range.Font.Bold = $false
    $obsC.Range.Font.Name = "Arial"
    $obsC.Range.Font.Size = 12
    $obsC.Range.Font.Color = $blackColor
    $obsC.Range.Text = if($rnf001.observaciones){$rnf001.observaciones}else{""}

    Write-Host "RNF-001 table created"
    $doc.Save()
    Write-Host "Document saved."

} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace
} finally {
    if ($doc) { try { $doc.Close() } catch {} }
    if ($word) { $word.Quit() }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [GC]::Collect()
    Write-Host "Word closed."
}
