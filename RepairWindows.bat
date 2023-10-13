:: スクリプトが既に管理者権限で実行されているかどうかを確認します
net session >nul 2>&1
if %errorLevel% == 0 (
  echo Script is already running with administrator privileges.
) else (
  echo Requesting administrator privileges...
  :: UAC プロンプトをトリガーして管理者としてスクリプトを実行する
  powershell -command "Start-Process 'cmd.exe' -ArgumentList '/c %~0' -Verb 'runAs'"
  exit /b
)
echo Start Windows Automatic Repair...

:: DISMを使用してイメージの修復を試みます
echo Running DISM...
Dism /Online /Cleanup-Image /CheckHealth
if %errorlevel% equ 0 (
    echo System is healthy, no repair required.
) else if %errorlevel% equ 1 (
    echo System needs repair. Initiating repair...
    Dism /Online /Cleanup-Image /RestoreHealth
) else (
    echo An error occurred while checking system health.
)

:: sfcを使用してシステムファイルのチェックを試みます
echo Running SFC verify...
sfc /VERIFYONLY

:: sfcが問題を見つけた場合にのみ、sfc /SCANNOWを実行します
if %errorlevel% equ 0 (
    echo No issues found by SFC verify.
) else (
    echo Issues found by SFC verify. Initiating SFC scan and repair...
    sfc /SCANNOW
)

:: 修復が完了したら終了メッセージを表示します
echo Windows Automatic Repair is complete.

:: ユーザーが画面を閉じる前に何かキーを押すように促します
pause
