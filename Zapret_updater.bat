@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title Zapret Updater by Yan4ik000 (v.1.0.1)
set "ZAPRET_DIR=%~dp0"
if "%ZAPRET_DIR:~-1%"=="\" set "ZAPRET_DIR=%ZAPRET_DIR:~0,-1%"
set "SELF_PATH=%~f0"
set "TARGET_BAT="
set "TEMP_DIR=%TEMP%\zapret_update"
set "SERVICE_NAME=zapret"
set "REL_FILE=%TEMP%\zapret_release.txt"
set "STEP=init"
set "BACKUP_FILE="

:: === LOGGING SETTINGS / НАСТРОЙКИ ЛОГИРОВАНИЯ ===
set "ENABLE_LOGGING=0"
set "LOG_FILE=%ZAPRET_DIR%\update_debug.log"

call :log "Script started. Path: %SELF_PATH%"

:: Require admin rights / Требую права администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :log "Admin rights missing. Requesting elevation."
    set "SELF_PATH=%~f0"
    powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList @('/k',([char]34 + $env:SELF_PATH + [char]34)) -Verb RunAs"
    exit /b
)
call :log "Admin rights confirmed."

:: Check PowerShell version / Проверяю версию PowerShell
powershell -NoProfile -Command "if ($PSVersionTable.PSVersion.Major -ge 5) { exit 0 } else { exit 1 }" >nul 2>&1
if %errorlevel% neq 0 (
    call :log "Error: PowerShell 5.0+ required."
    echo [ERROR] PowerShell 5.0 or higher is required for this script.
    echo Please install Windows Management Framework 5.1.
    pause
    exit /b 1
)

