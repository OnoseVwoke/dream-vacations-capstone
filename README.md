# ? Dream Vacations — DevOps Capstone 2026

![CI](https://github.com/OnoseVwoke/dream-vacations/actions/workflows/ci.yml/badge.svg)
![CD](https://github.com/OnoseVwoke/dream-vacations/actions/workflows/cd.yml/badge.svg)

A production-ready, fully containerized travel destination booking app deployed on AWS with automated CI/CD pipelines, Infrastructure as Code, and HTTPS delivery.

---

## ?? Architecture

## ?? Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18 |
| Backend | Node.js + Express |
| Database | PostgreSQL 15 |
| Containerization | Docker + Docker Compose |
| Reverse Proxy | Nginx + Let'\''s Encrypt SSL |
| CI/CD | GitHub Actions |
| Infrastructure | Terraform (AWS) |
| Cloud | AWS EC2 + VPC + Route 53 |

---

## ?? Local Setup

### Prerequisites
- Docker Desktop
- Git

### Run locally

```bash
# Clone the repo
git clone https://github.com/OnoseVwoke/dream-vacations.git
cd dream-vacations

# Copy environment file
cp .env.example .env

# Start all services
docker compose up --build -d

# Verify
curl http://localhost:5000/api/health
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000/api/health

### Stop the stack
```bash
docker compose down
```

---

## ?? Project Structure

---

## ?? Scripts

### Server Setup (run once on fresh EC2)
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Database Backup
```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

Backups are saved to `/var/backups/dream-vacations/` and logs to `/var/log/dream-vacations/dv-backup.log`. Old backups are rotated after 7 days.

---

## ?? Production Deployment

1. Provision AWS infrastructure with Terraform
2. SSH into EC2 and run `setup.sh`
3. Clone repo and configure `.env`
4. Run `docker compose up -d`
5. Configure Nginx and SSL with Certbot

Live URL: https://34.197.253.100.nip.io

---

## ?? API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | /api/health | Health check |
| GET | /api/destinations | List all destinations |
| POST | /api/destinations | Add a destination |
| DELETE | /api/destinations/:id | Remove a destination |

---

## ?? Environment Variables

See `.env.example` for all required variables.

Never commit `.env` to version control.

---

*© 2026 Dream Vacations · Capstone Project · Junior DevOps Engineer*
