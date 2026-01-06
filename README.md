# 🧱 Homelab Infrastructure Documentation

**Platform:** Proxmox VE + Docker + Portainer  
**Status:** Current / Stable Baseline

---

## 📌 Overview

This repository documents my personal homelab environment built on **Proxmox VE** with a **Docker VM managed via Portainer**.

The goals of this lab are:

- Hands-on experience with virtualization and containers
- Monitoring and observability practice
- Infrastructure documentation and reproducibility
- Resume-ready DevOps / SRE skill development

---

## 🖥️ Physical Host

### Hardware
- Bare-metal server

### Hypervisor
- **Platform:** Proxmox VE
- **Network Bridge:** vmbr0
- **Management Interface:**
- https://<proxmox-ip>:8006
---

## 🧩 Virtualization Layer

### Docker / Portainer VM
- **OS:** Linux (Ubuntu/Debian-based)
- **Purpose:** Container runtime host
- **Installed Software:**
- Docker Engine
- Docker Compose
- Portainer

This VM hosts all containerized services in the homelab.

---

## 🐳 Container Management

### Portainer
- **Role:** Docker environment management
- **Access:**
- http://<docker-vm-ip>:9000
- **Responsibilities:**
- Container lifecycle management
- Stack deployments (Docker Compose)
- Volume and network management

---

## 📈 Monitoring Stack

All monitoring services run as Docker containers inside the Docker VM.

### Prometheus
- **Port:** 9090
- **Purpose:** Metrics collection and storage
- **Status:** Operational
- **Access:**
- http://<docker-vm-ip>:9090

---

### Grafana
- **Port:** 3001
- **Purpose:** Metrics visualization and dashboards
- **Data Source:** Prometheus
- **Access:**
- http://<docker-vm-ip>:3001

---

## 🔄 Metrics Flow

Exporters
↓
Prometheus (scrape & store)
↓
Grafana (query & visualize)

---

## 🌐 Network Access Summary

| Service     | Location        | Port |
|------------|-----------------|------|
| Proxmox UI | Bare-metal host | 8006 |
| Portainer  | Docker VM       | 9000 |
| Prometheus | Docker container| 9090 |
| Grafana    | Docker container| 3001 |

---

## 🗺️ Architecture Diagram

```mermaid
graph TD
  User -->|LAN| Proxmox
  Proxmox -->|vmbr0| DockerVM
  DockerVM -->|Docker| Portainer
  DockerVM -->|Metrics| Prometheus
  Prometheus -->|Data Source| Grafana
