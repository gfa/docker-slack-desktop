#!/bin/bash
set -e
set -x

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

SLACK_DESKTOP_USER=slack

install_slack_desktop() {
  echo "Installing slack-desktop-wrapper..."
  install -m 0755 /var/cache/slack-desktop/slack-desktop-wrapper /target/
  echo "Installing slack-desktop..."
  ln -sf slack-desktop-wrapper /target/slack
}

uninstall_slack_desktop() {
  echo "Uninstalling slack-desktop-wrapper..."
  rm -rf /target/slack-desktop-wrapper
  echo "Uninstalling slack-desktop..."
  rm -rf /target/slack
}

create_user() {
  # create group with USER_GID
  if ! getent group ${SLACK_DESKTOP_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${SLACK_DESKTOP_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${SLACK_DESKTOP_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'Slack' ${SLACK_DESKTOP_USER} >/dev/null 2>&1
  fi
  chown ${SLACK_DESKTOP_USER}:${SLACK_DESKTOP_USER} -R /home/${SLACK_DESKTOP_USER}
}

grant_access_to_video_devices() {
  for device in /dev/video*; do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=slackvideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${SLACK_DESKTOP_USER}
      break
    fi
  done
}

launch_slack_desktop() {
  cd /home/${SLACK_DESKTOP_USER}
  exec sudo -HEu ${SLACK_DESKTOP_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
install)
  install_slack_desktop
  ;;
uninstall)
  uninstall_slack_desktop
  ;;
slack)
  create_user
  grant_access_to_video_devices
  echo "$1"
  launch_slack_desktop $@
  ;;
*)
  exec $@
  ;;
esac
