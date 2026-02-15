# 🧱 Homelab Infrastructure Documentation

**Platform:** Proxmox VE + Docker + Portainer + Terraform  
**Status:** Production / Active  
**Last Updated:** February 2026

---

## 📌 Overview

This repository documents my personal homelab environment built on **Proxmox VE** with a **Docker VM managed via Portainer**. Infrastructure is provisioned using **Terraform (Infrastructure-as-Code)** with the `bpg/proxmox` provider. The setup runs media services, monitoring infrastructure, CI/CD tooling, and various utility containers.

### Goals
- Hands-on experience with virtualization and containerization
- Infrastructure-as-Code practice with Terraform
- CI/CD pipeline development with Gitea
- Monitoring and observability
- Media server automation
- Resume-ready DevOps/Cloud Engineer skill development

---

## 🖥️ Hardware Specifications

### Physical Host
- **CPU:** Intel Core i5-6600K
- **Motherboard:** MSI H110I Pro
- **RAM:** 32GB DDR4
- **Storage:**
  - **OS/VMs:** 1TB SSD (Proxmox system + VM storage) - `local-lvm`
  - **Backups:** 2TB WD Red NAS HDD - ZFS
  - **Media/Files:** 4TB Seagate IronWolf NAS HDD - ZFS

### Hypervisor
- **Platform:** Proxmox VE 9.1
- **Hostname:** prometheus
- **Network Bridge:** vmbr0
- **Management Interface:** https://\<proxmox-ip\>:8006

---

## 🧩 Virtual Machines

All VMs provisioned via Terraform except the original Docker Host.

| VM | IP | CPU | RAM | Disk | Purpose | Managed By |
|---|---|---|---|---|---|---|
| **docker-host** | 192.168.50.42 | 4 cores | 16GB | 120GB | Production containers | Manual |
| **monitoring-01** | 192.168.50.51 | 2 cores | 3GB | 30GB | Prometheus, Grafana, Loki | Terraform |
| **cicd-01** | 192.168.50.52 | 2 cores | 3GB | 30GB | Gitea + CI runners | Terraform |

### Docker Host VM (Production)
- **OS:** Ubuntu LTS
- **Purpose:** Container runtime host for all production services
- **Network:** Bridged (vmbr0)
- **Installed Software:**
  - Docker Engine
  - Docker Compose
  - Portainer
  - Tailscale (for remote access)

### monitoring-01 (Terraform-managed)
- **OS:** Ubuntu 22.04 LTS (cloud-init)
- **Purpose:** Dedicated monitoring stack - Prometheus, Grafana, Loki
- **Status:** 🚧 In Progress

### cicd-01 (Terraform-managed)
- **OS:** Ubuntu 22.04 LTS (cloud-init)
- **Purpose:** Gitea self-hosted Git + CI/CD runners
- **Status:** 🚧 In Progress

---

## 🏗️ Infrastructure as Code

VMs are provisioned using **Terraform** with the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest) provider (fully compatible with Proxmox 9.x).

### Structure

```
terraform/
└── proxmox/
    ├── modules/
    │   └── vm/              # Reusable VM module
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── environments/
        └── dev/             # Phase 1 infrastructure
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── terraform.tfvars.example
```

### Prerequisites
- Terraform >= 1.0
- Proxmox 9.x with API user configured
- Ubuntu 22.04 cloud-init template (VM ID 9000)

### Deployment

```bash
cd terraform/proxmox/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### Terraform API User Setup

```bash
# Create dedicated Terraform user on Proxmox host
pveum user add terraform@pve --password <password>
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM \
  VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType \
  VM.Config.Memory VM.Config.Network VM.Config.Options VM.Audit \
  VM.PowerMgmt VM.Migrate Datastore.AllocateSpace Datastore.Audit \
  Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use"
