🧱 Homelab Infrastructure Documentation

Platform: Proxmox VE + Docker + Portainer
Status: Current / Stable Baseline

📌 Overview

This repository documents my personal homelab environment built on Proxmox VE with a Docker VM managed via Portainer. The primary goals of this lab are:

Hands-on experience with virtualization and containers

Monitoring and observability practice

Infrastructure documentation and reproducibility

Resume-ready DevOps / SRE skill development

🖥️ Physical Host
Hardware

Type: Bare-metal server

Role: Hypervisor host

Hypervisor

Platform: Proxmox VE

Network Bridge: vmbr0

Management Interface:

https://<proxmox-ip>:8006

🧩 Virtualization Layer (Proxmox)
Virtual Machines
🐧 Docker / Portainer VM

OS: Linux (Ubuntu/Debian-based)

Purpose: Container runtime host

Key Software:

Docker Engine

Docker Compose

Portainer

This VM serves as the primary application and monitoring platform for the homelab.

🐳 Container Management
Portainer

Role: Docker environment management

Access:

http://<docker-vm-ip>:9000


Responsibilities:

Container lifecycle management

Stack deployments (Docker Compose)

Volume and network management

📈 Monitoring Stack

All monitoring services run as Docker containers inside the Docker VM.

Prometheus

Port: 9090

Purpose: Metrics collection and storage

Status: ✔ Operational

Notes:

Scrapes configured exporters

Serves as Grafana data source

http://<docker-vm-ip>:9090

Grafana

Port: 3001

Purpose: Metrics visualization and dashboards

Status: ✔ Operational

Data Source: Prometheus

http://<docker-vm-ip>:3001

🔄 Metrics Flow
Exporters
   ↓
Prometheus (scrape & store)
   ↓
Grafana (query & visualize)

🌐 Network Access Summary
Service	Location	Port
Proxmox UI	Bare-metal host	8006
Portainer	Docker VM	9000
Prometheus	Docker container	9090
Grafana	Docker container	3001

All services are accessible from the local LAN.

🗺️ Architecture Diagram (Logical)
┌─────────────────────────────┐
│        Home Network          │
│     (Router / Switch)       │
└──────────────┬──────────────┘
               │
        ┌──────▼──────┐
        │ Proxmox VE  │
        │ Bare Metal  │
        │ vmbr0       │
        └──────┬──────┘
               │
      ┌────────▼────────┐
      │  Docker VM      │
      │  (Linux)        │
      │                 │
      │  ┌──────────┐  │
      │  │ Portainer│  │
      │  │ :9000    │  │
      │  └────┬─────┘  │
      │       │        │
      │  ┌────▼────┐  │
      │  │Prometheus│ │
      │  │ :9090    │ │
      │  └────┬─────┘ │
      │       │        │
      │  ┌────▼────┐  │
      │  │ Grafana │  │
      │  │ :3001   │  │
      │  └─────────┘  │
      └────────────────┘

🚀 Planned Enhancements

Node Exporter

cAdvisor

Alertmanager

Homepage / Homarr dashboard

SMB file sharing for Windows access

Reverse proxy (Traefik or Nginx Proxy Manager)

Backup strategy (Proxmox + Docker volumes)
