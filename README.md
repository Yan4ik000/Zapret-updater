# 🚀 Zapret Updater & Manager

**Zapret Updater** is a powerful tool for automatic updating, configuration, and management of the **Zapret** service (DPI bypass).
The script handles all the routine tasks: downloading new versions, creating backups, merging domain lists, and selecting the best bypass strategy.

> **⚠️ IMPORTANT: DO NOT RENAME THE SCRIPT FILE!**
> The script must be named strictly `Zapret_updater.bat`.
> If you change the name, it will start appearing in configuration lists, interfere with tests, and may work incorrectly.

## ✨ Key Features

*   **Automatic Update**: Checks GitHub for new releases and downloads them (uses `curl` or `PowerShell`).
*   **Smart Backups**: Offers to create a ZIP archive of the current version before any changes. If something goes wrong, you can roll back.
*   **List Preservation**: Your added domains will not be lost. The script merges your current lists (`lists`) with new ones from the update.
*   **Auto-Test Strategies**: Can run the standard test (`test zapret.ps1`), automatically find the best working configuration, and immediately install it as a service.
*   **Service Management**: Correctly stops and removes the old service, checks for conflicts, and installs the new one.
*   **Safety**:
    *   Checks for free disk space.
    *   Checks if files (`winws.exe`) are locked by other processes.
    *   Offers **automatic rollback** if the service fails to start after an update.
*   **Multi-language**: Automatically detects system language (Russian / English).

## 📋 Requirements

*   **OS**: Windows 7 SP1 / 8.1 / 10 / 11 (x64).
*   **PowerShell**: Version 5.0 or higher (built-in on Windows 10/11).
*   **Admin Rights**: The script will request them upon launch.
*   **Internet**: Connection required to check for updates.

## 🛠️ Installation and Usage

1.  Download the `Zapret_updater.bat` file.
2.  Place it in the **root folder** of your Zapret installation.
    *   **Correct location:** Next to the `service.bat` file and the `bin` folder.
    *   *Example path:* `D:\Program files\Zapret\Zapret_updater.bat`
3.  Run the script.

### ⛔ What NOT to do (to avoid errors)

1.  **Do not rename the `Zapret_updater.bat` file**.
    *   Internal Zapret mechanisms (tests and service menu) are configured to ignore this specific name. Any other name will cause the update script to be treated as a launch config.
2.  **Do not move the script to other folders (e.g., inside `bin` or `utils`)**.
    *   The script must reside in the root to correctly locate the `bin` folder with the `winws.exe` executable.
3.  **Do not manually delete the `backups` folder while the script is running**.
    *   This may lead to errors when attempting to create or restore a backup.
4.  **Do not run the script from inside an archive**.
    *   Extract it to the Zapret folder first.

### Action Menu

After checking for updates, the script will offer options:

1.  **Use last configuration** — Quickly reinstall the service with the same config as before the update.
2.  **Automatic test** — Runs strategy iteration, finds a working one, and installs it.
3.  **Select manually** — Allows choosing any `.bat` file from the folder to install as a service.

## 🛡️ Safety and Recovery

*   **Backups**: Saved in the `backups/` folder inside the Zapret directory. The script keeps the last 3 versions.
*   **Emergency Recovery**: If the service fails to start after an update (e.g., config is outdated), the script will offer a single button to restore files from the just-created backup.

## ⚙️ Logging

If you encounter problems, you can enable detailed logging.
Open the script in a text editor and change the line:
```bat
set "ENABLE_LOGGING=1"
```
The log will be written to the `update_debug.log` file.

---
*This script is an addition to the zapret-discord-youtube project.*

*

# 🚀 Zapret Updater & Manager

**Zapret Updater** — это мощный инструмент для автоматического обновления, настройки и управления службой **Zapret** (средство обхода DPI).
Скрипт берет на себя всю рутину: скачивание новой версии, создание резервных копий, объединение списков доменов и выбор лучшей стратегии обхода.

