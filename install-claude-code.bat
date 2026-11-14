@echo off
chcp 65001 >nul
setlocal

echo ============================================
echo  Claude Code インストール ＋ PATH 設定
echo ============================================
echo.

set "CLAUDE_DIR=%USERPROFILE%\.local\bin"
set "CLAUDE_EXE=%CLAUDE_DIR%\claude.exe"

rem ---- 1. インストール ----
echo [1/3] Claude Code をインストールしています...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"
echo.

rem ---- 2. claude.exe の確認（無ければ latest 指定で再試行） ----
echo [2/3] claude.exe があるか確認しています...
if exist "%CLAUDE_EXE%" goto :found

echo claude.exe が見つかりません。latest 指定で再試行します...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) latest"
if exist "%CLAUDE_EXE%" goto :found

echo.
echo [エラー] claude.exe をインストールできませんでした。
echo 上に表示されたメッセージを確認してください。
goto :end

:found
echo OK: %CLAUDE_EXE%
echo.

rem ---- 3. ユーザー環境変数の PATH に追加（重複しない） ----
echo [3/3] PATH を設定しています...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d = Join-Path $env:USERPROFILE '.local\bin'; $p = [Environment]::GetEnvironmentVariable('Path', 'User'); if (-not $p) { $p = '' }; $parts = @($p -split ';' | Where-Object { $_ }); if ($parts -contains $d) { exit 2 }; [Environment]::SetEnvironmentVariable('Path', (($parts + $d) -join ';'), 'User'); exit 0"
if errorlevel 2 (
    echo PATH には既に入っています。
) else if errorlevel 1 (
    echo [エラー] PATH の設定に失敗しました。
    goto :end
) else (
    echo PATH に追加しました。
)
echo.

rem ---- 動作確認 ----
echo インストールされたバージョン:
"%CLAUDE_EXE%" --version
echo.
echo 完了しました。
echo PowerShell やコマンドプロンプトを一度閉じて開き直してから、
echo "claude" と入力して起動してください。

:end
echo.
pause
endlocal
