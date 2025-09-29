# AFFiNE - YunoHost Package

## Description

AFFiNE is an open-source self-hostable workspace that combines collaborative documentation, whiteboard, and project management. This YunoHost package allows you to easily install AFFiNE on your YunoHost server with complete automatic configuration.

## Features

### 🎯 Main features
- **Collaborative documentation** : Rich document editor with Markdown support
- **Whiteboard** : Interactive whiteboard for visual collaboration
- **Project management** : Planning and organization tools
- **Knowledge base** : Structured storage system for knowledge

### 🔧 Technical features
- ✅ **100% FOSS** : No proprietary dependencies
- 🔒 **Privacy** : No tracking, local data
- ⚡ **Efficiency** : Optimized for low-consumption servers
- 🏗️ **Multi-architecture** : ARM64 and AMD64 support
- 🔄 **Multi-instance** : Multiple instances on the same server
- 🔐 **SSOwat** : Integration with YunoHost authentication
- 🌐 **IPv6** : Native IPv6 support
- 🔄 **Backup/Restore** : Complete data backup
- 🚀 **Performance** : Optimized NGINX reverse proxy

## Prerequisites

### System
- **YunoHost** : 4.3.0 or newer
- **Architecture** : ARM64 or AMD64
- **RAM** : 512MB minimum (1GB recommended)
- **Storage** : 2GB minimum

### Services
- **PostgreSQL** : 13.0 or newer
- **NGINX** : 1.18.0 or newer
- **Redis** : 6.0.0 or newer
- **Node.js** : 18.0.0 or newer (LTS)

## Installation

### Via YunoHost interface

1. Log in to YunoHost administration interface
2. Go to "Applications" > "Install"
3. Search for "AFFiNE" or "affine"
4. Click "Install"
5. Configure settings:
   - **Domain** : Select your domain
   - **Path** : `/affine` (default)
   - **Public access** : `false` (recommended)
6. Click "Install"

### Via command line

```bash
# Install from YunoHost catalog
yunohost app install affine

# Install with custom parameters
yunohost app install affine \
  --domain example.com \
  --path /affine \
  --is_public false
```

### Multi-instance installation

```bash
# Install a second instance
yunohost app install affine \
  --domain example.com \
  --path /affine2 \
  --is_public false

# Each instance will have its own port and database
```

## Configuration

### Automatic configuration

The application configures automatically during installation:
- PostgreSQL database created
- Dedicated system user
- NGINX configuration with SSL
- Systemd service configured
- SSOwat integration

### Manual configuration

Configuration is located in `/var/www/affine_<instance>/config/config.json` :

```json
{
  "database": {
    "url": "postgresql://affine_<instance>:password@localhost:5432/affine_<instance>"
  },
  "redis": {
    "url": "redis://localhost:6379/<instance_id>"
  },
  "server": {
    "port": 3000,
    "host": "127.0.0.1"
  },
  "security": {
    "secret": "your-secret-key"
  },
  "storage": {
    "path": "/var/www/affine_<instance>/data"
  }
}
```

### NGINX configuration

The package automatically configures NGINX with:
- Reverse proxy to application
- IPv6 support
- Security headers
- WebSocket support
- Gzip compression

### SSOwat configuration

SSOwat integration is automatic:
- Authentication via YunoHost
- Permission management
- Single session

## Usage

### Access to application

1. Open your browser
2. Go to `https://your-domain.com/affine`
3. Log in with your YunoHost account
4. Start using AFFiNE !

### User management

Users are managed via YunoHost interface:
- Each YunoHost user can access the application
- Permissions managed via SSOwat
- No separate user management

### AFFiNE features

- **Document creation** : Rich editor with Markdown
- **Whiteboard** : Drawing and visual collaboration
- **Project management** : Kanban, calendar, tasks
- **Knowledge base** : Information organization
- **Collaboration** : Sharing and team work

## Upgrade

### Automatic update

```bash
# Update via YunoHost interface
# Or via command line
yunohost app upgrade affine
```

### Manual update

