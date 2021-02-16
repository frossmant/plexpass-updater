# plexpass-updater

## Table of contents

- 1.0) [About](#10-about)
    - 1.1) [Features](#11-features)
    - 1.2) [Downloading](#12-downloading)
    - 1.3) [Configure](#13-configure)
    - 1.4) [Usage](#14-usage)
- 2.0) [Licensing](#20-licensing)


## 1.0) About
plexpass-updater is a bash script for updating Plex Media Server with the latest pre-release versions available to plexpass members.

## 1.1) Features
* Download and upgrade PMS to the latest Plex Pass version using Plex token
* Skipping upgrade of PMS if the server has active streaming sessions
* Syslog integration for logging events

## 1.2) Downloading
To download and install just clone this repository using GIT
```
git clone https://github.com/frossmant/plexpass-updater
```
## 1.3) Configure
* Make sure you've got your plex token key, if not check [this guide](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token) on how to get it.

First edit the plexpass-updater.sh script
```
vi plexpass-updater.sh
```
Now replace the value for variable PLEX_TOKEN with your own PLEX token key.

```diff
-      PLEX_TOKEN=EnterMyPlexPassToken
+      PLEX_TOKEN=xxxxxxxxxxxxxxxxxxxx
```
Save and exit out of vi.

## 1.4) Usage

Just run the script localy on your PLEX Media Server as root to upgrade your server.

```
./plexpass-updater.sh
```
By default the script will skip upgrading the server if you have active streaming sessions from your server.

Here are all available arguments/options for this script.
```
OPTIONS:
   force   forcing upgrade even if server has active sessions
```

## 2.0) Licensing

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
