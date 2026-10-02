Add-Type -AssemblyName System.Drawing

$dir = $PSScriptRoot

function Save-Jpg([System.Drawing.Bitmap]$bmp, [string]$path, [long]$quality) {
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
  $bmp.Save($path, $codec, $ep)
  $bmp.Dispose()
}

# 1) Consultório (622558494) -> manter proporção, otimizar
$src1 = Join-Path $dir '622558494_18089609222286409_5610068746848476364_n.jpg'
$img1 = New-Object System.Drawing.Bitmap($src1)
Save-Jpg $img1 (Join-Path $dir 'monica-consultorio.jpg') 86

# 2) Retrato (624211546) -> remover card sobreposto inferior (~21% da altura)
$src2 = Join-Path $dir '624211546_18105552736627480_4293618313031623903_n.jpg'
$img2 = New-Object System.Drawing.Bitmap($src2)
$cutY = [int]($img2.Height * 0.79)
$rect = New-Object System.Drawing.Rectangle(0, 0, $img2.Width, $cutY)
$crop = $img2.Clone($rect, $img2.PixelFormat)
$img2.Dispose()
Save-Jpg $crop (Join-Path $dir 'monica-retrato.jpg') 86

# 3) Ortodontia (632611294) -> otimizar
$src3 = Join-Path $dir '632611294_18413799310192731_8609120086562931226_n.jpg'
$img3 = New-Object System.Drawing.Bitmap($src3)
Save-Jpg $img3 (Join-Path $dir 'monica-ortodontia.jpg') 86

Get-ChildItem -LiteralPath $dir -Filter 'monica-*.jpg' | Select-Object Name, Length