:: === LANGUAGE SELECTION / ВЫБОР ЯЗЫКА===
set "SYS_LANG=en"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "if ((Get-UICulture).TwoLetterISOLanguageName -eq 'ru' -or (Get-Culture).TwoLetterISOLanguageName -eq 'ru') { Write-Output 'ru' } else { Write-Output 'en' }"`) do set "SYS_LANG=%%A"

call :log "Language detected: %SYS_LANG%"

if /i "%SYS_LANG%"=="ru" (
    goto lang_ru
) else (
    goto lang_en
)

:lang_en
set "L_ERR_GITHUB=[ERROR] Failed to fetch release info from GitHub."
set "L_ERR_ZIP=[ERROR] Zip archive not found in the latest release."
set "L_ERR_URL=[ERROR] Download URL not found."
set "L_REMOTE_VER=Latest GitHub version"
set "L_NEW_VER=New version available"
set "L_CUR_VER=Current local version"
set "L_UPDATE_ASK=Update now? (y/n): "
set "L_SKIP=Skipping update. Proceeding to settings..."
set "L_NO_UPDATE=Version is up to date."
set "L_FORCE_ASK=Configure current version? (y/n): "
set "L_LOCAL_MISSING=Local files missing. Proceeding with full download."
set "L_SETUP_CUR=Configuring current version"
set "L_INSTALLING=Installing version"
set "L_BACKUP_ASK=Create backup? (y/n): "
set "L_BACKUP_CREATING=Creating backup in"
set "L_BACKUP_FAIL=[WARNING] Failed to create backup!"
set "L_BACKUP_CONT=Continue without backup? (y/n): "
set "L_BACKUP_CANCEL=Update cancelled by user."
set "L_BACKUP_OK=Backup created successfully."
set "L_MERGING=Merging domain lists..."
set "L_COPY_ERR=[ERROR] robocopy failed with code"
set "L_SUCCESS=Version successfully installed."
set "L_MENU_HEADER=Select action:"
set "L_MENU_1=1. Use last configuration"
set "L_MENU_2=2. Auto-test and select best config"
set "L_MENU_3=3. Select configuration manually"
set "L_MENU_4=4. Exit"
set "L_MENU_CHOICE=Your choice? (1-4): "
set "L_ERR_LAST_CONF=[ERROR] Last configuration not defined."
set "L_AVAIL_CONFS=Available configurations:"
set "L_ENTER_NUM=Enter configuration number: "
set "L_TEST_ADD=Adding this script to test exceptions..."
set "L_TEST_RUN=Running configuration tests (Standard Test)..."
set "L_TEST_WAIT=Please wait..."
set "L_BEST_CONF=Best configuration:"
set "L_ERR_CONF_FAIL=[ERROR] Failed to determine configuration. Select manually."
set "L_ERR_PROF_NOT_FOUND=[ERROR] Target profile not found in"
set "L_ERR_WINWS=[ERROR] winws.exe not found."
set "L_SVC_CREATE_FAIL=[ERROR] Failed to create service."
set "L_SVC_START_FAIL=[ERROR] Failed to start service."
set "L_DONE=Done."
set "L_EXIT=Press any key to exit..."
set "L_FAIL_STEP=[ERROR] Update failed at step:"
set "L_FAIL_CODE=[ERROR] Error code:"
goto main_logic

:lang_ru
set "L_ERR_GITHUB=[ОШИБКА] Не удалось получить данные о релизе с GitHub."
set "L_ERR_ZIP=[ОШИБКА] Zip-архив не найден в последнем релизе."
set "L_ERR_URL=[ОШИБКА] Ссылка на скачивание zip-архива не найдена."
set "L_REMOTE_VER=Последняя версия на GitHub"
set "L_NEW_VER=Доступна новая версия"
set "L_CUR_VER=Текущая локальная версия"
set "L_UPDATE_ASK=Обновить сейчас? (y/n): "
set "L_SKIP=Пропускаю обновление. Переход к настройкам..."
set "L_NO_UPDATE=Версия актуальна."
set "L_FORCE_ASK=Настроить текущую версию? (y/n): "
set "L_LOCAL_MISSING=Локальные файлы отсутствуют. Продолжаю полную загрузку."
set "L_SETUP_CUR=Настройка текущей версии"
set "L_INSTALLING=Устанавливаю версию"
set "L_BACKUP_ASK=Хочешь создать резервную копию? (y/n): "
set "L_BACKUP_CREATING=Создаю резервную копию в"
set "L_BACKUP_FAIL=[ВНИМАНИЕ] Не удалось создать резервную копию!"
set "L_BACKUP_CONT=Продолжить обновление без бекапа? (y/n): "
set "L_BACKUP_CANCEL=Отмена обновления пользователем."
set "L_BACKUP_OK=Резервная копия успешно создана."
set "L_MERGING=Объединяю списки доменов..."
set "L_COPY_ERR=[ОШИБКА] robocopy завершился с кодом"
set "L_SUCCESS=Версия успешно установлена."
set "L_MENU_HEADER=Выбери:"
set "L_MENU_1=1. Использовать последнюю конфигурацию"
set "L_MENU_2=2. Автоматический тест и выбор лучшей конфигурации"
set "L_MENU_3=3. Выбрать конфигурацию вручную"
set "L_MENU_4=4. Выход"
set "L_MENU_CHOICE=Твой выбор? (1-4): "
set "L_ERR_LAST_CONF=[ОШИБКА] Последняя конфигурация не определена."
set "L_AVAIL_CONFS=Доступные конфигурации:"
set "L_ENTER_NUM=Введите номер конфигурации: "
set "L_TEST_ADD=Добавляю этот скрипт в исключения теста..."
set "L_TEST_RUN=Запускаю тестирование конфигураций (Standard Test)..."
set "L_TEST_WAIT=Пожалуйста, подождите..."
set "L_BEST_CONF=Лучшая конфигурация:"
set "L_ERR_CONF_FAIL=[ОШИБКА] Не удалось определить конфигурацию. Выберите вручную."
set "L_ERR_PROF_NOT_FOUND=[ОШИБКА] Целевой профиль не найден в"
set "L_ERR_WINWS=[ОШИБКА] winws.exe не найден."
set "L_SVC_CREATE_FAIL=[ОШИБКА] Не удалось создать службу."
set "L_SVC_START_FAIL=[ОШИБКА] Не удалось запустить службу."
set "L_DONE=Готово."
set "L_EXIT=Нажми любую клавишу для выхода..."
set "L_FAIL_STEP=[ОШИБКА] Обновление не удалось на этапе:"
set "L_FAIL_CODE=[ОШИБКА] Код ошибки:"
goto main_logic

:main_logic
cls
call :log "Entering main logic."
:: Determine GameFilter value / Определяю значение GameFilter
if exist "%ZAPRET_DIR%\utils\game_filter.enabled" (
    set "GameFilter=1024-65535"
    call :log "GameFilter enabled: 1024-65535"
) else (
    set "GameFilter=12"
    call :log "GameFilter disabled: 12"
)

call :check_updates_logic
if "%EXIT_APP%"=="1" exit /b 0
if "%SKIP_DOWNLOAD%"=="0" (
    call :check_disk_space
    call :download_and_extract
    call :cleanup_services
    call :create_backup
    call :merge_lists
    call :copy_files
) else (
    call :cleanup_services
)

goto select_config

:: ============================================================================
:: FUNCTIONS / ФУНКЦИИ
:: ============================================================================

:check_updates_logic
:: Get latest release info (zip archive) / Получаю информацию о последнем релизе (zip-архив)
call :log "Checking for updates..."
set "REMOTE_VERSION="
set "ASSET_NAME="
set "ASSET_URL="
set "STEP=download release metadata"
for /f "usebackq tokens=1,* delims==" %%A in (`powershell -NoProfile -Command "$r=Invoke-RestMethod -Uri 'https://api.github.com/repos/Flowseal/zapret-discord-youtube/releases/latest'; $a=$r.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1; if (-not $a) { exit 2 }; 'REMOTE_VERSION=' + $r.tag_name; 'ASSET_NAME=' + $a.name; 'ASSET_URL=' + $a.browser_download_url"`) do (
    if /i "%%A"=="REMOTE_VERSION" set "REMOTE_VERSION=%%B"
    if /i "%%A"=="ASSET_NAME" set "ASSET_NAME=%%B"
    if /i "%%A"=="ASSET_URL" set "ASSET_URL=%%B"
)
if errorlevel 1 (
    call :log "Warning: Failed to fetch release info from GitHub."
    set "REMOTE_VERSION="
)

if defined REMOTE_VERSION (
    if not defined ASSET_NAME set "REMOTE_VERSION="
    if not defined ASSET_URL set "REMOTE_VERSION="
)

if not defined REMOTE_VERSION (
    call :PrintRed "%L_ERR_GITHUB%"
    call :log "Offline mode. Exiting."
    echo %L_EXIT%
    pause >nul
    set "EXIT_APP=1"
    exit /b 0
) else (
    if /i "!REMOTE_VERSION:~0,1!"=="v" set "REMOTE_VERSION=!REMOTE_VERSION:~1!"
    echo %L_REMOTE_VER%: !REMOTE_VERSION!
    call :log "Remote version: !REMOTE_VERSION!"
)

:: Read local version from installed service.bat (if exists) / Читаю локальную версию из установленного service.bat (если есть)
set "LOCAL_VERSION="
if exist "%ZAPRET_DIR%\service.bat" (
    for /f "tokens=2 delims==" %%A in ('findstr /i /r "LOCAL_VERSION=" "%ZAPRET_DIR%\service.bat"') do (
        set "LOCAL_VERSION=%%A"
    )
)
if defined LOCAL_VERSION set "LOCAL_VERSION=!LOCAL_VERSION:"=!"

if defined LOCAL_VERSION (
    echo %L_CUR_VER%: %LOCAL_VERSION%
    call :log "Local version: %LOCAL_VERSION%"
) else (
    echo %L_CUR_VER%: ???
    call :log "Local version: Unknown"
)

:: Check for missing files / Проверяю наличие файлов
if not exist "%ZAPRET_DIR%\bin\winws.exe" (
    echo %L_LOCAL_MISSING%
    call :log "Local files missing. Forcing download."
    set "SKIP_DOWNLOAD=0"
    exit /b 0
)

set "NEED_UPDATE=0"
if not "%LOCAL_VERSION%"=="%REMOTE_VERSION%" set "NEED_UPDATE=1"
call :log "Need update: %NEED_UPDATE%"

if "%NEED_UPDATE%"=="1" (
    echo.
    call :PrintYellow "%L_NEW_VER%: %REMOTE_VERSION% (%L_CUR_VER%: %LOCAL_VERSION%)"
    set "DO_UPD="
    set /p "DO_UPD=%L_UPDATE_ASK%"
    if /i not "!DO_UPD!"=="y" (
        echo.
        echo %L_SKIP%
        set "SKIP_DOWNLOAD=1"
    ) else (
        set "SKIP_DOWNLOAD=0"
    )
) else (
    echo.
    echo %L_NO_UPDATE%
    set "DO_FORCE="
    set /p "DO_FORCE=%L_FORCE_ASK%"
    if /i "!DO_FORCE!"=="y" (
        set "SKIP_DOWNLOAD=1"
    ) else (
        set "EXIT_APP=1"
        exit /b 0
    )
)

if "%SKIP_DOWNLOAD%"=="1" set "STATUS_MSG=%L_SETUP_CUR% %LOCAL_VERSION%."
exit /b 0

:check_disk_space
    call :log "Checking disk space..."
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "if ((Get-Item '%ZAPRET_DIR%').PSDrive.Free -gt 50MB) { Write-Output 'OK' } else { Write-Output 'LOW' }"`) do set "DISK_STATUS=%%A"
    if "%DISK_STATUS%"=="LOW" (
        call :PrintRed "[ERROR] Not enough disk space (need 50MB)."
        call :log "Error: Low disk space."
        set "RC=1"
        goto fail
    )
    call :log "Disk space OK."
