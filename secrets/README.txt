Папка secrets/ — секреты и cookies оператора.

Что должно лежать здесь:

  .env                  обязательно
    Переменные окружения: токены Telegram, ID получателей, ключ OpenAI,
    ID Google-таблицы и папки Google Drive. Скопируйте .env.example в .env
    и заполните своими значениями.

  credentials.json      обязательно для OAuth-режима (по умолчанию)
    Google OAuth 2.0 Desktop client (Client ID и Client Secret).
    Скачать в Google Cloud Console: APIs & Services -> Credentials ->
    Create credentials -> OAuth client ID -> Desktop app.

  token.json            создаётся автоматически
    Сохранённый OAuth-токен. Появится после первого запуска и успешного
    входа в браузере. Удалите файл, чтобы пройти OAuth заново.

  service_account.json  альтернатива OAuth
    Используется, если в переменной окружения GOOGLE_AUTH_MODE задано
    service_account вместо oauth.

  cookies.txt           нужен для приватных и age-gated видео
    Экспорт cookies YouTube в формате Netscape. Первая строка файла
    должна быть строго:
      # Netscape HTTP Cookie File
    Как получить:
      Chrome / Edge:   расширение "Get cookies.txt LOCALLY"
      Firefox:         расширение "cookies.txt"
    Открыть YouTube под нужным аккаунтом -> экспортировать -> положить
    файл сюда под именем cookies.txt.

  .env.example          шаблон .env, можно копировать как шаблон

Что НЕ нужно делать:
  - Не класть сюда пустой или произвольный cookies.txt: программа
    распознает невалидный формат на старте и откажется запускаться.
  - Не коммитить содержимое этой папки в git: всё, кроме README.txt и
    .env.example, в .gitignore.