> **⚠️ ВАЖНО: НЕ ПЕРЕИМЕНОВЫВАЙТЕ ФАЙЛ СКРИПТА!**
> Скрипт должен называться строго `Zapret_updater.bat`.
> Если вы измените имя, он начнет появляться в списках конфигураций, мешать тестам и может работать некорректно.

## ✨ Основные возможности

*   **Автоматическое обновление**: Проверяет GitHub на наличие новых релизов и скачивает их (использует `curl` или `PowerShell`).
*   **Умные бекапы**: Перед любым изменением предлагает создать ZIP-архив текущей версии. Если что-то пойдет не так, можно откатиться.
*   **Сохранение списков**: Ваши добавленные домены не пропадут. Скрипт объединяет ваши текущие списки (`lists`) с новыми из обновления.
*   **Авто-тест стратегий**: Умеет запускать стандартный тест (`test zapret.ps1`), автоматически находить лучшую рабочую конфигурацию и сразу устанавливать её в службу.
*   **Управление службой**: Корректно останавливает, удаляет старую службу, проверяет конфликты и устанавливает новую.
*   **Безопасность**:
    *   Проверяет свободное место на диске.
    *   Проверяет, не заблокированы ли файлы (`winws.exe`) другими процессами.
    *   Предлагает **автоматический откат**, если после обновления служба не запустилась.
*   **Мультиязычность**: Автоматически определяет язык системы (Русский / English).

## 📋 Требования

*   **ОС**: Windows 7 SP1 / 8.1 / 10 / 11 (x64).
*   **PowerShell**: Версия 5.0 или выше (встроена в Windows 10/11).
*   **Права администратора**: Скрипт сам запросит их при запуске.
*   **Интернет**: Требуется подключение для проверки обновлений.

## 🛠️ Установка и использование

1.  Скачайте файл `Zapret_updater.bat`.
2.  Поместите его в **корневую папку** вашей установки Zapret.
    *   **Правильное расположение:** Рядом с файлом `service.bat` и папкой `bin`.
    *   *Пример пути:* `C:\Program files\Zapret\Zapret_updater.bat`
3.  Запустите скрипт.

### ⛔ Чего делать НЕЛЬЗЯ (во избежание ошибок)

1.  **Не переименовывайте файл `Zapret_updater.bat`**.
    *   Внутренние механизмы Zapret (тесты и сервисное меню) настроены на игнорирование именно этого имени. Любое другое имя приведет к тому, что скрипт обновления будет восприниматься как конфиг для запуска.
2.  **Не перемещайте скрипт в другие папки (например, внутрь `bin` или `utils`)**.
    *   Скрипт должен лежать в корне, чтобы правильно находить папку `bin` с исполняемым файлом `winws.exe`.
3.  **Не удаляйте папку `backups` вручную во время работы скрипта**.
    *   Это может привести к ошибкам при попытке создания или восстановления резервной копии.
4.  **Не запускайте скрипт из архива**.
    *   Сначала распакуйте его в папку с Zapret.

### Меню действий

После проверки обновлений скрипт предложит варианты:

1.  **Использовать последнюю конфигурацию** — Быстро переустановить службу с тем же конфигом, что был до обновления.
2.  **Автоматический тест** — Запустит перебор стратегий, найдет рабочую и установит её.
3.  **Выбрать вручную** — Позволит выбрать любой `.bat` файл из папки для установки в службу.

## 🛡️ Безопасность и восстановление

*   **Бекапы**: Сохраняются в папку `backups/` внутри директории Zapret. Скрипт хранит 3 последние версии.
*   **Аварийное восстановление**: Если после обновления служба не стартует (например, конфиг устарел), скрипт предложит нажать одну кнопку, чтобы восстановить файлы из только что созданного бекапа.

## ⚙️ Логирование

Если у вас возникли проблемы, вы можете включить подробный лог.
Откройте скрипт в текстовом редакторе и измените строку:
```bat
set "ENABLE_LOGGING=1"
```
Лог будет писаться в файл `update_debug.log`.

---
*Этот скрипт является дополнением к проекту zapret-discord-youtube.*
