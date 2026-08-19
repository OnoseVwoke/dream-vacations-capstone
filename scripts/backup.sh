#!/bin/bash
set -e
set -o pipefail

echo "============================================"
echo " Dream Vacations - Backup Script"
echo "============================================"

# Config
BACKUP_DIR="/var/backups/dream-vacations"
LOG_FILE="/var/log/dream-vacations/dv-backup.log"
RETENTION_DAYS=7
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"

# Load env vars if .env exists
if [ -f /opt/dream-vacations/.env ]; then
  export $(grep -v '^#' /opt/dream-vacations/.env | xargs)
fi

# Use defaults if not set
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-dream_vacation_db}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-mysecretpassword}

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
  echo -e "${GREEN}${msg}${NC}"
  echo "$msg" >> "$LOG_FILE"
}

error() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
  echo -e "${RED}${msg}${NC}"
  echo "$msg" >> "$LOG_FILE"
  exit 1
}

# Create directories
log "Creating backup and log directories..."
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname $LOG_FILE)"

log "Starting database backup..."
log "Database : $POSTGRES_DB"
log "User     : $POSTGRES_USER"
log "Output   : $BACKUP_FILE"

# Run backup from running container
if docker ps --format '{{.Names}}' | grep -q "dream-vacations-db"; then
  docker exec dream-vacations-db pg_dump \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" | gzip > "$BACKUP_FILE"
  log "Backup completed: $BACKUP_FILE ($(du -sh $BACKUP_FILE | cut -f1))"
else
  error "dream-vacations-db container is not running. Backup aborted."
fi

# Rotate old backups
log "Rotating backups older than ${RETENTION_DAYS} days..."
DELETED=$(find "$BACKUP_DIR" -name "db_backup_*.sql.gz" -mtime +${RETENTION_DAYS} -print -delete | wc -l)
log "Deleted $DELETED old backup(s)"

# Rotate old logs
log "Rotating logs older than ${RETENTION_DAYS} days..."
find "$(dirname $LOG_FILE)" -name "*.log" -mtime +${RETENTION_DAYS} -delete

# List current backups
log "Current backups:"
ls -lh "$BACKUP_DIR" | tee -a "$LOG_FILE"

echo ""
echo "============================================"
echo " Backup Complete: $TIMESTAMP"
echo " File: $BACKUP_FILE"
echo " Log:  $LOG_FILE"
echo "============================================"