exit /b 0

:download_and_extract
    echo %L_INSTALLING% %REMOTE_VERSION%...

    :: Prepare temp folder / Подготавливаю временную папку
    if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
    mkdir "%TEMP_DIR%"

    set "ZIP_PATH=%TEMP_DIR%\%ASSET_NAME%"

    :: Download / Скачиваю
    set "STEP=download release archive"
    where curl >nul 2>&1
    if !errorlevel! equ 0 (
        call :log "Using curl for download..."
        curl -L -o "!ZIP_PATH!" "!ASSET_URL!"
        if !errorlevel! neq 0 goto fail
    ) else (
        call :log "Using PowerShell for download..."
        powershell -NoProfile -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%ASSET_URL%' -OutFile '!ZIP_PATH!' -UseBasicParsing" || goto fail
    )

    :: Extract / Распаковываю
    set "STEP=extract release archive"
    powershell -NoProfile -Command "Expand-Archive -LiteralPath '!ZIP_PATH!' -DestinationPath '%TEMP_DIR%\extracted' -Force" || goto fail

    :: Determine source root folder / Определяю корневую папку исходников
    set "SRC_ROOT=%TEMP_DIR%\extracted"
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$p='%TEMP_DIR%\extracted'; $dirs=Get-ChildItem -LiteralPath $p -Directory; if ($dirs.Count -eq 1 -and (Test-Path (Join-Path $dirs[0].FullName 'service.bat'))) { $dirs[0].FullName } else { $p }"`) do (
        set "SRC_ROOT=%%A"
    )
