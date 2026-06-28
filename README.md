Here's a professional GitHub project description you can use for your repository.

---

# Oracle Data Pump Backup Automation Script

A professional Bash automation framework for managing **Oracle Data Pump (expdp)** backups with support for **hourly, daily, and weekly backup policies**, automatic retention management, comprehensive logging, and resilient error handling.

## Features

* 🚀 Supports **Hourly**, **Daily**, and **Weekly** backup modes
* 📦 Automated Oracle Data Pump exports (`expdp`)
* 🔄 Batch execution of multiple `.par` files
* 📁 Automatic organization of dump and log files into timestamped directories
* 📝 Detailed execution logs for every export job
* ⚠️ Error detection with failed export reporting
* ⏭ Continues processing remaining databases even if one export fails
* 🧹 Automatic cleanup of expired backups using configurable retention policies
* ⚡ Parallel Data Pump exports
* 🗜 Compression enabled (`compression=all`)
* 📊 Runtime statistics and execution summary
* 🔐 SYSDBA authentication support
* 🎨 Colorized terminal output for better readability

## Backup Modes

| Mode   | Option | Content       | Retention |
| ------ | ------ | ------------- | --------- |
| Hourly | `-h`   | Full Export   | 10 days   |
| Daily  | `-d`   | Data Only     | 10 days   |
| Weekly | `-w`   | Metadata Only | 30 days   |

## Directory Structure

```text
EXP_HOUR/
├── YYYY-MM-DD_HH-MM/
├── log/
│   └── error/

EXP_DAILY/
├── YYYY-MM-DD_HH/
├── log/
│   └── error/

EXP_WEEKLY/
├── YYYY-MM-DD/
├── log/
│   └── error/
```

## Requirements

* Oracle Database
* Oracle Data Pump (`expdp`)
* Bash
* Oracle environment variables properly configured
* Oracle DIRECTORY objects created for each backup destination

Example:

```sql
CREATE OR REPLACE DIRECTORY PUMP_HOUR AS '/path/EXP_HOUR';
CREATE OR REPLACE DIRECTORY PUMP_DAILY AS '/path/EXP_DAILY';
CREATE OR REPLACE DIRECTORY PUMP_WEEKLY AS '/path/EXP_WEEKLY';
```

## Usage

```bash
# Hourly backup
./backup.sh -h

# Daily backup
./backup.sh -d

# Weekly backup
./backup.sh -w
```

## Key Capabilities

* Executes all `.par` files automatically in sorted order
* Creates individual logs for every export job
* Generates an error report for failed exports
* Moves generated dump and log files into timestamped backup folders
* Removes expired backups according to the configured retention period
* Displays a complete execution summary with total runtime

## Customization

The script can be easily customized by modifying:

* Oracle environment variables
* Backup directories
* Retention periods
* Data Pump parameters
* Parallelism level
* Compression options
* Export content (Full / Data Only / Metadata Only)

## Author

**Hamed Esmaeili**
