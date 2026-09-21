# import_shot.ps1 —— 把一张截图转成网页用的 JPEG。
#
# 为什么需要它:NVIDIA 的 HDR 截图是 .jxr(JPEG XR),浏览器不认;而且动辄 2560x1440、
# 十几 MB,直接塞进仓库又大又慢。这里用 Windows 自带的 WIC 解码(不需要装任何东西),
# 等比缩到指定宽度,再编码成 JPEG。
#
# 用法(在 blog 目录下):
#   powershell -File scripts\import_shot.ps1 -Src "C:\Users\...\Videos\NVIDIA\Titanfall 2\xxx.jxr" -Name tf2-aimbot-01
#   powershell -File scripts\import_shot.ps1 -Src shot.png -Name tf2-aimbot-02 -Width 1200 -Quality 85
#
# 产出:assets\shots\<Name>.jpg,在文章里这样引用:
#   <img src="../assets/shots/<Name>.jpg" alt="..." loading="lazy">
param(
  [Parameter(Mandatory = $true)][string]$Src,
  [Parameter(Mandatory = $true)][string]$Name,
  [int]$Width = 1600,
  [int]$Quality = 88,
  [string]$Dir = "assets\shots"
)

Add-Type -AssemblyName PresentationCore

if (-not (Test-Path -LiteralPath $Src)) { Write-Error "找不到文件: $Src"; exit 1 }

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root $Dir
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir ($Name + ".jpg")

$fs = [System.IO.File]::OpenRead($Src)
try {
  $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create($fs, 'None', 'OnLoad')
  $frame = $dec.Frames[0]
  $w = $frame.PixelWidth
  $h = $frame.PixelHeight

  $target = $frame
  if ($w -gt $Width) {
    $s = $Width / $w
    $target = New-Object System.Windows.Media.Imaging.TransformedBitmap(
      $frame, (New-Object System.Windows.Media.ScaleTransform($s, $s)))
  }

  $enc = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
  $enc.QualityLevel = $Quality
  $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($target))
  $o = [System.IO.File]::Create($out)
  try { $enc.Save($o) } finally { $o.Close() }

  Write-Host ("in : {0}  {1}x{2} ({3})" -f (Split-Path -Leaf $Src), $w, $h, $frame.Format)
  Write-Host ("out: {0}  {1}x{2}  {3} KB" -f $out, $target.PixelWidth, $target.PixelHeight,
              [math]::Round((Get-Item $out).Length / 1KB))
}
finally { $fs.Close() }