exit /b 0

:cleanup_services
:: Determine current strategy before removing service / Определяю текущую стратегию перед удалением службы
set "CURRENT_STRATEGY="
for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube 2^>nul') do set "CURRENT_STRATEGY=%%B"
if defined CURRENT_STRATEGY set "CURRENT_STRATEGY=!CURRENT_STRATEGY!.bat"

:: Stop and remove old services / Останавливаю и удаляю старые службы
sc stop "%SERVICE_NAME%" >nul 2>&1
timeout /t 1 /nobreak >nul
taskkill /IM winws.exe /F >nul 2>&1
timeout /t 1 /nobreak >nul
sc delete "%SERVICE_NAME%" >nul 2>&1
sc stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
sc stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
exit /b 0

:create_backup
    :: Create backup of current version (ZIP) / Создаю резервную копию текущей версии (в ZIP)
    if defined LOCAL_VERSION (
        set "DO_BACKUP="
        set /p "DO_BACKUP=%L_BACKUP_ASK%"
        if /i "!DO_BACKUP!"=="y" (
            if not exist "%ZAPRET_DIR%\backups" mkdir "%ZAPRET_DIR%\backups"
            set "BACKUP_FILE=%ZAPRET_DIR%\backups\!LOCAL_VERSION!.zip"
            echo %L_BACKUP_CREATING% "!BACKUP_FILE!"...
            powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%ZAPRET_DIR%' | Where-Object { $_.Name -ne 'backups' -and $_.Name -ne '%~nx0' } | Compress-Archive -DestinationPath '!BACKUP_FILE!' -Force"

            if not exist "!BACKUP_FILE!" (
                echo %L_BACKUP_FAIL%
                set "CHOICE="
                set /p "CHOICE=%L_BACKUP_CONT%"
                if /i not "!CHOICE!"=="y" (
                    set "RC=1"
                    echo %L_BACKUP_CANCEL%
                    goto fail
                )
            ) else (
                echo %L_BACKUP_OK%
            )

            :: Remove old backups (keep last 3 zip archives) / Удаляю старые бекапы (оставляю 3 последних zip архива)
            powershell -NoProfile -Command "$limit = 3; $path = '%ZAPRET_DIR%\backups'; if (Test-Path $path) { $items = Get-ChildItem -Path $path -Filter '*.zip' | Sort-Object CreationTime; if ($items.Count -gt $limit) { $items | Select-Object -First ($items.Count - $limit) | ForEach-Object { Write-Host 'Удаляю старый бекап: ' $_.Name; Remove-Item -LiteralPath $_.FullName -Force } } }"
        )
    )