pveum aclmod / --user terraform@pve --role TerraformRole
```

### Planned Phases

| Phase | VMs | Status |
|---|---|---|
| Phase 1 | monitoring-01, cicd-01 | ✅ Deployed |
| Phase 2 | k3s-master-01, k3s-worker-01, k3s-worker-02 | ⏳ Pending hardware upgrade |
| Phase 3 | docker-dev-01 | ⏳ Pending hardware upgrade |

---

## 🐳 Container Services

All production services run as Docker containers managed through Portainer on docker-host.

### 📊 Management & Monitoring

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| **Portainer** | 9000 | Docker container management UI | ✅ Running |
| **Homepage** | TBD | Unified dashboard for all services | ✅ Running |
| **Prometheus** | 9090 | Metrics collection and storage | ✅ Running |
| **Grafana** | 3001 | Metrics visualization and dashboards | ✅ Running |
| **Nginx Proxy Manager (NPM)** | 80/443, 81 | Reverse proxy & SSL management | ⚠️ Planned |

### 🎬 Media Stack

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| **Plex** | 32400 | Media server | ✅ Running |
| **Sonarr** | 8989 | TV show automation | ✅ Running |
| **Radarr** | 7878 | Movie automation | ✅ Running |
| **Prowlarr** | 9696 | Indexer management | ✅ Running |
| **Transmission/qBittorrent** | TBD | Download client | TBD |

---

## 💾 Storage Configuration

```
Proxmox Host (prometheus)
├── 1TB SSD - local-lvm (OS & VMs)
│   ├── docker-host (120GB)
│   ├── monitoring-01 (30GB)
│   ├── cicd-01 (30GB)
│   └── ubuntu-cloud-template (VM 9000)
├── 2TB WD Red - ZFS (Backups)
│   └── /mnt/backups
│       ├── Proxmox VM backups
│       └── Docker volume backups
└── 4TB Seagate IronWolf - ZFS (Media & Files)
    └── /mnt/media
        ├── /movies
        ├── /tv
        └── /downloads
```

---

## 🔐 Remote Access

### Tailscale VPN
- Installed on Proxmox host and Docker VM
- Secure remote access without port forwarding
- No public port exposure

---

## 📈 Monitoring Architecture

```
Container Metrics
       ↓
   Prometheus (scrape & store)
       ↓
   Grafana (query & visualize)
       ↓
   Loki (log aggregation) [planned on monitoring-01]
```

---

## 🌐 Network Access Summary

| Service | Access Method | Address |
|---------|---------------|---------|
| Proxmox UI | Direct/Tailscale | https://\<proxmox-ip\>:8006 |
| Docker VM SSH | Tailscale | ssh user@\<vm-tailscale-name\> |
| Portainer | Tailscale | http://\<vm-ip\>:9000 |
| Prometheus | Tailscale | http://\<vm-ip\>:9090 |
| Grafana | Tailscale | http://\<vm-ip\>:3001 |
| Plex | Tailscale/Local | http://\<vm-ip\>:32400/web |
| monitoring-01 | Local | 192.168.50.51 |
| cicd-01 | Local | 192.168.50.52 |

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

### Infrastructure Backups
- **Method:** Terraform state + this GitHub repository
- **Recovery:** Full environment reproducible from `terraform apply`

---

## 🚀 Deployment & Recovery

### Fresh Deployment
1. Install Proxmox VE on bare metal
2. Create Ubuntu cloud-init template (VM ID 9000)
3. Configure Terraform API user and role
4. Run `terraform apply` from `environments/dev`
5. Deploy production services on docker-host via Portainer
6. Configure Tailscale on Proxmox and Docker VM

### Service Recovery
1. Pull latest code from this repo
2. Run `terraform apply` to reprovsion VMs
3. Restore volume data from 2TB backup drive
4. Deploy stacks via Portainer or `docker compose up -d`

---

## 📚 Repository Structure

```
homelab-proxmox-server/
├── README.md
├── terraform/
│   └── proxmox/
│       ├── modules/vm/
│       └── environments/dev/
├── stacks/
│   ├── monitoring/
│   ├── media/
│   ├── management/
│   └── proxy/
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

- **Hardware constraints:** i5-6600K (4 cores/32GB) limits simultaneous VM count
  - *Planned:* Upgrade to i7-9700K (8 cores) for K3s cluster deployment
- **NPM Not Running:** Using Tailscale instead of reverse proxy
  - *Status:* Low priority with current Tailscale setup
- **No Automated Docker Backups:** Manual backup process currently
  - *Planned:* Implement Restic automation

---

## 🎯 Future Improvements

### Short Term
- [ ] Configure monitoring stack on monitoring-01 (Prometheus, Grafana, Loki)
- [ ] Deploy Gitea on cicd-01
- [ ] Build GitHub Actions workflows for automated Terraform plans
- [ ] Add Ansible playbooks for VM configuration management
- [ ] Get NPM running
- [ ] Add automated Docker volume backups (Restic)

### Long Term
- [ ] Deploy K3s cluster (Phase 2) after hardware upgrade
- [ ] Add docker-dev-01 (Phase 3) after hardware upgrade
- [ ] Expand to cloud provider (AWS/Azure) with Terraform modules
- [ ] Set up off-site backup solution

---

## 📖 Additional Resources

- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [bpg/proxmox Terraform Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [TRaSH Guides](https://trash-guides.info/)

---

**Maintained by:** likeshadic  
**Repository:** https://github.com/likeshadic/homelab-proxmox-server