1. Stop application : `yunohost app stop affine`
2. Backup data : `yunohost app backup affine`
3. Update : `yunohost app upgrade affine`
4. Restart : `yunohost app start affine`

### Verification after update

```bash
# Check status
systemctl status affine

# Test access
curl -I https://your-domain.com/affine/health
```

## Backup/Restore

### Automatic backup

Backups are automatic and include:
- PostgreSQL database
- Data files
- Configuration
- Logs

### Manual backup

```bash
# Create backup
yunohost app backup affine

# List backups
yunohost app backup list affine

# Restore backup
yunohost app restore affine backup_name
```

### Restoration

1. Stop application : `yunohost app stop affine`
2. Restore : `yunohost app restore affine backup_name`
3. Restart : `yunohost app start affine`

## Remove

### Uninstallation

```bash
# Uninstall via YunoHost interface
# Or via command line
yunohost app remove affine
```

### Uninstallation verification

Uninstallation removes:
- Application and data
- PostgreSQL database
- System user
- NGINX configuration
- Systemd service
- SSOwat configuration

## Limitations

### Technical limitations
- **RAM** : 512MB minimum (1GB recommended)
- **Storage** : 2GB minimum
- **Concurrent users** : Depends on available RAM
- **File size** : Limited by disk space

### Functional limitations
- **Multi-instance** : Maximum 10 instances per server
- **Backup** : Backups limited by disk space
- **Performance** : Depends on server configuration

## Troubleshooting

### Common issues

#### Service won't start
```bash
# Check logs
journalctl -u affine -f

# Check configuration
systemctl status affine

# Restart
systemctl restart affine
```

#### Database error
```bash
# Check PostgreSQL
systemctl status postgresql

# Check connection
sudo -u postgres psql -l | grep affine
```

#### NGINX error
```bash
# Check configuration
nginx -t

# Check logs
tail -f /var/log/nginx/error.log

# Restart NGINX
systemctl restart nginx
```

#### WebSocket issue
- Check NGINX configuration
- Check security headers
- Check application configuration

#### Security headers issue
- Check NGINX configuration
- Check application parameters
- Check permissions

### Logs

```bash
# Application logs
tail -f /var/log/affine/app.log

# Service logs
journalctl -u affine -f

# NGINX logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Status verification

```bash
# Service status
systemctl status affine

# Connectivity test
curl -I https://your-domain.com/affine/health

# Check ports
netstat -tlnp | grep :3000
```

## Multi-instance

### Multiple instance installation

```bash
# Instance 1 (default)
yunohost app install affine --domain example.com --path /affine

# Instance 2
yunohost app install affine --domain example.com --path /affine2

# Instance 3
yunohost app install affine --domain example.com --path /affine3
```

### Instance management

Each instance is independent:
- Different automatic port
- Separate database
- Different system user
- Isolated configuration

### Multi-instance limitations

- Maximum 10 instances per server
- Each instance consumes ~512MB RAM
- Automatic ports (3000, 3001, 3002, ...)

## Security

### Application security
- Authentication via YunoHost/SSOwat
- Data encryption in transit (HTTPS)
- HTTP security headers
- User isolation

### System security
- Dedicated system user
- Restrictive permissions
- No root privileges
- Security logs

### Security headers
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `Referrer-Policy: strict-origin-when-cross-origin`
- Content Security Policy (CSP)

## Support

### Documentation
- **AFFiNE** : [docs.affine.pro](https://docs.affine.pro)
- **YunoHost** : [yunohost.org](https://yunohost.org)

### Community
- **YunoHost Forum** : [forum.yunohost.org](https://forum.yunohost.org)
- **GitHub** : [github.com/toeverything/AFFiNE](https://github.com/toeverything/AFFiNE)

### Issues
- **Package** : [github.com/username/affine_ynh/issues](https://github.com/username/affine_ynh/issues)
- **AFFiNE** : [github.com/toeverything/AFFiNE/issues](https://github.com/toeverything/AFFiNE/issues)

---

**Developed with ❤️ for the YunoHost community**
