# Pixie EHR – Database Scripts

This folder contains PowerShell scripts used to initialize and manage your PostgreSQL database schema.

## Main Script: import_all_sql.ps1

- Executes all `.sql` files in the `/db/init/` folder in sorted order
- Logs all actions to `db/logs/`
- Logs errors to `db/errors/`
- Halts on failure
- Requires environment variables to be loaded from env.dev.ps1

## How to Run

1. Load environment:
```powershell
. .\env.dev.ps1
```

2. Import schema:
```powershell
.\import_all_sql.ps1
```

## Other Scripts

### reset_db.ps1

- Drops and recreates the database
- Does not import schema (run import manually after)

### export_schema.ps1

- Dumps schema (no data) to a timestamped `.sql` file

### verify_schema.ps1

- Checks that required tables exist and logs the result

## Folder Structure

```
pixie/
└── db/
    ├── init/
    ├── logs/
    ├── errors/
    └── scripts/
        ├── import_all_sql.ps1
        ├── reset_db.ps1
        ├── export_schema.ps1
        ├── verify_schema.ps1
        └── env.dev.ps1
```

## SQL File Naming

SQL files should be named to control execution order:
```
001_create_clients.sql
002_create_claims.sql
010_add_indexes.sql
020_seed_defaults.sql
```

## Prerequisites

- PostgreSQL 17
- PowerShell 5 or later
- PostgreSQL CLI tools (`psql`, `pg_dump`, etc.)
- Environment variables loaded from `env.dev.ps1`
