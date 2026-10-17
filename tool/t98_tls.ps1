# Solo saludos TLS sin autenticación. No usa Firebase CLI ni su consola.
param(
  [Parameter(Mandatory=$true)][string]$OpenSsl,
  [string]$Salida = "$env:TEMP\t98\tls.json"
)
$ErrorActionPreference='Stop'
if (-not (Test-Path -LiteralPath $OpenSsl -PathType Leaf)) { throw 'Indicar un openssl existente; no se instala nada.' }
$target=[IO.Path]::GetFullPath($Salida)
if (-not $target.StartsWith(([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de TEMP.' }
if (Test-Path -LiteralPath $target) { throw 'No sobrescribir evidencia.' }
$version=(& $OpenSsl version | Out-String).Trim()
$results=foreach ($remote in @('firestore.googleapis.com','identitytoolkit.googleapis.com','securetoken.googleapis.com')) {
  # TLS 1.2 es el control positivo. Si el cliente no sabe ofrecer 1.1, el
  # negativo NO demuestra que el servidor lo rechace. No guardar certificados.
  foreach ($protocol in @('tls1_2','tls1_1')) {
    $info=[Diagnostics.ProcessStartInfo]::new()
    $info.FileName=$OpenSsl
    $info.Arguments="s_client -connect ${remote}:443 -servername $remote -$protocol -brief"
    $info.RedirectStandardInput=$true
    $info.RedirectStandardOutput=$true
    $info.RedirectStandardError=$true
    $info.UseShellExecute=$false
    $info.CreateNoWindow=$true
    $process=[Diagnostics.Process]::Start($info)
    $process.StandardInput.Close()
    $outTask=$process.StandardOutput.ReadToEndAsync()
    $errTask=$process.StandardError.ReadToEndAsync()
    $timeout=-not $process.WaitForExit(15000)
    if ($timeout) { $process.Kill(); $process.WaitForExit() }
    $text=$outTask.Result + $errTask.Result
    $negotiated=[regex]::Match($text,'(?:Protocol version:|Protocol\s*:)\s*(TLSv[\d.]+)').Groups[1].Value
    $localFailure=$text -match 'no protocols available|no ciphers available|no suitable signature algorithm|unsupported protocol|legacy sigalg disallowed'
    $remoteRejection=$text -match 'alert protocol version|tlsv1 alert|handshake failure'
    [ordered]@{ host=$remote; ofrecido=$protocol; timeout=$timeout;
      exitCode=$process.ExitCode; negociado=$negotiated;
      falloCliente=$localFailure; alertaRemota=$remoteRejection;
      interpretacion= if ($timeout -or $localFailure) { 'inconcluso' }
        elseif ($protocol -eq 'tls1_1' -and $remoteRejection -and -not $negotiated) { 'rechazo_remoto_observado' }
        elseif ($negotiated) { 'negociado' } else { 'inconcluso' } }
    $process.Dispose()
  }
}
New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
[ordered]@{ instrumento='T98'; openssl=$version; conexiones=@($results);
  pendiente='Versión de las conexiones reales en Security de Chrome; estos saludos no la sustituyen.' } |
  ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $target -Encoding utf8
Write-Output 'T-98: saludos TLS registrados sin certificados, credenciales ni datos.'