exit /b 0

:merge_lists
    :: Merge domain lists (keep user lists + add new ones) / Объединяю списки доменов (сохраняю пользовательские + добавляю новые)
    echo %L_MERGING%
    powershell -NoProfile -Command ^
        "$src = '!SRC_ROOT!\lists';" ^
        "$dst = '%ZAPRET_DIR%\lists';" ^
        "if (Test-Path $src) {" ^
        "    Get-ChildItem -Path $src -Filter '*.txt' | ForEach-Object {" ^
        "        $fName = $_.Name;" ^
        "        $srcFile = $_.FullName;" ^
        "        $dstFile = Join-Path $dst $fName;" ^
        "        if (Test-Path $dstFile) {" ^
        "            Write-Host 'Объединяю' $fName '...';" ^
        "            $c1 = @(Get-Content -LiteralPath $dstFile -Encoding UTF8 -ErrorAction SilentlyContinue);" ^
        "            $c2 = @(Get-Content -LiteralPath $srcFile -Encoding UTF8 -ErrorAction SilentlyContinue);" ^
        "            $merged = ($c1 + $c2) | Select-Object -Unique | Sort-Object;" ^
        "            $merged | Set-Content -LiteralPath $srcFile -Encoding UTF8;" ^
        "        }" ^
        "    }" ^
        "}"
exit /b 0

