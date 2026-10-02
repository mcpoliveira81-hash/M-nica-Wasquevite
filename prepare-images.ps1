Add-Type -AssemblyName System.Drawing

$dir = $PSScriptRoot

function Save-Jpg([System.Drawing.Bitmap]$bmp, [string]$path, [long]$quality) {
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
  $bmp.Save($path, $codec, $ep)
  $bmp.Dispose()
}

# Corta a faixa inferior (21%) — remoção de sobreposições — e otimiza
function Crop-Optimize([string]$srcName, [string]$outName) {
  $src = Join-Path $dir $srcName
  $img = New-Object System.Drawing.Bitmap($src)
  $cutY = [int]($img.Height * 0.79)
  $rect = New-Object System.Drawing.Rectangle(0, 0, $img.Width, $cutY)
  $crop = $img.Clone($rect, $img.PixelFormat)
  $img.Dispose()
  Save-Jpg $crop (Join-Path $dir $outName) 85
}

# Só otimiza, mantém o enquadramento
function Optimize([string]$srcName, [string]$outName) {
  $img = New-Object System.Drawing.Bitmap((Join-Path $dir $srcName))
  Save-Jpg $img (Join-Path $dir $outName) 85
}

Crop-Optimize '622558494_18089609222286409_5610068746848476364_n.jpg' 'monica-consultorio.jpg'
Crop-Optimize '624211546_18105552736627480_4293618313031623903_n.jpg' 'monica-retrato.jpg'
Optimize    '632611294_18413799310192731_8609120086562931226_n.jpg' 'monica-ortodontia.jpg'

Get-ChildItem -LiteralPath $dir -Filter 'monica-*.jpg' |
  ForEach-Object {
    $i = [System.Drawing.Image]::FromFile($_.FullName)
    "{0}  {1}x{2}  {3}KB" -f $_.Name, $i.Width, $i.Height, [int]($_.Length/1024)
    $i.Dispose()
  }
