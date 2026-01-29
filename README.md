# 🧱 Homelab Infrastructure Documentation

**Platform:** Proxmox VE + Docker + Portainer  
**Status:** Production / Active  
**Last Updated:** January 2026

---

## 📌 Overview

This repository documents my personal homelab environment built on **Proxmox VE** with a **Docker VM managed via Portainer**. This setup runs media services, monitoring infrastructure, and various utility containers.

### Goals
- Hands-on experience with virtualization and containerization
- Infrastructure-as-Code practice
- Monitoring and observability
- Media server automation
- Resume-ready DevOps/SRE skill development

---

## 🖥️ Hardware Specifications

### Physical Host
- **CPU:** Intel Core i5-6600K
- **Motherboard:** MSI H110I Pro
- **RAM:** 32GB
- **Storage:**
  - **OS/VMs:** 1TB SSD (Proxmox system + VM storage)
  - **Backups:** 2TB WD Red HDD
  - **Media/Files:** 4TB Seagate IronWolf HDD

### Hypervisor
- **Platform:** Proxmox VE
- **Network Bridge:** vmbr0
- **Management Interface:** https://<proxmox-ip>:8006

---

## 🧩 Virtual Machines

### Docker Host VM (Primary)
- **OS:** Ubuntu/Debian-based Linux
- **Resources:**
  - **CPU:** 4 cores
  - **RAM:** 16GB
  - **Disk:** 120GB (on 1TB SSD)
- **Purpose:** Container runtime host for all services
- **Network:** Bridged (vmbr0)
- **Installed Software:**
  - Docker Engine
  - Docker Compose
  - Portainer
  - Tailscale (for remote access)

---

## 🐳 Container Services

All services run as Docker containers managed through Portainer.

### 📊 Management & Monitoring

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| **Portainer** | 9000 | Docker container management UI | ✅ Running |
| **Homepage** | TBD | Unified dashboard for all services | ✅ Running |
| **Prometheus** | 9090 | Metrics collection and storage | ✅ Running |
| **Grafana** | 3001 | Metrics visualization and dashboards | ✅ Running |
| **Nginx Proxy Manager (NPM)** | 80/443, 81 (admin) | Reverse proxy & SSL management | ⚠️ Planned |

### 🎬 Media Stack

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| **Plex** | 32400 | Media server | ✅ Running |
| **Sonarr** | 8989 | TV show automation | ✅ Running |
| **Radarr** | 7878 | Movie automation | ✅ Running |
| **Prowlarr** | 9696 | Indexer management | ✅ Running |
| **Transmission/qBittorrent** | TBD | Download client | TBD |

> **Note:** Update specific ports and add any additional *arr services you're running

---

## 💾 Storage Configuration

### Volume Mappings

```
Proxmox Host
├── 1TB SSD (OS & VMs)
│   └── Docker VM (120GB virtual disk)
│       └── /var/lib/docker (containers & volumes)
├── 2TB WD Red (Backups)
│   └── /mnt/backups (mounted in Docker VM)
│       ├── Proxmox VM backups
│       └── Docker volume backups
└── 4TB Seagate IronWolf (Media & Files)
    └── /mnt/media (mounted in Docker VM)
        ├── /movies
        ├── /tv
        └── /downloads
```

### Container Volume Binds

```yaml
# Example for media services
Plex:
  - /mnt/media/movies:/movies
  - /mnt/media/tv:/tv

Radarr:
  - /mnt/media/movies:/movies
  - /mnt/media/downloads:/downloads

Sonarr:
  - /mnt/media/tv:/tv
  - /mnt/media/downloads:/downloads
```

---

## 🔐 Remote Access

### Tailscale VPN
- **Installation:** 
  - Proxmox host
  - Docker VM (as container)
- **Purpose:** Secure remote access without port forwarding
- **Access Points:**
  - Proxmox web UI
  - Individual container services
  - SSH access to VM

**No public port exposure** - All remote access is through Tailscale mesh VPN.

---

## 📈 Monitoring Architecture

```
Container Metrics
       ↓
   Prometheus (scrape & store)
       ↓
   Grafana (query & visualize)
```

### Prometheus Configuration
- **Scrape Interval:** 15s
- **Retention:** 15 days (default)
- **Targets:**
  - Node Exporter (system metrics)
  - cAdvisor (container metrics)
  - Service-specific exporters

### Grafana Dashboards
- System Overview (CPU, RAM, Disk, Network)
- Container Performance
- Docker Host Metrics
- Plex Statistics (if configured)

