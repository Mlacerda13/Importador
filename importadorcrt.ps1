# --- FORÇAR ELEVAÇÃO DE ADMINISTRADOR ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

[System.Windows.Forms.Application]::EnableVisualStyles()

# --- FORMULÁRIO UNIVERSAL v9.2 ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Painel Importador de Certificados Remoto v9.2 (Universal Correção)"
$Form.ClientSize = New-Object System.Drawing.Size(580, 860)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "Sizable"
$Form.AutoScroll = $true

# 1. MÁQUINAS ALVO
$GrpAlvo = New-Object System.Windows.Forms.GroupBox
$GrpAlvo.Location = New-Object System.Drawing.Point(10, 10)
$GrpAlvo.Size = New-Object System.Drawing.Size(550, 140)
$GrpAlvo.Text = "1. Máquinas Alvo / Origem da Lista"
$Form.Controls.Add($GrpAlvo)

$RadMaquinas = New-Object System.Windows.Forms.RadioButton
$RadMaquinas.Location = New-Object System.Drawing.Point(15, 20)
$RadMaquinas.Size = New-Object System.Drawing.Size(180, 20)
$RadMaquinas.Text = "Lista de Hostnames"
$RadMaquinas.Checked = $true
$GrpAlvo.Controls.Add($RadMaquinas)

$TxtMaquinas = New-Object System.Windows.Forms.TextBox
$TxtMaquinas.Location = New-Object System.Drawing.Point(200, 20)
$TxtMaquinas.Size = New-Object System.Drawing.Size(330, 60)
$TxtMaquinas.Multiline = $true
$TxtMaquinas.ScrollBars = "Vertical"
$TxtMaquinas.Text = $env:COMPUTERNAME
$GrpAlvo.Controls.Add($TxtMaquinas)

$RadFarm = New-Object System.Windows.Forms.RadioButton
$RadFarm.Location = New-Object System.Drawing.Point(15, 90)
$RadFarm.Size = New-Object System.Drawing.Size(180, 20)
$RadFarm.Text = "Farm Digitável (DNS)"
$GrpAlvo.Controls.Add($RadFarm)

$TxtFarmDomain = New-Object System.Windows.Forms.TextBox
$TxtFarmDomain.Location = New-Object System.Drawing.Point(200, 90)
$TxtFarmDomain.Size = New-Object System.Drawing.Size(210, 22)
$TxtFarmDomain.Text = "rdp.facil.hosting"
$TxtFarmDomain.Enabled = $false
$GrpAlvo.Controls.Add($TxtFarmDomain)

$BtnResolverFarm = New-Object System.Windows.Forms.Button
$BtnResolverFarm.Location = New-Object System.Drawing.Point(420, 88)
$BtnResolverFarm.Size = New-Object System.Drawing.Size(110, 26)
$BtnResolverFarm.Text = "🌐 Resolver IPs"
$BtnResolverFarm.Enabled = $false
$GrpAlvo.Controls.Add($BtnResolverFarm)

$RadMaquinas.add_CheckedChanged({
    $TxtMaquinas.Enabled = $RadMaquinas.Checked
    $TxtFarmDomain.Enabled = $RadFarm.Checked
    $BtnResolverFarm.Enabled = $RadFarm.Checked
})

$RadFarm.add_CheckedChanged({
    $TxtMaquinas.Enabled = $RadMaquinas.Checked
    $TxtFarmDomain.Enabled = $RadFarm.Checked
    $BtnResolverFarm.Enabled = $RadFarm.Checked
})

$BtnResolverFarm.add_Click({
    try {
        $Domain = $TxtFarmDomain.Text.Trim()
        $FarmIPs = ([net.dns]::GetHostEntry($Domain)).AddressList | ForEach-Object { $_.IPAddressToString }
        $HostsGerados = @()
        foreach ($ip in $FarmIPs) { $HostsGerados += ("F" + $ip.Replace('.', '-')) }
        $TxtMaquinas.Text = [string]::Join("`r`n", $HostsGerados)
        [System.Windows.Forms.MessageBox]::Show("IPs resolvidos e gravados na lista!", "Sucesso")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erro ao resolver DNS: " + $_.Exception.Message, "Erro")
    }
})

# 2. AUTENTICAÇÃO / CREDENCIAIS ALTERNATIVAS
$GrpCreds = New-Object System.Windows.Forms.GroupBox
$GrpCreds.Location = New-Object System.Drawing.Point(10, 160)
$GrpCreds.Size = New-Object System.Drawing.Size(550, 95)
$GrpCreds.Text = "2. Credenciais de Conexão (Credenciais ADM)"
$Form.Controls.Add($GrpCreds)

