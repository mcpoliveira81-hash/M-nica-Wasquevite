$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8787/')
$listener.Start()
Write-Output 'Serving on http://localhost:8787/'
$types = @{ '.html'='text/html'; '.css'='text/css'; '.js'='application/javascript'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.png'='image/png'; '.svg'='image/svg+xml'; '.webp'='image/webp'; '.ico'='image/x-icon' }
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = $ctx.Request.Url.LocalPath
  if ($path -eq '/') { $path = '/index.html' }
  $file = Join-Path $root ($path.TrimStart('/').Replace('/','\'))
  if (Test-Path -LiteralPath $file -PathType Leaf) {
    $ext = [IO.Path]::GetExtension($file).ToLower()
    $mime = $types[$ext]; if (-not $mime) { $mime = 'application/octet-stream' }
    $bytes = [IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = $mime
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $msg = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
    $ctx.Response.StatusCode = 404
    $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
  }
  $ctx.Response.Close()
}
