# Portable-структура дистрибутива broadcaster

`build_broadcaster_exe.bat` выполняет сборку и формирует готовый portable-дистрибутив.
После выполнения папка `dist\broadcaster\` является portable-корнем
при наличии внешних ресурсов `tools\`, `secrets\`, `config\`.

## Структура

```
dist\broadcaster\                <- portable-корень
  broadcaster.exe                <- точка запуска (Telegram-бот, иконка вшита)
  run_debug.bat                  <- вспомогательный debug-лончер
  ico_code.ico                   <- иконка для пользовательских ярлыков
  tools\
    yt-dlp.exe                   <- внешний бинарник, обновляется приложением автоматически
  secrets\
    README.txt                   <- инструкция: что должно лежать в этой папке
    .env                         <- токены Telegram, API-ключи, Google IDs
    .env.example                 <- пример переменных окружения
    service_account.json         <- Google service account (auth_mode=service_account)
    credentials.json             <- OAuth2 Desktop client (auth_mode=oauth)
    token.json                   <- генерируется при первом OAuth-запуске
  config\
    README.txt                   <- инструкция: что должно лежать в этой папке
    app_config.yaml              <- пользовательский конфиг; если отсутствует —
                                    создаётся автоматически из bundled при первом запуске
    app_config.example.yaml      <- публичный пример пользовательского конфига
    templates.yaml               <- шаблоны LLM и публикаций
  state\                         <- создаётся автоматически
    ytdlp_last_check.json
    bot_known_groups.json
  logs\                          <- создаётся автоматически
  _internal\                     <- Python runtime (не трогать)
```

## Сборка

```
build_broadcaster_exe.bat
```

## yt-dlp

`yt-dlp.exe` не входит в PyInstaller-сборку. Приложение обновляет его само при старте
через встроенный `ytdlp_updater` (`yt-dlp.exe -U` при истечении интервала обновления).
При первом развёртывании: поместить актуальный `yt-dlp.exe` в `tools\`.

## Примечания

- `config\app_config.yaml` — пользовательская версия конфига. Если отсутствует при старте,
  приложение само создаёт её из bundled-версии внутри `_internal\` и сразу использует.
- `token.json` генерируется при первом запуске через OAuth2-flow. После первого входа
  токен сохраняется, последующие запуски браузер не требуют.
- `state\`, `logs\`, `config\`, `secrets\`, `image\`, `docs\` создаются приложением
  автоматически при первом запуске если отсутствуют.

## Сборка инсталлятора

Для одношаговой сборки полного `.exe`-инсталлятора через Inno Setup:

- `build_release.bat` — публичная сборка, без реальных секретов; подходит для GitHub Release.
- `build_local.bat` — личная сборка с реальными секретами; не публиковать.

Оба батника:
1. Вызывают `build_broadcaster_exe.bat` для PyInstaller-сборки.
2. Запускают `ISCC.exe` против `installer.iss`.
3. Кладут готовый installer в `dist\installer\`:
   - `build_release.bat` → `broadcaster-setup-<version>.exe` (для GitHub Release)
   - `build_local.bat`   → `broadcaster-setup-local-<version>.exe` (для личного использования)

Установщик создаёт один ярлык на рабочем столе:
- **Broadcaster** — запуск через `run_debug.bat`, который вызывает
  `broadcaster.exe` и сохраняет окно консоли с кодом возврата после выхода.