$ChkUsarAltCreds = New-Object System.Windows.Forms.CheckBox
$ChkUsarAltCreds.Location = New-Object System.Drawing.Point(15, 20)
$ChkUsarAltCreds.Size = New-Object System.Drawing.Size(250, 20)
$ChkUsarAltCreds.Text = "Usar conta ADM alternativa"
$GrpCreds.Controls.Add($ChkUsarAltCreds)

$LblUserAlt = New-Object System.Windows.Forms.Label
$LblUserAlt.Location = New-Object System.Drawing.Point(15, 55)
$LblUserAlt.Size = New-Object System.Drawing.Size(60, 20)
$LblUserAlt.Text = "Usuário:"
$GrpCreds.Controls.Add($LblUserAlt)

$TxtUserAlt = New-Object System.Windows.Forms.TextBox
$TxtUserAlt.Location = New-Object System.Drawing.Point(75, 52)
$TxtUserAlt.Size = New-Object System.Drawing.Size(185, 22)
$TxtUserAlt.Text = "facil.hosting\admin"
$TxtUserAlt.Enabled = $false
$GrpCreds.Controls.Add($TxtUserAlt)

$LblPassAlt = New-Object System.Windows.Forms.Label
$LblPassAlt.Location = New-Object System.Drawing.Point(275, 55)
$LblPassAlt.Size = New-Object System.Drawing.Size(50, 20)
$LblPassAlt.Text = "Senha:"
$GrpCreds.Controls.Add($LblPassAlt)

$TxtPassAlt = New-Object System.Windows.Forms.TextBox
$TxtPassAlt.Location = New-Object System.Drawing.Point(330, 52)
$TxtPassAlt.Size = New-Object System.Drawing.Size(200, 22)
$TxtPassAlt.UseSystemPasswordChar = $true
$TxtPassAlt.Enabled = $false
$GrpCreds.Controls.Add($TxtPassAlt)

# 3. CERTIFICADOS
$GrpCerts = New-Object System.Windows.Forms.GroupBox
$GrpCerts.Location = New-Object System.Drawing.Point(10, 265)
$GrpCerts.Size = New-Object System.Drawing.Size(550, 145)
$GrpCerts.Text = "3. Seleção de Certificados"
$Form.Controls.Add($GrpCerts)

$BtnSelCert = New-Object System.Windows.Forms.Button
$BtnSelCert.Location = New-Object System.Drawing.Point(15, 22)
$BtnSelCert.Size = New-Object System.Drawing.Size(170, 30)
$BtnSelCert.Text = "📁 Selecionar Arquivos"
$GrpCerts.Controls.Add($BtnSelCert)

$BtnLimparCerts = New-Object System.Windows.Forms.Button
$BtnLimparCerts.Location = New-Object System.Drawing.Point(15, 57)
$BtnLimparCerts.Size = New-Object System.Drawing.Size(170, 25)
$BtnLimparCerts.Text = "🗑️ Limpar Lista"
$GrpCerts.Controls.Add($BtnLimparCerts)

$LstCertificados = New-Object System.Windows.Forms.ListBox
$LstCertificados.Location = New-Object System.Drawing.Point(200, 20)
$LstCertificados.Size = New-Object System.Drawing.Size(330, 65)
$GrpCerts.Controls.Add($LstCertificados)

$LblSenhaPfx = New-Object System.Windows.Forms.Label
$LblSenhaPfx.Location = New-Object System.Drawing.Point(15, 102)
$LblSenhaPfx.Size = New-Object System.Drawing.Size(170, 20)
$LblSenhaPfx.Text = "Senha PFX (se houver):"
$GrpCerts.Controls.Add($LblSenhaPfx)

$TxtSenhaPfx = New-Object System.Windows.Forms.TextBox
$TxtSenhaPfx.Location = New-Object System.Drawing.Point(200, 99)
$TxtSenhaPfx.Size = New-Object System.Drawing.Size(330, 22)
$TxtSenhaPfx.UseSystemPasswordChar = $true
$GrpCerts.Controls.Add($TxtSenhaPfx)

$BtnSelCert.add_Click({
    $OFD = New-Object System.Windows.Forms.OpenFileDialog
    $OFD.Filter = "Certificados (*.cer;*.crt;*.pfx;*.p7b)|*.cer;*.crt;*.pfx;*.p7b"
    $OFD.Multiselect = $true
    if ($OFD.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($File in $OFD.FileNames) {
            if (-not $LstCertificados.Items.Contains($File)) { [void]$LstCertificados.Items.Add($File) }
        }
    }
})

