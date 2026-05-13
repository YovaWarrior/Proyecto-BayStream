$ErrorActionPreference = "Stop"
$filePath = "c:\Proyectos\proyecto-baystream\docs\Primer Entregable.docx"
$jsonPath = "c:\Proyectos\proyecto-baystream\docs\rf_data.json"
$allData = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "Loaded $($allData.rfs.Count) RFs and $($allData.rnfs.Count) RNFs"

Write-Host "Opening Word..."
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Open($filePath)
    Write-Host "Document opened: $($doc.Paragraphs.Count) paragraphs"

    $grayBg = 8421504
    $whiteBg = 16777215
    $blackColor = 0
    $whiteColor = 16777215
    $wdParagraph = 4

    function Create-ReqTable {
        param($doc, $insertRange, $id, $nombre, $descripcion, $entrada, $proceso, $salida, $criterios, $prioridad, $observaciones, $grayBg, $whiteColor, $blackColor)

        $table = $doc.Tables.Add($insertRange, 9, 4)
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
        $table.Cell(1, 2).Range.Text = $id
        $table.Cell(1, 3).Range.Text = "Nombre:"
        $table.Cell(1, 3).Range.ParagraphFormat.Alignment = 1
        $table.Cell(1, 4).Range.Text = $nombre

        $labels = @("Descripcion", "Entrada", "Proceso", "Salida", "Criterios de Aceptacion", "Prioridad")
        $values = @($descripcion, $entrada, $proceso, $salida, $criterios, $prioridad)

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
        $obsHeaderCell = $table.Cell(8, 1)
        $obsHeaderCell.Shading.BackgroundPatternColor = $grayBg
        $obsHeaderCell.Range.Font.Bold = $true
        $obsHeaderCell.Range.Font.Color = $whiteColor
        $obsHeaderCell.Range.Font.Name = "Arial"
        $obsHeaderCell.Range.Font.Size = 12
        $obsHeaderCell.Range.ParagraphFormat.Alignment = 1
        $obsHeaderCell.Range.Text = "Observaciones"

        $table.Cell(9, 1).Merge($table.Cell(9, 2))
        $obsCell = $table.Cell(9, 1)
        $obsCell.Range.Font.Bold = $false
        $obsCell.Range.Font.Name = "Arial"
        $obsCell.Range.Font.Size = 12
        $obsCell.Range.Font.Color = $blackColor
        $obsCell.Range.Text = $observaciones

        return $table
    }

    function Process-Requirement {
        param($doc, $req, $grayBg, $whiteColor, $blackColor, $wdParagraph)
        
        $reqId = $req.id
        $searchText = "ID: $reqId"

        $findRange = $doc.Content.Duplicate
        $findRange.Find.ClearFormatting()
        $findRange.Find.Text = $searchText
        $findRange.Find.Forward = $true
        $findRange.Find.Wrap = 0
        $findRange.Find.MatchCase = $false

        $found = $findRange.Find.Execute()
        
        if (-not $found) {
            $findRange = $doc.Content.Duplicate
            $findRange.Find.ClearFormatting()
            $findRange.Find.Text = $reqId
            $findRange.Find.Forward = $true
            $findRange.Find.Wrap = 0
            while ($findRange.Find.Execute()) {
                $pText = $findRange.Paragraphs(1).Range.Text.Trim()
                if ($pText -match 'PAGEREF') {
                    $findRange.Start = $findRange.End
                    $findRange.End = $doc.Content.End
                    continue
                }
                $dashMatch = $reqId + " " + [char]0x2014
                if ($pText.StartsWith($dashMatch)) {
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
        }

        if (-not $found) {
            Write-Host " NOT_FOUND" -ForegroundColor Yellow
            return $false
        }

        $startPara = $findRange.Paragraphs(1)
        $startPos = $startPara.Range.Start
        $endPos = $startPara.Range.End
        $docEnd = $doc.Content.End
        $safeEnd = $docEnd - 2

        $currentRange = $doc.Range($endPos, [Math]::Min($endPos + 1, $safeEnd))

        $maxParagraphs = 60
        $count = 0
        while ($count -lt $maxParagraphs) {
            $count++
            $nextParaRange = $currentRange.Duplicate
            $moved = $nextParaRange.Move($wdParagraph, 1)
            if ($moved -eq 0) { break }
            if ($nextParaRange.Start -ge $safeEnd) { break }
            
            $nextPara = $nextParaRange.Paragraphs(1)
            if ($null -eq $nextPara) { break }
            
            $paraText = $nextPara.Range.Text.Trim()
            if ($paraText.Length -eq 0) {
                $endPos = $nextPara.Range.End
                $currentRange = $doc.Range($endPos, [Math]::Min($endPos + 1, $safeEnd))
                continue
            }
            
            $isNextHeading = $false
            if ($paraText -match '^RF-\d{3}') { $isNextHeading = $true }
            if ($paraText -match '^RNF-\d{3}') { $isNextHeading = $true }
            if ($paraText -match '^\d+\.\s*RF-') { $isNextHeading = $true }
            if ($paraText -match '^M[o]dulo \d') { $isNextHeading = $true }
            if ($paraText -match '^Modulo \d') { $isNextHeading = $true }
            if ($paraText -match '^Requerimientos No Funcionales') { $isNextHeading = $true }
            if ($paraText -match '^Alcances y L') { $isNextHeading = $true }
            if ($paraText -match '^Tipo de Muestreo') { $isNextHeading = $true }
            if ($paraText -match '^Definici') { $isNextHeading = $true }
            if ($paraText -match '^Muestra de') { $isNextHeading = $true }
            if ($paraText -match '^IX\.') { $isNextHeading = $true }
            if ($paraText -match '^VIII\.') { $isNextHeading = $true }
            if ($paraText -match '^X\.') { $isNextHeading = $true }
            if ($paraText -match '^[A-Z]\.\s') { $isNextHeading = $true }
            
            try {
                $styleName = $nextPara.Range.ParagraphFormat.Style.NameLocal
                if ($styleName -match 'tulo|Heading') { $isNextHeading = $true }
            } catch {}

            if ($isNextHeading) { break }
            $endPos = $nextPara.Range.End
            $currentRange = $doc.Range($endPos, [Math]::Min($endPos + 1, $safeEnd))
        }

        try {
            $deleteRange = $doc.Range($startPos, $endPos)
            $deleteRange.Delete()
        } catch {
            Write-Host " WARN:range_delete_failed" -ForegroundColor Yellow
            try {
                $r = $doc.Range($startPos, $endPos)
                $pc = $r.Paragraphs.Count
                for ($pi = $pc; $pi -ge 1; $pi--) {
                    try { $r.Paragraphs($pi).Range.Delete() } catch {}
                }
            } catch {
                Write-Host " ERR:$_" -ForegroundColor Red
                return $false
            }
        }

        $insertRange = $doc.Range($startPos, $startPos)
        
        $nombre = if ($req.nombre) { $req.nombre } else { "" }
        $descripcion = if ($req.descripcion) { $req.descripcion } else { "" }
        $entrada = if ($req.entrada) { $req.entrada } else { "" }
        $proceso = if ($req.proceso) { $req.proceso } else { "" }
        $salida = if ($req.salida) { $req.salida } else { "" }
        $criterios = if ($req.criterios) { $req.criterios } else { "" }
        $prioridad = if ($req.prioridad) { $req.prioridad } else { "" }
        $observaciones = if ($req.observaciones) { $req.observaciones } else { "" }

        Create-ReqTable -doc $doc -insertRange $insertRange `
            -id $reqId -nombre $nombre `
            -descripcion $descripcion -entrada $entrada `
            -proceso $proceso -salida $salida `
            -criterios $criterios -prioridad $prioridad `
            -observaciones $observaciones `
            -grayBg $grayBg -whiteColor $whiteColor -blackColor $blackColor | Out-Null
        
        Write-Host " OK" -ForegroundColor Green
        return $true
    }

    # --- Process RFs in REVERSE order ---
    $rfList = @() + $allData.rfs
    [array]::Reverse($rfList)
    $successCount = 0
    $failCount = 0

    Write-Host "`n--- Processing RFs (reverse order) ---"
    foreach ($req in $rfList) {
        Write-Host "Processing $($req.id)..." -NoNewline
        try {
            $result = Process-Requirement -doc $doc -req $req -grayBg $grayBg -whiteColor $whiteColor -blackColor $blackColor -wdParagraph $wdParagraph
            if ($result) { $successCount++ } else { $failCount++ }
        } catch {
            $failCount++
            Write-Host " ERROR:$_" -ForegroundColor Red
        }
    }

    Write-Host "`nRFs done: $successCount OK, $failCount failed"
    $doc.Save()
    Write-Host "Document saved after RFs."

    # --- Process RNFs in REVERSE order ---
    $rnfList = @() + $allData.rnfs
    [array]::Reverse($rnfList)
    $rnfSuccess = 0
    $rnfFail = 0

    Write-Host "`n--- Processing RNFs (reverse order) ---"
    foreach ($req in $rnfList) {
        Write-Host "Processing $($req.id)..." -NoNewline
        try {
            $result = Process-Requirement -doc $doc -req $req -grayBg $grayBg -whiteColor $whiteColor -blackColor $blackColor -wdParagraph $wdParagraph
            if ($result) { $rnfSuccess++ } else { $rnfFail++ }
        } catch {
            $rnfFail++
            Write-Host " ERROR:$_" -ForegroundColor Red
        }
    }

    Write-Host "`n=== Final Results ==="
    Write-Host "RFs: $successCount OK, $failCount failed"
    Write-Host "RNFs: $rnfSuccess OK, $rnfFail failed"

    $doc.Save()
    Write-Host "Document saved."

} catch {
    Write-Host "CRITICAL ERROR: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace
} finally {
    if ($doc) { try { $doc.Close() } catch {} }
    if ($word) { $word.Quit() }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [GC]::Collect()
    Write-Host "Word closed."
}