:copy_files
    :: Check if winws.exe is writable (not locked) / Проверяю, доступен ли winws.exe для записи
    if exist "%ZAPRET_DIR%\bin\winws.exe" (
        call :log "Checking write access to winws.exe..."
        powershell -NoProfile -Command "try { $f=[IO.File]::OpenWrite('%ZAPRET_DIR%\bin\winws.exe'); $f.Close(); exit 0 } catch { exit 1 }"
        if !errorlevel! neq 0 (
            call :PrintRed "[ERROR] winws.exe is locked by another process."
            call :log "Error: winws.exe is locked."
            set "RC=1"
            goto fail
        )
    )

    :: Copy files to existing folder (flat structure) / Копирую файлы в существующую папку (без вложенности)
    set "STEP=copy files with robocopy"
    call :log "Copying files using robocopy..."
    robocopy "%SRC_ROOT%" "%ZAPRET_DIR%" /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 /NFL /NDL /NJH /NJS /NP /XF "%~nx0" "update_debug.log"
    set "RC=!ERRORLEVEL!"
    if !RC! GEQ 8 (
        echo %L_COPY_ERR% !RC!.
        call :log "Robocopy failed with code !RC!"
        goto fail
    )
    call :log "Files copied successfully."
    set "STATUS_MSG=%L_SUCCESS%"
exit /b 0

:select_config
cls
call :log "Entering config selection menu."
if defined STATUS_MSG (
    echo [ИНФО] !STATUS_MSG!
    echo.
)
echo.
echo %L_MENU_HEADER%
echo.
if defined CURRENT_STRATEGY (
    echo %L_MENU_1% [!CURRENT_STRATEGY!]
    echo %L_MENU_2%
    echo %L_MENU_3%
    echo %L_MENU_4%
    echo.
    set "choice_conf="
    set /p "choice_conf=%L_MENU_CHOICE%"
    call :log "User menu choice: !choice_conf!"
    if "!choice_conf!"=="1" goto use_last
    if "!choice_conf!"=="2" goto auto_test
    if "!choice_conf!"=="3" goto manual_select
    if "!choice_conf!"=="4" exit /b 0
) else (
    echo 1. %L_MENU_2:~3%
    echo 2. %L_MENU_3:~3%
    echo 3. %L_MENU_4:~3%
    echo.
    set "choice_conf="
    set /p "choice_conf=%L_MENU_CHOICE:~0,-7%(1-3): "
    call :log "User menu choice: !choice_conf!"
    if "!choice_conf!"=="1" goto auto_test
    if "!choice_conf!"=="2" goto manual_select
    if "!choice_conf!"=="3" exit /b 0
)
goto select_config

:use_last
if not defined CURRENT_STRATEGY (
    echo %L_ERR_LAST_CONF%
    call :log "Error: Last configuration not defined."
    pause
    goto select_config
)
set "TARGET_BAT=!CURRENT_STRATEGY!"
call :log "Selected last configuration: !TARGET_BAT!"
goto install_service

:manual_select
echo.
echo %L_AVAIL_CONFS%
call :log "Listing available configurations..."
set "count=0"
for /f "delims=" %%F in ('powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%ZAPRET_DIR%' -Filter '*.bat' | Where-Object { $_.Name -notlike 'service*' -and $_.Name -notlike 'Zapret_updater*' } | Sort-Object { [Regex]::Replace($_.Name, '(\d+)', { $args[0].Value.PadLeft(8, '0') }) } | ForEach-Object { $_.Name }"') do (
    set /a count+=1
    echo !count!. %%F
    set "file!count!=%%F"
)
set /p "conf_idx=%L_ENTER_NUM%"
set "TARGET_BAT=!file%conf_idx%!"
call :log "User selected config index: !conf_idx! -> !TARGET_BAT!"
if not defined TARGET_BAT goto manual_select
goto install_service

:auto_test
echo.
echo %L_TEST_ADD%
call :log "Starting auto-test."

where curl >nul 2>&1
if %errorlevel% neq 0 (
    call :PrintRed "[ERROR] curl.exe not found. Auto-test skipped."
    call :log "Error: curl.exe not found."
    goto manual_select
)