$BtnLimparCerts.add_Click({ $LstCertificados.Items.Clear() })

# 4. REPOSITÓRIO DE DESTINO
$GrpStore = New-Object System.Windows.Forms.GroupBox
$GrpStore.Location = New-Object System.Drawing.Point(10, 420)
$GrpStore.Size = New-Object System.Drawing.Size(550, 160)
$GrpStore.Text = "4. Repositório de Destino & Agendamento"
$Form.Controls.Add($GrpStore)

$LblStoreLoc = New-Object System.Windows.Forms.Label
$LblStoreLoc.Location = New-Object System.Drawing.Point(15, 22)
$LblStoreLoc.Size = New-Object System.Drawing.Size(170, 20)
$LblStoreLoc.Text = "Modo de Instalação:"
$GrpStore.Controls.Add($LblStoreLoc)

$CmbStoreLocation = New-Object System.Windows.Forms.ComboBox
$CmbStoreLocation.Location = New-Object System.Drawing.Point(200, 20)
$CmbStoreLocation.Size = New-Object System.Drawing.Size(330, 22)
$CmbStoreLocation.DropDownStyle = "DropDownList"
[void]$CmbStoreLocation.Items.Add("LocalMachine (MÁQUINA - Todos os Usuários)")
[void]$CmbStoreLocation.Items.Add("CurrentUser (PERFIL DO ADM CONECTADO)")
[void]$CmbStoreLocation.Items.Add("LoggedUser_ViaADM (PERFIL DO USUÁRIO LOGADO AGORA)")
[void]$CmbStoreLocation.Items.Add("ScheduleUser_ViaADM (AGENDAR PARA O LOGIN DO COLABORADOR)")
$CmbStoreLocation.SelectedIndex = 3
$GrpStore.Controls.Add($CmbStoreLocation)

$LblTargetUser = New-Object System.Windows.Forms.Label
$LblTargetUser.Location = New-Object System.Drawing.Point(15, 57)
$LblTargetUser.Size = New-Object System.Drawing.Size(170, 20)
$LblTargetUser.Text = "Colaborador (DOMINIO\user):"
$GrpStore.Controls.Add($LblTargetUser)

$TxtTargetUser = New-Object System.Windows.Forms.TextBox
$TxtTargetUser.Location = New-Object System.Drawing.Point(200, 54)
$TxtTargetUser.Size = New-Object System.Drawing.Size(330, 22)
$TxtTargetUser.Text = "facil.hosting\r.ferreira"
$TxtTargetUser.Enabled = $true
$GrpStore.Controls.Add($TxtTargetUser)

$LblStoreFolder = New-Object System.Windows.Forms.Label
$LblStoreFolder.Location = New-Object System.Drawing.Point(15, 95)
$LblStoreFolder.Size = New-Object System.Drawing.Size(170, 20)
$LblStoreFolder.Text = "Pasta de Destino:"
$GrpStore.Controls.Add($LblStoreFolder)

$CmbStoreFolder = New-Object System.Windows.Forms.ComboBox
$CmbStoreFolder.Location = New-Object System.Drawing.Point(200, 92)
$CmbStoreFolder.Size = New-Object System.Drawing.Size(330, 22)
$CmbStoreFolder.DropDownStyle = "DropDownList"
[void]$CmbStoreFolder.Items.Add("Root (Autoridades Raiz Confiáveis)")
[void]$CmbStoreFolder.Items.Add("My (Pessoal)")
[void]$CmbStoreFolder.Items.Add("CA (Autoridades Intermediárias)")
$CmbStoreFolder.SelectedIndex = 1
$GrpStore.Controls.Add($CmbStoreFolder)

