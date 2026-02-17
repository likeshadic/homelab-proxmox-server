# Monitoring Stack

Current deployment on docker-host (192.168.50.42).

## Services
- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (system metrics)
- cAdvisor (container metrics)

## Migration Plan
This stack will be migrated to dedicated monitoring-01 VM (192.168.50.51) 
as part of Phase 2 infrastructure improvements to separate concerns and 
improve resilience.

**Status:** Production on docker-host | Target: monitoring-01 (planned)