$adb = "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Pushing sample receipts to connected Android device/emulator..."
& $adb shell "mkdir -p /sdcard/DCIM/Camera /sdcard/Pictures /sdcard/Download"

Get-ChildItem -Path $scriptDir -Include *.jpg, *.jpeg, *.png, *.webp -Recurse | ForEach-Object {
    $fileName = $_.Name
    Write-Host "Pushing $fileName..."
    & $adb push $_.FullName /sdcard/DCIM/Camera/
    & $adb push $_.FullName /sdcard/Pictures/
    & $adb push $_.FullName /sdcard/Download/
    & $adb shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/DCIM/Camera/$fileName"
    & $adb shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/$fileName"
    & $adb shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Download/$fileName"
}

Write-Host "Done! All receipt images are now available in Gallery / Photos / Downloads."
