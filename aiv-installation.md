# AIV Installation Guide
## Os support (tested)
- Debian 11, 12
- Ubuntu 20*, 22*, 24*
- RHEL 8, 9
- CentOS 7, 8, 9
- Fedora 36+
- macOS 13+ (Intel and Apple Silicon)

## Installation steps
**For Debian/Ubuntu:**
- Install dependencies
openjdk >= 17
```
apt-get update

apt-get install -y \
    openjdk-17-jdk-headless \
    ca-certificates

```

**For RedHat/CentOS/Fedora:**
- Install dependencies
openjdk >= 17

```
dnf install -y java-17-openjdk-headless ca-certificates
```

**For macOS:**
- Install dependencies (Java 17+) via [Homebrew](https://brew.sh)
```bash
brew install openjdk@17

# Link so `java` and `java_home` can find it
sudo ln -sfn "$(brew --prefix openjdk@17)/libexec/openjdk.jdk" \
  /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

- Download the package from GitHub release

https://github.com/aiv-code/docker-aiv/releases

- Install package

**For Debian/Ubuntu:**
```
dpkg -i aiv_<version>_all.deb
```

**For RedHat/CentOS/Fedora:**
```
rpm -i aiv_<version>_all.rpm
```

**For macOS:**
```bash
sudo installer -pkg aiv-<version>-<release>.pkg -target /
```
> The package is unsigned. On first install, right-click (or Control-click) the `.pkg`
> and choose "Open", or allow it via System Settings > Privacy & Security.

## Configure the service
### PostgreSQL

#### Install PostgreSQL

**For Debian/Ubuntu:**
```bash
apt-get update
apt-get install -y postgresql postgresql-contrib

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql


```

**For RedHat/CentOS/Fedora:**
```bash
# Install PostgreSQL
dnf install -y postgresql postgresql-server postgresql-contrib

# Initialize the database
sudo postgresql-setup --initdb

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

```

**For macOS:**
```bash
brew install postgresql

# Start and enable PostgreSQL service (survives reboot/login via launchd)
brew services start postgresql
```

#### Configure PostgreSQL for AIV

Once PostgreSQL is installed and running, create a credential and database for AIV.

```
psql -U postgres

CREATE USER aiv WITH PASSWORD 'aiv_password';
CREATE DATABASE aiv OWNER aiv;
GRANT ALL PRIVILEGES ON DATABASE aiv TO aiv;

```

- Update the postgresql connection at the configuration file:
  - **Debian/Ubuntu/RedHat/CentOS/Fedora:** `/var/lib/aiv/repository/econfig/application.yml`
  - **macOS:** `/usr/local/lib/aiv/repository/econfig/application.yml`

```
spring:
  autoconfigure:
    exclude: org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration
  datasource:
    url: jdbc:postgresql://localhost:5432/aiv # database for aiv schema
    username: aiv
    password: aiv_password
    driverClassName: org.postgresql.Driver
  datasource1:
    url: jdbc:postgresql://localhost:5432/aiv?currentSchema=security # database for security schema
    username: aiv
    password: aiv_password
    driverClassName: org.postgresql.Driver

```

- Enable the service

**For Debian/Ubuntu/RedHat/CentOS/Fedora:**
```
systemctl enable --now aiv.service
```

**For macOS:**
The `com.aivhub.aiv` launchd service is bootstrapped automatically by the installer,
so no extra step is needed.

## Start the service

**For Debian/Ubuntu/RedHat/CentOS/Fedora:**
```
systemctl start aiv
```

**For macOS:**
```bash
sudo launchctl kickstart -k system/com.aivhub.aiv
```

## How to upgrade
- Download the new package from GitHub release

https://github.com/aiv-code/docker-aiv/releases

- Stop the service

**For Debian/Ubuntu/RedHat/CentOS/Fedora:**
```
systemctl stop aiv
```

**For macOS:**
```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.aivhub.aiv.plist
```

- Install the new package

**For Debian/Ubuntu:**
```
dpkg -i aiv_<version>_all.deb
```

**For RedHat/CentOS/Fedora:**
```
rpm -U aiv_<version>_all.rpm
```

**For macOS:**
```bash
sudo installer -pkg aiv-<version>-<release>.pkg -target /
```
This reinstalls the launchd service and starts it automatically — no separate restart step is needed.

- Restart the service

**For Debian/Ubuntu/RedHat/CentOS/Fedora:**
```
systemctl start aiv
```

## Uninstall (macOS)

```bash
sudo /usr/local/bin/aiv-uninstall.sh
```

This stops the `com.aivhub.aiv` launchd service and removes the installed files, service
account, and package receipt.

## Build the macOS package from source

The `.pkg` installer is built and published automatically by the
[`macos-release.yml`](../packages/.github/workflows/macos-release.yml) GitHub Actions
workflow, the same way [`deb-release.yml`](../packages/.github/workflows/deb-release.yml)
builds the `.deb`. It runs on pushes to `main`/`macos` (and on the same
`docker-aiv-release` repository dispatch as the Debian build), extracts `aiv.jar` from the
published Docker image, packages it with `aiv-build-macos.sh`, and publishes the `.pkg` as
a GitHub release asset alongside the `.deb`/`.rpm` packages.
