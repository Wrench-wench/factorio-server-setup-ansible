#!/bin/bash

echo "Starting script"

if [ $UID -eq 0 ]; then

  # Update system package list and install needed packages
  echo "Installing system packages (tar and OpenSSH Server)"
  dnf makecache
  dnf upgrade
  dnf install openssh-server tar curl -y

  # Start the SSH daemon
  echo "Enabling SSH"
  systemctl start sshd
  systemctl enable sshd

  # What's my IP address? (With colour!)
  ip -c address

  # Get the Factorio server files and extract them
  echo "Downloading Factorio server files"
  download=$(curl -Ls -o /opt/factorio.tar.xz -w %{url_effective} https://factorio.com/get-download/stable/headless/linux64)
  tar -xJf /opt/factorio.tar.xz --directory /opt/

  # Add the unprivlidged user that'll run the server
  echo "Adding factorio user"
  useradd factorio
  chown -R factorio:factorio /opt/factorio

  # Switch to the new user and launch the Factorio server
  exec su "factorio" "$0" -- "$@"

  # Nothing will be executed beyond this line,
  # Because exec replaces running process with the new one.
fi

id=$(id -u factorio)

if [ $UID -eq $id ]; then
    echo "Switched to factorio user, starting Factorio server."
    cd /opt/factorio
    mkdir /opt/factorio/saves
    /opt/factorio/bin/x64/factorio --create firsttest
    /opt/factorio/bin/x64/factorio --start-server firsttest
fi