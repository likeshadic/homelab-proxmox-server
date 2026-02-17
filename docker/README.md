# Docker Infrastructure Documentation

## Overview

All Docker services run on a dedicated **docker-host** VM managed through **Portainer**.

| Property | Value |
|----------|-------|
| **VM Name** | docker-host |
| **IP Address** | 192.168.50.42 |
| **OS** | Ubuntu 24.04.3 LTS |
| **CPU** | 4 cores |
| **RAM** | 16GB |
| **Disk** | 120GB (Proxmox local-lvm) |
| **Docker Version** | 29.1.3 |
| **Portainer** | http://192.168.50.42:9000 |

---

## Storage Configuration

### NFS Mounts from Proxmox Host

Media is served via **NFS4** from Proxmox ZFS pools rather than direct disk passthrough.

```
docker-host VM
├── /var/lib/docker/volumes   # Docker volumes (on 120GB VM disk)
└── /mnt/media/
    ├── tv/       → NFS: 192.168.50.157:/media-pool/tv (4TB ZFS)
    └── movies/   → NFS: 192.168.50.157:/media-pool/movies (4TB ZFS)
```

**Proxmox NFS Exports:**
- **Source:** Proxmox host (192.168.50.157)
- **Protocol:** NFSv4.2
- **Storage:** 4TB Seagate IronWolf (ZFS pool)
- **Mount Options:** `rw,hard,proto=tcp` (reliable, persistent mounts)

**Future Addition:**
- `/mnt/backups` → NFS from 2TB WD Red ZFS pool (planned)

### Volume Binds

Stacks use bind mounts to NFS-backed storage:
- **Plex, Sonarr, Radarr** → `/mnt/media/movies`, `/mnt/media/tv`
- **Config/data** → `/var/lib/docker/volumes/[stack]_data`

---

## Active Stacks

| Stack | Services | Purpose | Port(s) | Status |
|-------|----------|---------|---------|--------|
| **arr** | Sonarr, Radarr, Prowlarr | Media automation | 8989, 7878, 9696 | ✅ Production |
| **homepage** | Homepage Dashboard | Service dashboard | 3000 | ✅ Production |
| **monitoring** | Prometheus, Grafana, Node Exporter, cAdvisor | Metrics & visualization | 9090, 3001 | ✅ Production → 🔄 Migrating to monitoring-01 |
| **nginx-proxy-manager** | NPM | Reverse proxy & SSL | 80, 443, 81 | ⚠️ Running but not configured |
| **plex** | Plex Media Server | Media streaming | 32400 | ✅ Production |

---

## Service Access

### Local Network
- **Portainer:** http://192.168.50.42:9000
- **Homepage:** http://192.168.50.42:3000
- **Prometheus:** http://192.168.50.42:9090
- **Grafana:** http://192.168.50.42:3001
- **Plex:** http://192.168.50.42:32400/web
- **Sonarr:** http://192.168.50.42:8989
- **Radarr:** http://192.168.50.42:7878
- **Prowlarr:** http://192.168.50.42:9696
- **NPM Admin:** http://192.168.50.42:81 (not in use)

### Remote Access
- **Method:** Tailscale VPN mesh network
- **No public port forwarding**
- **No SSL/certificates configured** (Tailscale handles encryption)

### NPM Status
Nginx Proxy Manager is running but **not actively used**. Tailscale provides secure remote access without needing a reverse proxy.

---

## Deployment Process

### Stack Management
All stacks are deployed and managed through **Portainer Web UI**.

**Deployment workflow:**
1. Log into Portainer at http://192.168.50.42:9000
2. Navigate to **Stacks**
3. Click **Add Stack** or edit existing
4. Paste/edit `docker-compose.yml` content in web editor
5. Click **Deploy the stack**

### Secrets Management
- **No .env files used**
- **API keys and passwords** managed directly through Portainer's environment variable editor
- Secrets stored in Portainer's database (backed by `portainer_data` volume)

---

## Stack Details

### arr/
Media download automation stack
- **Services:** Sonarr (TV), Radarr (Movies), Prowlarr (Indexers)
- **Storage:** 
  - Downloads: `/mnt/media/downloads` (NFS)
  - TV Library: `/mnt/media/tv` (NFS)
  - Movies Library: `/mnt/media/movies` (NFS)
- **Dependencies:** Download client (Transmission/qBittorrent)

### homepage/
Unified dashboard for all homelab services
- **Port:** 3000
- **Config:** Stored in Docker volume
- **Access:** http://192.168.50.42:3000

### monitoring/
**⚠️ MIGRATION PLANNED** → monitoring-01 VM (192.168.50.51)

Current services running on docker-host:
- **Prometheus** (port 9090) - Metrics collection and storage
- **Grafana** (port 3001) - Visualization dashboards
- **Node Exporter** - System metrics from docker-host
- **cAdvisor** - Container metrics and resource usage

**Why migrating:** Separation of concerns for improved resilience. If docker-host goes down, monitoring should remain independent to track the issue.

**Current Status:** Production on docker-host  
**Target:** monitoring-01 (Phase 2)

