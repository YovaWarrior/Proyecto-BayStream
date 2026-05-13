# =============================================================================
# Fix RNF section: Delete all RNF content and re-insert 8 fresh tables
# =============================================================================
$ErrorActionPreference = "Stop"
$filePath = "c:\Proyectos\proyecto-baystream\docs\Primer Entregable.docx"
$jsonPath = "c:\Proyectos\proyecto-baystream\docs\rf_data.json"

$allData = Get-Content $jsonPath -Raw | ConvertFrom-Json
Write-Host "Loaded $($allData.rnfs.Count) RNFs"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Open($filePath)
    Write-Host "Document opened: $($doc.Paragraphs.Count) paragraphs"

    $grayBg = 8421504
    $whiteColor = 16777215
    $blackColor = 0

    # --- Step 1: Find the RNF section boundaries ---
    # Find the first "RNF-" occurrence in a heading style (not TOC) 
    # by searching for it after position of last RF table
    
    # Find "RNF-" text occurrences
    $rnfPositions = @()
    $searchRange = $doc.Content.Duplicate
    $searchRange.Find.ClearFormatting()
    $searchRange.Find.Text = "RNF-00"
    $searchRange.Find.Forward = $true
    $searchRange.Find.Wrap = 0
    
    while ($searchRange.Find.Execute()) {
        $pos = $searchRange.Start
        $paraText = $searchRange.Paragraphs(1).Range.Text.Trim()
        $rnfPositions += @{ pos = $pos; text = $paraText.Substring(0, [Math]::Min(80, $paraText.Length)) }
        $searchRange.Start = $searchRange.End
        $searchRange.End = $doc.Content.End
    }
    
    Write-Host "Found $($rnfPositions.Count) RNF-related positions"
    foreach ($p in $rnfPositions) { Write-Host "  Pos $($p.pos): $($p.text)" }
    
    if ($rnfPositions.Count -eq 0) {
        Write-Host "ERROR: No RNF content found"
        return
    }

    # The first RNF position (skip TOC entries - they'll be at the start of the doc)
    # Find "Alcances y L" as the end boundary
    $endRange = $doc.Content.Duplicate
    $endRange.Find.ClearFormatting()
    $endRange.Find.Text = "Alcances y L"
    $endRange.Find.Forward = $true
    $endRange.Find.Wrap = 0
    
    $endFound = $endRange.Find.Execute()
    if (-not $endFound) {
        # Try "IX." 
        $endRange = $doc.Content.Duplicate
        $endRange.Find.Text = "IX."
        $endFound = $endRange.Find.Execute()
    }
    
    if (-not $endFound) {
        Write-Host "ERROR: Cannot find end boundary (Alcances/IX)"
        return
    }
    
    $endPos = $endRange.Paragraphs(1).Range.Start
    Write-Host "End boundary at position: $endPos"
    
    # Find the start: look for the first RNF-related position that's NOT in the TOC
    # TOC entries are typically in the first ~10% of the document
    $docLen = $doc.Content.End
    $tocThreshold = $docLen * 0.15  # Assume TOC is in first 15%
    
    $firstRnfPos = $null
    foreach ($p in $rnfPositions) {
        if ($p.pos -gt $tocThreshold) {
            $firstRnfPos = $p.pos
            break
        }
    }
    
    if ($firstRnfPos -eq $null) {
        Write-Host "ERROR: All RNF positions are in TOC area"
        return
    }
    
    Write-Host "First body RNF at position: $firstRnfPos (doc length: $docLen)"
    
    # Go back from firstRnfPos to find the start of the RNF section
    # Look for the paragraph BEFORE the first RNF heading
    $firstRnfPara = $doc.Range($firstRnfPos, $firstRnfPos).Paragraphs(1)
    $sectionStartPos = $firstRnfPara.Range.Start
    
    # Check if there's a paragraph before this one that might be the section intro
    $prevRange = $doc.Range([Math]::Max(0, $sectionStartPos - 2), [Math]::Max(0, $sectionStartPos - 1))
    if ($prevRange.Paragraphs.Count -gt 0) {
        $prevPara = $prevRange.Paragraphs(1)
        $prevText = $prevPara.Range.Text.Trim()
        Write-Host "Previous paragraph: $($prevText.Substring(0, [Math]::Min(80, $prevText.Length)))"
        
        # If the previous paragraph is a section intro (not a heading), include everything from the first RNF heading
        # Don't go further back - keep the section heading and intro
    }
    
    Write-Host "Will delete from $sectionStartPos to $endPos"
    
    # --- Step 2: Delete all RNF content ---
    $deleteRange = $doc.Range($sectionStartPos, $endPos)
    $deleteText = $deleteRange.Text
    Write-Host "Deleting $($deleteText.Length) characters of RNF content..."
    $deleteRange.Delete()
    Write-Host "Deleted."
    
    # --- Step 3: Insert all 8 RNFs with headings and tables ---
    $insertPos = $sectionStartPos
    
    foreach ($rnf in $allData.rnfs) {
        Write-Host "Inserting $($rnf.id)..." -NoNewline
        
        # Insert heading paragraph: "RNF-XXX — [Name]"
        $headingRange = $doc.Range($insertPos, $insertPos)
        $headingRange.Text = "$($rnf.id) `u{2014} $($rnf.nombre)`r"
        $headingRange.Font.Name = "Arial"
        $headingRange.Font.Size = 12
        $headingRange.Font.Bold = $true
        $headingRange.Font.Color = $blackColor
        $headingRange.ParagraphFormat.SpaceBefore = 12
        $headingRange.ParagraphFormat.SpaceAfter = 6
        
        # Move insert position past the heading
        $insertPos = $headingRange.End
        
        # Insert table
        $tableRange = $doc.Range($insertPos, $insertPos)
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
        $table.Cell(1, 2).Range.Text = $rnf.id
        $table.Cell(1, 3).Range.Text = "Nombre:"
        $table.Cell(1, 3).Range.ParagraphFormat.Alignment = 1
        $table.Cell(1, 4).Range.Text = $rnf.nombre

        # Rows 2-7: Labels and values (merge cols 2-4)
        $labels = @("Descripción", "Entrada", "Proceso", "Salida", "Criterios de Aceptación", "Prioridad")
        $values = @(
            $(if($rnf.descripcion){$rnf.descripcion}else{""}),
            $(if($rnf.entrada){$rnf.entrada}else{""}),
            $(if($rnf.proceso){$rnf.proceso}else{""}),
            $(if($rnf.salida){$rnf.salida}else{""}),
            $(if($rnf.criterios){$rnf.criterios}else{""}),
            $(if($rnf.prioridad){$rnf.prioridad}else{""})
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

        # Row 8: Observaciones header (merge all)
        $table.Cell(8, 1).Merge($table.Cell(8, 2))
        $obsHeader = $table.Cell(8, 1)
        $obsHeader.Shading.BackgroundPatternColor = $grayBg
        $obsHeader.Range.Font.Bold = $true
        $obsHeader.Range.Font.Color = $whiteColor
        $obsHeader.Range.Font.Name = "Arial"
        $obsHeader.Range.Font.Size = 12
        $obsHeader.Range.ParagraphFormat.Alignment = 1
        $obsHeader.Range.Text = "Observaciones"

        # Row 9: Observaciones content (merge all)
        $table.Cell(9, 1).Merge($table.Cell(9, 2))
        $obsCell = $table.Cell(9, 1)
        $obsCell.Range.Font.Bold = $false
        $obsCell.Range.Font.Name = "Arial"
        $obsCell.Range.Font.Size = 12
        $obsCell.Range.Font.Color = $blackColor
        $obsCell.Range.Text = if($rnf.observaciones){$rnf.observaciones}else{""}
        
        # Move insert position past the table
        $insertPos = $table.Range.End + 1
        
        # Add spacing paragraph after table
        $spacer = $doc.Range($insertPos, $insertPos)
        $spacer.InsertAfter("`r")
        $insertPos = $spacer.End
        
        Write-Host " OK"
    }

    $doc.Save()
    Write-Host "`nAll 8 RNFs inserted and document saved."

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