if not exist "%ZAPRET_DIR%\utils\test zapret.ps1" (
    call :PrintRed "[ERROR] test zapret.ps1 not found!"
    call :log "Error: test zapret.ps1 not found."
    goto manual_select
)
call :log "Patching test zapret.ps1..."
powershell -NoProfile -Command "$f='%ZAPRET_DIR%\utils\test zapret.ps1'; $c=Get-Content -LiteralPath $f -Raw; $c=$c -replace '-notlike .service\*.', '-notlike \"service*\" -and $$_.Name -ne ''%~nx0'''; if ($c -notmatch 'IsInputRedirected') { $c=$c -replace '\[void\]\[System\.Console\]::ReadKey\(\$true\)', 'if (-not [System.Console]::IsInputRedirected) { [void][System.Console]::ReadKey($true) }' }; Set-Content -LiteralPath $f -Value $c -Encoding UTF8"

echo %L_TEST_RUN%
echo %L_TEST_WAIT%
call :log "Running test script..."
powershell -NoProfile -Command "echo 1; echo 1" | powershell -NoProfile -ExecutionPolicy Bypass -File "%ZAPRET_DIR%\utils\test zapret.ps1"

set "BEST_CONF="
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "$dir='%ZAPRET_DIR%\utils\test results'; $latest = Get-ChildItem -LiteralPath $dir -Filter 'test_results_*.txt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if ($latest) { $c = Get-Content $latest.FullName | Select-String 'Best strategy: (.+)'; if ($c) { $c.Matches.Groups[1].Value.Trim() } }"`) do set "BEST_CONF=%%A"

if defined BEST_CONF (
    echo.
    echo %L_BEST_CONF% !BEST_CONF!
    call :log "Best configuration found: !BEST_CONF!"
    set "TARGET_BAT=!BEST_CONF!"
    goto install_service
)
echo %L_ERR_CONF_FAIL%
call :log "Error: Failed to determine best configuration."
goto manual_select

:install_service
:: Collect arguments from target .bat / Собираю аргументы из целевого .bat
call :log "Installing service with config: %TARGET_BAT%"
set "BIN_PATH=%ZAPRET_DIR%\bin\"
set "LISTS_PATH=%ZAPRET_DIR%\lists\"
set "selectedFile=%ZAPRET_DIR%\%TARGET_BAT%"

if not exist "%selectedFile%" (
    set "RC=1"
    call :PrintRed "%L_ERR_PROF_NOT_FOUND% %ZAPRET_DIR%."
    call :log "Error: Target profile not found."
    goto fail
)
if not exist "%BIN_PATH%winws.exe" (
    set "RC=1"
    call :PrintRed "%L_ERR_WINWS%"
    call :log "Error: winws.exe not found."
    goto fail
)

set "args_with_value=sni host altorder"
set "args="
set "capture=0"
set "mergeargs=0"
set QUOTE="

call :log "Parsing arguments from file..."
for /f "tokens=*" %%a in ('type "%selectedFile%"') do (
    set "line=%%a"
    call set "line=%%line:^!=EXCL_MARK%%"

    echo !line! | findstr /i "winws.exe" >nul
    if not errorlevel 1 (
        set "capture=1"
    )

    if !capture!==1 (
        if not defined args (
            set "line=!line:*winws.exe"=!"
        )

        set "temp_args="
        for %%i in (!line!) do (
            set "arg=%%i"
            set "arg=!arg:%%GameFilter%%=%GameFilter%!"

            if not "!arg!"=="^" (
                if "!arg:~0,2!" EQU "--" if not !mergeargs!==0 set "mergeargs=0"

                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"

                    echo !arg! | findstr ":" >nul
                    if !errorlevel!==0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!"=="@" (
                        set "arg=\!QUOTE!%ZAPRET_DIR%\!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!"=="%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else if "!arg:~0,7!"=="%%LISTS%%" (
                        set "arg=\!QUOTE!!LISTS_PATH!!arg:~7!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%ZAPRET_DIR%\!arg!\!QUOTE!"
                    )
                ) else if "!arg:~0,12!" EQU "%%GameFilter%%" (
                    set "arg=%GameFilter%"
                )

                if !mergeargs!==1 (
                    set "temp_args=!temp_args!,!arg!"
                ) else if !mergeargs!==3 (
                    set "temp_args=!temp_args!=!arg!"
                    set "mergeargs=1"
                ) else (
                    set "temp_args=!temp_args! !arg!"
                )

                if "!arg:~0,2!" EQU "--" (
                    set "mergeargs=2"
                ) else if !mergeargs! GEQ 1 (
                    if !mergeargs!==2 set "mergeargs=1"

                    for %%x in (!args_with_value!) do (
                        if /i "%%x"=="!arg!" set "mergeargs=3"
                    )
                )
            )
        )

        if not "!temp_args!"=="" (
            set "args=!args! !temp_args!"
        )
    )
)

:: Enable TCP timestamps / Включаю TCP timestamps
set "STEP=enable tcp timestamps"
call :log "Enabling TCP timestamps..."
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" >nul || netsh interface tcp set global timestamps=enabled >nul 2>&1

set ARGS=%args%
call set "ARGS=%%ARGS:EXCL_MARK=^!%%"

:: Create and start service / Создаю и запускаю службу
set "STEP=create zapret service"
call :log "Creating service %SERVICE_NAME%..."
sc create %SERVICE_NAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto
sc query %SERVICE_NAME% >nul 2>&1
if errorlevel 1 (
    set "RC=1"
    call :PrintRed "%L_SVC_CREATE_FAIL%"
    call :log "Error: Failed to create service."
    sc qc %SERVICE_NAME%
    goto fail
)
sc description %SERVICE_NAME% "Zapret DPI bypass software"
set "STEP=start zapret service"
call :log "Starting service..."
sc start %SERVICE_NAME%
timeout /t 2 >nul
sc query %SERVICE_NAME% | findstr /i "RUNNING" >nul
if errorlevel 1 (
    set "RC=1"
    call :PrintRed "%L_SVC_START_FAIL%"
    call :log "Error: Failed to start service."

    if defined BACKUP_FILE if exist "!BACKUP_FILE!" (
        call :PrintYellow "Backup detected: !BACKUP_FILE!"
        set "DO_RESTORE="
        set /p "DO_RESTORE=Service failed to start. Restore backup? (y/n): "
        if /i "!DO_RESTORE!"=="y" (
            call :log "Restoring backup..."
            powershell -NoProfile -Command "Expand-Archive -LiteralPath '!BACKUP_FILE!' -DestinationPath '%ZAPRET_DIR%' -Force"
            call :log "Backup restored."
            call :PrintGreen "Backup restored. Please run the script again to reinstall the service."
            pause
            exit /b 0
        )
    )

    sc query %SERVICE_NAME%
    sc qc %SERVICE_NAME%
    tasklist /FI "IMAGENAME eq winws.exe"
    goto fail
)

call :log "Service started successfully."
for %%F in ("%selectedFile%") do set "filename=%%~nF"
reg add "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube /t REG_SZ /d "!filename!" /f
call :log "Registry updated with strategy: !filename!"

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
call :log "Temp directory cleaned."

call :PrintGreen "%L_DONE%"
call :PrintYellow "%L_EXIT%"
call :log "Script finished successfully."
pause >nul
exit /b 0

:fail
if not defined RC set "RC=%errorlevel%"
call :PrintRed "%L_FAIL_STEP% %STEP%"
call :PrintRed "%L_FAIL_CODE% %RC%"
call :PrintYellow "%L_EXIT%"
call :log "Script failed at step: %STEP% with code: %RC%"
pause >nul
exit /b %RC%

:PrintGreen
set "MSG=%~1"
powershell -NoProfile -Command "Write-Host $env:MSG -ForegroundColor Green"
exit /b

:PrintRed
set "MSG=%~1"
powershell -NoProfile -Command "Write-Host $env:MSG -ForegroundColor Red"
exit /b

:PrintYellow
set "MSG=%~1"
powershell -NoProfile -Command "Write-Host $env:MSG -ForegroundColor Yellow"
exit /b

:log
if not "%ENABLE_LOGGING%"=="1" exit /b
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
exit /b
