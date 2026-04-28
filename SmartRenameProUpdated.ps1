Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ================= AUTO FOLDER =================
$ScriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# ================= FORM =================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Smart Rename Pro (Portable)"
$form.Size = New-Object System.Drawing.Size(650,500)
$form.StartPosition = "CenterScreen"

# ================= TITLE =================
$title = New-Object System.Windows.Forms.Label
$title.Text = "Smart Rename Pro"
$title.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$title.Size = New-Object System.Drawing.Size(300,30)
$title.Location = New-Object System.Drawing.Point(20,10)
$form.Controls.Add($title)

# ================= INFO =================
$info = New-Object System.Windows.Forms.Label
$info.Text = "Folder: $ScriptFolder"
$info.Size = New-Object System.Drawing.Size(600,20)
$info.Location = New-Object System.Drawing.Point(20,40)
$form.Controls.Add($info)

# ================= PREFIX =================
$prefixLabel = New-Object System.Windows.Forms.Label
$prefixLabel.Text = "Enter Prefix:"
$prefixLabel.Location = New-Object System.Drawing.Point(20,80)
$form.Controls.Add($prefixLabel)

$prefixBox = New-Object System.Windows.Forms.TextBox
$prefixBox.Location = New-Object System.Drawing.Point(20,110)
$prefixBox.Size = New-Object System.Drawing.Size(200,25)
$form.Controls.Add($prefixBox)

# ================= EXTENSION DROPDOWN =================
$extLabel = New-Object System.Windows.Forms.Label
$extLabel.Text = "Select File Type:"
$extLabel.Location = New-Object System.Drawing.Point(250,80)
$form.Controls.Add($extLabel)

$extBox = New-Object System.Windows.Forms.ComboBox
$extBox.Location = New-Object System.Drawing.Point(250,110)
$extBox.Size = New-Object System.Drawing.Size(150,25)
$form.Controls.Add($extBox)

# ================= OUTPUT BOX =================
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20,220)
$outputBox.Size = New-Object System.Drawing.Size(600,220)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$form.Controls.Add($outputBox)

# ================= LOAD EXTENSIONS =================
$files = Get-ChildItem -Path $ScriptFolder -File
$extensions = $files | Select-Object -ExpandProperty Extension -Unique

foreach ($ext in $extensions) {
    if ($ext -ne "") {
        $extBox.Items.Add($ext)
    }
}

if ($extBox.Items.Count -gt 0) {
    $extBox.SelectedIndex = 0
}

# ================= PREVIEW BUTTON =================
$previewBtn = New-Object System.Windows.Forms.Button
$previewBtn.Text = "Preview"
$previewBtn.Location = New-Object System.Drawing.Point(420,105)
$previewBtn.Size = New-Object System.Drawing.Size(100,30)

$previewBtn.Add_Click({
    $outputBox.Clear()

    $selectedExt = $extBox.SelectedItem
    $filteredFiles = Get-ChildItem -Path $ScriptFolder -File | Where-Object { $_.Extension -eq $selectedExt } | Sort-Object Name

    $i = 1
    foreach ($file in $filteredFiles) {
        $newName = "{0}_{1:D3}{2}" -f $prefixBox.Text, $i, $file.Extension
        $outputBox.AppendText("$($file.Name) → $newName`r`n")
        $i++
    }
})

$form.Controls.Add($previewBtn)

# ================= RENAME BUTTON =================
$renameBtn = New-Object System.Windows.Forms.Button
$renameBtn.Text = "RENAME"
$renameBtn.Location = New-Object System.Drawing.Point(530,105)
$renameBtn.Size = New-Object System.Drawing.Size(100,30)

$renameBtn.Add_Click({

    if ([string]::IsNullOrWhiteSpace($prefixBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Enter Prefix First!")
        return
    }

    $selectedExt = $extBox.SelectedItem
    $filteredFiles = Get-ChildItem -Path $ScriptFolder -File | Where-Object { $_.Extension -eq $selectedExt } | Sort-Object Name

    $i = 1

    foreach ($file in $filteredFiles) {
        $newName = "{0}_{1:D3}{2}" -f $prefixBox.Text, $i, $file.Extension
        Rename-Item $file.FullName -NewName $newName
        $i++
    }

    [System.Windows.Forms.MessageBox]::Show("Renaming Completed!")
})

$form.Controls.Add($previewBtn)
$form.Controls.Add($renameBtn)

# ================= RUN =================
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()