# CMS to Report API System Integration Pipeline / Конвейер интеграции

Automated data synchronization pipeline built using **n8n**, **PostgreSQL**, and **Python** to connect a parts catalog (**System 1: CMS**) to a compliance tracking server (**System 3: Report API**).

Автоматизированный конвейер синхронизации данных, построенный на базе **n8n**, **PostgreSQL** и **Python** для связи каталога запчастей (**Система 1: CMS**) с сервером сбора отчетности (**Система 3: Report API**).

---

## 📁 Repository Structure / Структура репозитория

* `compose.yml` - Multi-container stack (n8n + AI Sandboxes + SearXNG + Postgres `db`).
* `volume-backup.tar` - Pre-populated Docker volume data backup for immediate database initialization.
* `n8n_workflow_CMS to Report API Integration.json` - Complete production n8n workflow.
* `create_table_query_for_postgres.sql` - SQL script to initialize the database schema manually.
* `searxng-settings.yml` - Configuration file for SearXNG engine.
* `.env_example` - Template file containing database keys and environment ports.
* `.gitignore` - Rule file to ensure local session folders and active `.env` stay private.

---

## 🚀 Quick Start Guide / Руководство по запуску (English / Русский)

### 1. Run the n8n Installation Script / Запуск инсталляционного скрипта n8n
Execute the official one-line command to build the base environment:
```bash
curl -fsSL https://n8n.io | sh
```
*RU:* Выполните официальную команду в терминале, чтобы загрузить базовую конфигурацию стека. Это создаст структуру директорий проекта и базовый файл `.env`.

### 2. Configure Environment Variables / Настройка переменных окружения
Open the generated `.env` file and append your custom configurations at the very bottom:

*RU:* Откройте созданный файл `.env` и добавьте ваши настройки подключения к API и базе данных в самый конец файла:

```env
# --- APPEND YOUR OWN DATA HERE ---
API_HOST=<YOUR_API_HOST>
API_PORT=<YOUR_API_PORT>
API_USERNAME=<YOUR_STUDENT_USERNAME>
API_PASSWORD=<YOUR_STUDENT_ASSIGNMENT_PASSWORD>

DB_HOST=local-postgres
DB_NAME=spares_db
DB_USER=<YOUR_DATABASE_USER>
DB_PASSWORD=<YOUR_DATABASE_PASSWORD>
DB_PORT=5432
```

### 3. Start the Services / Запуск контейнеров
Apply the changes and start the background services:
```bash
docker compose up -d
```
* **n8n Canvas:** [http://localhost:5678](http://localhost:5678)
* *RU:* Примените конфигурацию и запустите фоновые службы с помощью Docker Compose. Интерфейс n8n будет доступен по адресу выше.

### 4. Initialize the Database / Инициализация базы данных

#### Option A: Automated Restoration (Recommended) / Вариант А: Автоматическое восстановление
The stack includes a `db-init` sidecar container. If the root folder contains `volume-backup.tar`, running `docker compose up -d` will automatically restore pre-seeded database schemas and relational data tables on the very first boot.

*RU:* Стек включает в себя вспомогательный контейнер `db-init`. Если в корневой директории присутствует файл `volume-backup.tar`, команда `docker compose up -d` автоматически восстановит структуру схем и таблицы данных при самом первом запуске СУБД.

#### Option B: Manual SQL Setup / Вариант Б: Ручная настройка через SQL
If you do not have the backup tarball file, execute the contents of `create_table_query_for_postgres.sql` inside your PostgreSQL database to construct the clean table schema manually before running the workflow.

*RU:* Если архив резервной копии отсутствует, выполните содержимое файла `create_table_query_for_postgres.sql` внутри вашей СУБД PostgreSQL для ручной сборки пустой таблицы перед запуском основного сценария.

---

## ⚙️ Workflow Architecture / Архитектура конвейера

```text
[Manual/Schedule Trigger] 
       │
       ▼
 [GET /cms/spares]  ──► Automated loops through pages until data runs out.
       │               (Автоматический цикл по страницам до полной выгрузки)
       ▼
[DB: Upsert Spares] ──► Overwrites records via `ON CONFLICT (spareCode)` into Postgres.
       │               (Сохранение строк в Postgres с обновлением дубликатов)
       ▼
[DB: Select Clean]  ──► Extracts fields in sequence, isolated from CMS mutations.
       │               (Выборка полей в строгой последовательности для отчета)
       ▼
[Format: Matrix]    ──► Python node converts table data into headerless semicolon rows.
       │               (Python-скрипт собирает матрицу БД в CSV-строку с `;`)
       ▼
 [POST /auth/login] ──► Pulls a short-lived Bearer JWT token.
       │               (Запрос и получение временного токена Bearer JWT)
       ▼
 [POST /report/csv] ──► Streams raw UTF-8 CSV string payload to the target endpoint.
                       (Отправка чистого текстового потока CSV на сервер отчетов)
```
