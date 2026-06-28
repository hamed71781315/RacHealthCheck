Based on the uploaded script, here's a professional GitHub repository description suitable for an open-source project.

---

# Oracle RAC Health Check Automation

A comprehensive Bash-based health check framework for **Oracle Real Application Clusters (RAC)** environments. The script automatically discovers cluster resources, databases, ASM instances, and services, then generates a detailed health report covering the entire Oracle RAC stack.

## Features

* 🔍 Automatic Oracle RAC node discovery
* 🖥 Clusterware (CRS) health verification
* 🌐 Inter-node network connectivity tests
* 💽 ASM disk group and disk status validation
* 🗄 Automatic RAC database discovery
* 📊 Database health assessment
* 📂 Tablespace utilization monitoring
* ❌ Invalid object detection
* 🔒 Blocking session identification
* 📦 Archive destination status verification
* 💾 Fast Recovery Area (FRA) usage monitoring
* ⚙ Oracle Services configuration and status checks
* 🎧 Listener status verification
* 🗳 OCR and Voting Disk validation
* 📈 Operating system performance metrics
* 🚨 Oracle Alert Log error scanning
* 📝 Timestamped health check reports
* 🎨 Colorized console output for improved readability

---

## Health Check Coverage

The script performs end-to-end validation of:

* Oracle Clusterware (CRS)
* RAC Nodes
* Network Connectivity
* ASM Disk Groups
* ASM Disks
* Oracle Databases
* Instance Status
* Database Role & Open Mode
* Tablespace Utilization
* Invalid Database Objects
* Blocking Sessions
* Archive Destinations
* Fast Recovery Area (FRA)
* RAC Services
* Listener Status
* OCR Integrity
* Voting Disks
* CPU & Load Average
* Memory Utilization
* I/O Performance
* VM Statistics
* Oracle Alert Logs

---

## Report Example

The script automatically generates a timestamped report:

```text
/tmp/rac_healthcheck_<hostname>_<timestamp>.log
```

The report contains complete execution results, making it ideal for:

* Preventive maintenance
* Routine health checks
* Incident troubleshooting
* Oracle RAC audits
* Capacity planning
* Production environment validation

---

## Requirements

* Oracle Linux / Linux
* Oracle RAC
* Oracle Grid Infrastructure
* Bash
* SQL*Plus
* SRVCTL
* CRSCTL
* ASM
* Appropriate privileges for both **grid** and **oracle** users

---

## Usage

```bash
chmod +x rac.sh
./rac.sh
```

The script automatically discovers the environment and requires no database names or cluster configuration as input.

---

## Output

The health report includes:

* Cluster topology
* Database inventory
* ASM configuration
* Storage status
* Service configuration
* Database health
* Performance statistics
* Critical Oracle errors
* Overall environment summary

---

## Highlights

* **Zero-configuration auto-discovery**
* **Production-ready reporting**
* **Comprehensive Oracle RAC diagnostics**
* **Designed for Oracle DBAs**
* **Single-command execution**
* **Ideal for scheduled health checks via cron**

---

## Author

**Hamed Esmaeili**