function Update-TargetDomainPrefix {
    $AdminUser = $TxtUserAlt.Text.Trim()
    if ($AdminUser.Contains("\")) {
        $DomainPart = $AdminUser.Split("\")[0]
        $CurrentUserPart = ""
        if ($TxtTargetUser.Text.Contains("\")) {
            $CurrentUserPart = $TxtTargetUser.Text.Split("\")[1]
        }
        $TxtTargetUser.Text = "$DomainPart\$CurrentUserPart"
    }
}

$ChkUsarAltCreds.add_CheckedChanged({
    $TxtUserAlt.Enabled = $ChkUsarAltCreds.Checked
    $TxtPassAlt.Enabled = $ChkUsarAltCreds.Checked
    if ($ChkUsarAltCreds.Checked) {
        Update-TargetDomainPrefix
    }
})

$TxtUserAlt.add_TextChanged({
    if ($ChkUsarAltCreds.Checked) {
        Update-TargetDomainPrefix
    }
})

$CmbStoreLocation.add_SelectedIndexChanged({
    $TxtTargetUser.Enabled = ($CmbStoreLocation.SelectedIndex -eq 3)
})

# 5. BOTÃO EXECUTAR
$BtnIniciar = New-Object System.Windows.Forms.Button
$BtnIniciar.Location = New-Object System.Drawing.Point(10, 590)
$BtnIniciar.Size = New-Object System.Drawing.Size(550, 40)
$BtnIniciar.Text = "🚀 IMPORTAR / AGENDAR CERTIFICADOS"
$BtnIniciar.BackColor = [System.Drawing.Color]::DarkGreen
$BtnIniciar.ForeColor = [System.Drawing.Color]::White
$BtnIniciar.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($BtnIniciar)

# 6. LOG DE EXECUÇÃO
$TxtStatus = New-Object System.Windows.Forms.TextBox
$TxtStatus.Location = New-Object System.Drawing.Point(10, 640)
$TxtStatus.Size = New-Object System.Drawing.Size(550, 200)
$TxtStatus.Multiline = $true
$TxtStatus.ScrollBars = "Vertical"
$TxtStatus.ReadOnly = $true
$TxtStatus.Text = "Pronto para iniciar..."
$Form.Controls.Add($TxtStatus)

$BtnIniciar.add_Click({
    $ListaMaquinas = @()
    foreach ($line in ($TxtMaquinas.Text -split "`r`n")) {
        $t = $line.Trim()
        if ($t -ne "") { $ListaMaquinas += $t }
    }

    if ($ListaMaquinas.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Digite ou selecione ao menos uma máquina.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if ($LstCertificados.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecione ao menos um certificado.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $PSCred = $null
    if ($ChkUsarAltCreds.Checked) {
        if ([string]::IsNullOrEmpty($TxtUserAlt.Text.Trim()) -or [string]::IsNullOrEmpty($TxtPassAlt.Text.Trim())) {
            [System.Windows.Forms.MessageBox]::Show("Informe o usuário e a senha alternativos para autenticação.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        $SecPass = ConvertTo-SecureString $TxtPassAlt.Text -AsPlainText -Force
        $PSCred = New-Object System.Management.Automation.PSCredential($TxtUserAlt.Text, $SecPass)
    }

    $TargetLocMode = $CmbStoreLocation.SelectedIndex
    $TargetUserVal = $TxtTargetUser.Text.Trim()

    if ($TargetLocMode -eq 3 -and ([string]::IsNullOrEmpty($TargetUserVal) -or $TargetUserVal.EndsWith("\"))) {
        [System.Windows.Forms.MessageBox]::Show("Por favor informe a conta completa do colaborador (ex: DOMINIO\usuario) para criar o agendamento.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $TargetFolder = switch ($CmbStoreFolder.SelectedIndex) {
        0 { "Root" }
        1 { "My" }
        2 { "CA" }
        default { "My" }
    }

    $CertBytes = @()
    foreach ($Path in $LstCertificados.Items) {
        if (Test-Path $Path) {
            $CertBytes += [PSCustomObject]@{
                FileName = [System.IO.Path]::GetFileName($Path)
                Bytes    = [System.IO.File]::ReadAllBytes($Path)
                Ext      = [System.IO.Path]::GetExtension($Path).ToLower()
            }
        }
    }

    $BtnIniciar.Enabled = $false
    $TxtStatus.Text = "Iniciando processamento v9.2...`r`n"
    $Form.Refresh()

    foreach ($Comp in $ListaMaquinas) {
        $TxtStatus.AppendText("`r`n[ " + $Comp + " ] Conectando...`r`n")
        $Form.Refresh()

        try {
            $ScriptBlock = {
                param($Certs, $LocMode, $Folder, $Pass, $TargetColab)
                $Out = @()

                # MODO 3: SCHEDULE USER (AGENDAMENTO DE TAREFA UNIVERSAL VIA SCHTASKS.EXE)
                if ($LocMode -eq 3) {
                    try {
                        $StagingDir = "C:\Windows\Temp\CertDeploy"
                        if (-not (Test-Path $StagingDir)) { [void](New-Item -ItemType Directory -Path $StagingDir -Force) }

                        foreach ($c in $Certs) {
                            $DestFile = Join-Path $StagingDir $c.FileName
                            [System.IO.File]::WriteAllBytes($DestFile, $c.Bytes)
                        }

                        $TaskScriptPath = Join-Path $StagingDir "InstallCerts.ps1"
                        $ScriptBody = @"
`$Folder = "$Folder"
`$Pass = "$Pass"
`$StagingDir = "$StagingDir"
`$Files = Get-ChildItem -Path `$StagingDir | Where-Object { `$_.Extension -match "\.(cer|crt|pfx|p7b)`$" }

foreach (`$f in `$Files) {
    try {
        if (`$f.Extension.ToLower() -eq ".pfx") {
            & certutil.exe -user -p "`$Pass" -importpfx "`$(`$f.FullName)" NoRoot | Out-Null
        } else {
            & certutil.exe -user -addstore `$Folder "`$(`$f.FullName)" | Out-Null
        }
    } catch {}
}

& schtasks.exe /Delete /TN "ImportCertificates_$Folder" /F | Out-Null
Remove-Item -Path `$StagingDir -Recurse -Force -ErrorAction SilentlyContinue
"@
                        [System.IO.File]::WriteAllText($TaskScriptPath, $ScriptBody)
                        $TaskName = "ImportCertificates_$Folder"
                        $TaskCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$TaskScriptPath`""

                        & schtasks.exe /Delete /TN $TaskName /F 2>&1 | Out-Null
                        $SchRes = & schtasks.exe /Create /TN $TaskName /TR $TaskCmd /SC ONLOGON /RU $TargetColab /F 2>&1

                        if ($LASTEXITCODE -eq 0) {
                            $Out += "SUCESSO: Tarefa agendada via schtasks para o login de [" + $TargetColab + "]."
                        } else {
                            $Out += "ERRO no Agendamento (schtasks): " + ($SchRes -join " ")
                        }

                    } catch {
                        $Out += "ERRO no Agendamento: " + $_.Exception.Message
                    }
                    return $Out
                }

                # MODO DIRECT INSTALLATION (CERTUTIL UNIVERSAL)
                foreach ($c in $Certs) {
                    try {
                        $Tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), $c.FileName)
                        [System.IO.File]::WriteAllBytes($Tmp, $c.Bytes)

                        if ($LocMode -eq 0) {
                            # LocalMachine
                            if ($c.Ext -eq ".pfx") {
                                & certutil.exe -p $Pass -importpfx $Tmp NoRoot 2>&1 | Out-Null
                            } else {
                                & certutil.exe -addstore $Folder $Tmp 2>&1 | Out-Null
                            }
                            $Out += "OK: " + $c.FileName + " instalado em LocalMachine\" + $Folder
                        } else {
                            # CurrentUser
                            if ($c.Ext -eq ".pfx") {
                                & certutil.exe -user -p $Pass -importpfx $Tmp NoRoot 2>&1 | Out-Null
                            } else {
                                & certutil.exe -user -addstore $Folder $Tmp 2>&1 | Out-Null
                            }
                            $Out += "OK: " + $c.FileName + " instalado em CurrentUser\" + $Folder
                        }

                        if (Test-Path $Tmp) { Remove-Item $Tmp -Force }
                    } catch {
                        $Out += "ERRO: " + $_.Exception.Message
                    }
                }
                return $Out
            }

            if ($PSCred) {
                $Res = Invoke-Command -ComputerName $Comp -Credential $PSCred -ScriptBlock $ScriptBlock -ArgumentList $CertBytes, $TargetLocMode, $TargetFolder, $TxtSenhaPfx.Text, $TargetUserVal -ErrorAction Stop
            } else {
                $Res = Invoke-Command -ComputerName $Comp -ScriptBlock $ScriptBlock -ArgumentList $CertBytes, $TargetLocMode, $TargetFolder, $TxtSenhaPfx.Text, $TargetUserVal -ErrorAction Stop
            }

            foreach ($line in $Res) { $TxtStatus.AppendText(" -> " + $line + "`r`n") }

        } catch {
            $TxtStatus.AppendText(" -> FALHA DE CONEXÃO: " + $_.Exception.Message + "`r`n")
        }
        $Form.Refresh()
    }

    $TxtStatus.AppendText("`r`n--- PROCESSO CONCLUÍDO ---`r`n")
    $BtnIniciar.Enabled = $true
})

# EXIBIR TELA
[void]$Form.ShowDialog()