### nginx-proxy-manager/
Reverse proxy and SSL certificate management
- **Admin UI:** http://192.168.50.42:81
- **Status:** Running but not configured
- **Reason:** Tailscale VPN handles remote access and encryption, eliminating need for reverse proxy and SSL certificates

**Future consideration:** Could be used for local domain names (e.g., `plex.homelab.local`)

### plex/
Media server for streaming movies and TV shows
- **Port:** 32400
- **Library Paths:**
  - Movies: `/mnt/media/movies` (NFS from Proxmox)
  - TV Shows: `/mnt/media/tv` (NFS from Proxmox)
- **Transcoding:** Software transcoding (CPU-based)
- **Access:** Local network + Tailscale remote access

---

## Backup Strategy

### Current State
- ✅ **Compose files:** Backed up in this GitHub repository
- ✅ **NFS data:** Protected by ZFS on Proxmox host (snapshots possible)
- ⚠️ **Docker volumes:** No automated backup yet

### Planned Improvements
- [ ] Mount 2TB WD Red as `/mnt/backups` via NFS
- [ ] Implement Restic or Duplicati for automated Docker volume backups
- [ ] Schedule daily backups of:
  - Portainer data (`portainer_data` volume)
  - *arr service databases and configurations
  - Grafana dashboards and data sources
  - Homepage configuration
- [ ] Exclude Plex metadata from backups (very large, easily regenerated)

### Disaster Recovery
**Current recovery process:**
1. Rebuild docker-host VM on Proxmox
2. Mount NFS shares from Proxmox (`/mnt/media/tv`, `/mnt/media/movies`)
3. Install Docker and Portainer
4. Clone this GitHub repo
5. Deploy stacks via Portainer using compose files from repo
6. Plex media already intact on NFS (minimal reconfiguration needed)

---

## NFS Mount Configuration

For reference, the NFS mounts are configured in `/etc/fstab` on docker-host:

```bash
192.168.50.157:/media-pool/tv     /mnt/media/tv      nfs4  defaults,_netdev  0  0
192.168.50.157:/media-pool/movies /mnt/media/movies  nfs4  defaults,_netdev  0  0
```

**To verify mounts:**
```bash
mount | grep /mnt
df -h | grep /mnt
```

**To remount after changes:**
```bash
sudo mount -a
```

---

## Common Operations

### View Logs
Via Portainer UI:
- Navigate to **Stacks** → Click stack name → **Logs** button

Or via SSH:
```bash
docker logs <container_name>
docker logs -f <container_name>  # Follow logs in real-time
```

### Restart Stack
Via Portainer:
- **Stacks** → Stack name → **Stop** → **Start**

Or via SSH:
```bash
cd /path/to/stack
docker compose restart
```

### Update Containers
Via Portainer:
- **Stacks** → Stack name → **Pull and redeploy**

Manual update:
```bash
docker compose pull
docker compose up -d
```

### Check Docker Resource Usage
```bash
docker system df        # Disk usage
docker stats            # Real-time container stats
docker ps -a            # All containers
```

---

## Troubleshooting

### Service Not Accessible
1. Check container status: `docker ps` or Portainer UI
2. Verify port bindings: `docker port <container_name>`
3. Test local connectivity: `curl http://localhost:<port>`
4. Check Tailscale status if accessing remotely

### NFS Mount Issues
```bash
# Check if mounts are active
mount | grep /mnt

# Test NFS connectivity
showmount -e 192.168.50.157

# Remount if needed
sudo umount /mnt/media/tv
sudo mount -a

# Check Proxmox NFS exports
# (on Proxmox host)
exportfs -v
```

### Storage Full
```bash
# Check VM disk usage
df -h

# Check Docker disk usage
docker system df

# Clean up unused images/containers
docker system prune -a
```

### Performance Issues
- Monitor in Grafana dashboards at http://192.168.50.42:3001
- Check Proxmox host resources
- Review NFS performance (network bottleneck?)
- Check container resource limits in Portainer

---

## Architecture Notes

### Why NFS Instead of Passthrough?
- ✅ **Flexibility:** Media accessible to multiple VMs if needed
- ✅ **ZFS benefits:** Snapshots, compression, scrubbing on Proxmox side
- ✅ **Easy backup:** Backup ZFS pool on Proxmox host
- ✅ **VM independence:** Recreate docker-host without losing media
- ⚠️ **Tradeoff:** Slight network overhead vs. direct disk access

### Single VM Design
Currently all services run on one VM, which creates a single point of failure.

**Mitigation:**
- Regular backups via Proxmox
- Compose files in GitHub for quick redeployment
- Media on separate NFS storage (survives VM rebuild)

**Future improvement:** Phase 2 will separate monitoring to independent VM

---

## Future Improvements

- [ ] Migrate monitoring stack to monitoring-01 VM (Phase 2)
- [ ] Set up automated Docker volume backups to 2TB NFS share
- [ ] Add Watchtower or Diun for container update notifications
- [ ] Consider configuring NPM for local domain names
- [ ] Implement GitOps workflow (GitHub → Portainer auto-deploy)
- [ ] Add hardware transcoding to Plex (if GPU available)

---

**Last Updated:** February 2026  
**Maintained by:** likeshadic  
**Related:** See `/terraform` directory for VM provisioning infrastructure