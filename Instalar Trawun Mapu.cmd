@echo off
rem Trawun Mapu - instalador chico (El Gallo McFlay). Baja el juego completo desde GitHub y lo instala sin pedir administrador.
rem Es un .cmd con un programa de PowerShell adentro (despues de la marca de dos numerales y PS). Windows 10 u 11, 64 bits.
title Instalar Trawun Mapu
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = [IO.File]::ReadAllText('%~f0', [Text.Encoding]::UTF8); $i = $s.IndexOf('#' + '#PS' + [char]13); if ($i -lt 0) { $i = $s.IndexOf('#' + '#PS' + [char]10) }; Invoke-Expression $s.Substring($i + 5)"
exit /b
##PS
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$REPO = 'https://raw.githubusercontent.com/facundoavila306-spec/trawun-mapu/main/instalar'
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Trawun Mapu'
function Titulo { Clear-Host; Write-Host ''; Write-Host '   TRAWÜN MAPU' -ForegroundColor Yellow; Write-Host '   estrategia en la Patagonia · El Gallo McFlay' -ForegroundColor DarkYellow; Write-Host '' }
function Bajar($url, $archivo, $bytes, $texto) {
  $req = [Net.HttpWebRequest]::Create($url); $req.UserAgent = 'TrawunMapu-instalador'; $req.Timeout = 60000
  $resp = $req.GetResponse(); $in = $resp.GetResponseStream(); $out = [IO.File]::Create($archivo)
  $buf = New-Object byte[] 262144; $tot = 0; $ult = -1
  while (($n = $in.Read($buf, 0, $buf.Length)) -gt 0) { $out.Write($buf, 0, $n); $tot += $n; $pct = [math]::Floor($tot * 100 / $bytes); if ($pct -ne $ult) { $ult = $pct; Write-Host ("`r   $texto $pct%   ") -NoNewline } }
  $out.Close(); $in.Close(); $resp.Close(); Write-Host ''
  if ($tot -ne $bytes) { throw "La bajada se cortó ($tot de $bytes bytes). Probá de nuevo." }
}
try {
  Titulo
  if (-not [Environment]::Is64BitOperatingSystem) { throw 'Este juego necesita Windows de 64 bits.' }
  Write-Host '   Buscando la última versión…'
  $m = Invoke-RestMethod ("$REPO/instalar.json?t=" + [DateTime]::Now.Ticks)
  Write-Host ("   Versión {0} · hay que bajar {1} MB" -f $m.version, [math]::Round($m.bytes / 1MB))
  Write-Host ''
  Write-Host "   Se instala en: $dest"
  $r = Read-Host '   Enter para seguir (o escribí otra carpeta y Enter)'
  if ($r.Trim()) { $dest = $r.Trim().Trim('"') }
  $exe = Join-Path $dest $m.exe
  $corriendo = Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($m.exe)) -ErrorAction SilentlyContinue
  if ($corriendo) { throw 'El juego está abierto: cerralo y volvé a correr el instalador.' }
  $tmp = Join-Path $env:TEMP 'trawun-instalar'; New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  $zip = Join-Path $tmp ("trawun-mapu-" + $m.version + ".zip")
  Write-Host ''
  $fs = [IO.File]::Create($zip); $i = 0
  foreach ($p in $m.partes) {
    $i++; $pf = Join-Path $tmp $p.archivo
    Bajar ("$REPO/" + $m.version + "/" + $p.archivo) $pf $p.bytes ("Bajando parte $i de " + $m.partes.Count + "…")
    $h = (Get-FileHash -LiteralPath $pf -Algorithm SHA256).Hash.ToLower()
    if ($h -ne $p.sha256) { $fs.Close(); throw "La parte $i bajó dañada (huella distinta). Probá de nuevo." }
    $b = [IO.File]::ReadAllBytes($pf); $fs.Write($b, 0, $b.Length); Remove-Item -LiteralPath $pf -Force
  }
  $fs.Close()
  $h = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
  if ($h -ne $m.sha256) { throw 'El paquete bajó dañado (huella distinta). Probá de nuevo.' }
  Write-Host '   Instalando (un minuto)…'
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $dest -Force
  Remove-Item -LiteralPath $zip -Force
  if (-not (Test-Path -LiteralPath $exe)) { throw 'No quedó el juego en la carpeta (¿antivirus?).' }
  # accesos directos: escritorio y menú Inicio, con el ícono del juego
  $ws = New-Object -ComObject WScript.Shell
  $ico = Join-Path $dest 'icono.ico'
  foreach ($lnk in @((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Trawün Mapu.lnk'), (Join-Path ([Environment]::GetFolderPath('Programs')) 'Trawün Mapu.lnk'))) {
    $lk = $ws.CreateShortcut($lnk); $lk.TargetPath = $exe; $lk.WorkingDirectory = $dest; $lk.Description = 'Trawün Mapu — El Gallo McFlay'; if (Test-Path -LiteralPath $ico) { $lk.IconLocation = "$ico,0" }; $lk.Save()
  }
  # desinstalador y entrada en "Aplicaciones" de Windows
  $des = @(
    '@echo off',
    'chcp 65001 >nul',
    'title Desinstalar Trawun Mapu',
    'echo.',
    'echo   Se va a borrar Trawun Mapu de esta carpeta:',
    ('echo   ' + $dest),
    'echo.',
    'set /p R=  Escribi SI para borrar el juego (las partidas guardadas quedan): ',
    'if /i not "%R%"=="SI" exit /b',
    ('del /q "' + (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Trawün Mapu.lnk') + '" 2>nul'),
    ('del /q "' + (Join-Path ([Environment]::GetFolderPath('Programs')) 'Trawün Mapu.lnk') + '" 2>nul'),
    'reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\TrawunMapu /f >nul 2>nul',
    ('if exist "' + (Join-Path $dest 'datos') + '" ( if not exist "%USERPROFILE%\Documents\Trawun Mapu" mkdir "%USERPROFILE%\Documents\Trawun Mapu" & move /y "' + (Join-Path $dest 'datos') + '" "%USERPROFILE%\Documents\Trawun Mapu\datos" >nul & echo   Las partidas guardadas quedaron en Documentos\Trawun Mapu\datos )'),
    'cd /d "%TEMP%"',
    ('rmdir /s /q "' + $dest + '"'),
    'echo   Listo.',
    'pause'
  )
  [IO.File]::WriteAllLines((Join-Path $dest 'Desinstalar.cmd'), $des, (New-Object Text.UTF8Encoding $false))
  try {
    $k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\TrawunMapu'
    New-Item -Path $k -Force | Out-Null
    New-ItemProperty -Path $k -Name DisplayName -Value 'Trawün Mapu' -Force | Out-Null
    New-ItemProperty -Path $k -Name DisplayVersion -Value $m.version -Force | Out-Null
    New-ItemProperty -Path $k -Name Publisher -Value 'El Gallo McFlay' -Force | Out-Null
    New-ItemProperty -Path $k -Name DisplayIcon -Value $exe -Force | Out-Null
    New-ItemProperty -Path $k -Name InstallLocation -Value $dest -Force | Out-Null
    New-ItemProperty -Path $k -Name UninstallString -Value ('cmd /c ""' + (Join-Path $dest 'Desinstalar.cmd') + '""') -Force | Out-Null
    New-ItemProperty -Path $k -Name NoModify -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $k -Name NoRepair -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $k -Name EstimatedSize -Value ([int]((Get-ChildItem -LiteralPath $dest -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB)) -PropertyType DWord -Force | Out-Null
  } catch {}
  Write-Host ''
  Write-Host ("   Listo: Trawün Mapu " + $m.version + " quedó instalado.") -ForegroundColor Green
  Write-Host '   Tenés el acceso directo en el escritorio y en el menú Inicio.'
  Write-Host '   Las partidas guardadas quedan en la carpeta "datos", al lado del juego.'
  Write-Host ''
  $r = Read-Host '   ¿Lo abrimos ahora? (Enter = sí, n = no)'
  if ($r.Trim() -notmatch '^[nN]') { Start-Process -FilePath $exe -WorkingDirectory $dest }
} catch {
  Write-Host ''
  Write-Host ('   No se pudo instalar: ' + $_.Exception.Message) -ForegroundColor Red
  Write-Host '   Si se repite, mandale este mensaje a Facundo.'
  Write-Host ''
  Read-Host '   Enter para cerrar' | Out-Null
}
