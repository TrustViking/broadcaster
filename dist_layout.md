# Portable-структура дистрибутива broadcaster

`build_broadcaster_exe.bat` выполняет сборку и формирует готовый portable-дистрибутив.
После выполнения папка `dist\broadcaster\` является portable-корнем
при наличии внешних ресурсов `tools\`, `secrets\`, `config\`.

## Структура

```
dist\broadcaster\                <- portable-корень
  broadcaster.exe                <- точка запуска (Telegram-бот, иконка вшита)
  run_debug.bat                  <- вспомогательный debug-лончер
  .env.example                   <- пример переменных окружения
  ico_tg.ico                     <- иконка для пользовательских ярлыков
  tools\
    yt-dlp.exe                   <- внешний бинарник, обновляется приложением автоматически
  secrets\
    .env                         <- токены Telegram, API-ключи, Google IDs
    service_account.json         <- Google service account (auth_mode=service_account)
    credentials.json             <- OAuth2 Desktop client (auth_mode=oauth)
    token.json                   <- генерируется при первом OAuth-запуске
  config\
    app_config.yaml              <- пользовательский конфиг; если отсутствует —
                                    создаётся автоматически из bundled при первом запуске
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