---

## 🌐 Network Access Summary

| Service | Access Method | Address |
|---------|---------------|---------|
| Proxmox UI | Direct/Tailscale | https://<proxmox-ip>:8006 |
| Docker VM SSH | Tailscale | ssh user@<vm-tailscale-name> |
| Portainer | Tailscale | http://<vm-ip>:9000 |
| Prometheus | Tailscale | http://<vm-ip>:9090 |
| Grafana | Tailscale | http://<vm-ip>:3001 |
| Plex | Tailscale/Local | http://<vm-ip>:32400/web |
| Homepage | Tailscale/Local | http://<vm-ip>:<port> |

---

## 📋 Docker Compose Stacks

### Available Stacks
- `/stacks/monitoring` - Prometheus, Grafana, exporters
- `/stacks/media` - Plex, *arr services, download client
- `/stacks/management` - Portainer, Homepage
- `/stacks/proxy` - Nginx Proxy Manager (planned)

> **TODO:** Add actual compose files to this repository

---

## 🔄 Backup Strategy

### Proxmox VM Backups
- **Frequency:** Weekly (automated)
- **Location:** 2TB WD Red (`/mnt/backups/proxmox`)
- **Retention:** Last 4 backups
- **Method:** Proxmox built-in backup

### Docker Volume Backups
- **Tool:** Duplicati / Restic (planned)
- **Frequency:** Daily (planned)
- **Location:** 2TB WD Red (`/mnt/backups/docker-volumes`)
- **Included:**
  - Portainer data
  - *arr configuration
  - Prometheus/Grafana configs and dashboards
  - Plex metadata (optional - large)

### Configuration Backups
- **Location:** This GitHub repository
- **Included:**
  - Docker Compose files
  - Service configurations
  - Network/storage documentation

---

## 🚀 Deployment & Recovery

### Fresh Deployment
1. Install Proxmox VE on bare metal
2. Create Docker VM with specified resources
3. Install Docker, Docker Compose, Portainer
4. Mount storage volumes (2TB backup, 4TB media)
5. Deploy stacks using compose files from this repo
6. Configure Tailscale on Proxmox and VM
7. Restore backup data if available

### Service Recovery
1. Pull latest compose files from this repo
2. Restore volume data from 2TB backup drive
3. Deploy stacks via Portainer or `docker compose up -d`
4. Verify service connectivity

---

## 📚 Documentation Structure

```
homelab-proxmox-server/
├── README.md (this file)
├── stacks/
│   ├── monitoring/
│   │   └── docker-compose.yml
│   ├── media/
│   │   └── docker-compose.yml
│   ├── management/
│   │   └── docker-compose.yml
│   └── proxy/
│       └── docker-compose.yml
├── configs/
│   ├── prometheus/
│   ├── grafana/
│   └── tailscale/
└── docs/
    ├── disaster-recovery.md
    ├── service-guides.md
    └── troubleshooting.md
```

---

## ⚠️ Known Issues & Limitations

- **Single VM Architecture:** All services in one VM creates single point of failure
  - *Mitigation:* Regular backups, monitoring VM health
  - *Future:* Consider separating media and monitoring into separate VMs
- **NPM Not Running:** Nginx Proxy Manager configured but not currently active
  - *Reason:* Using Tailscale instead of reverse proxy
  - *Status:* Low priority with current Tailscale setup
- **No Automated Backups:** Manual backup process currently
  - *Planned:* Implement Duplicati/Restic automation

---

## 🎯 Future Improvements

### Short Term
- [ ] Get NPM running (optional with Tailscale)
- [ ] Add automated Docker volume backups (Duplicati/Restic)
- [ ] Create separate monitoring VM for independence
- [ ] Document all Docker Compose files in repo
- [ ] Set up Watchtower or Diun for update notifications

### Long Term
- [ ] Split services across multiple VMs for resilience
- [ ] Implement Infrastructure-as-Code (Terraform/Ansible)
- [ ] Add more Grafana dashboards
- [ ] Expand storage capacity
- [ ] Set up off-site backup solution

---

## 📖 Additional Resources

- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [TRaSH Guides](https://trash-guides.info/) - *arr stack setup guides

---

## 🤝 Contributing

This is a personal homelab documentation repository. Feel free to use this as a template for your own setup or suggest improvements via issues/PRs.

---

## 📝 License

This documentation is provided as-is for educational and reference purposes.

---

**Maintained by:** likeshadic  
**Repository:** https://github.com/likeshadic/homelab-proxmox-server
