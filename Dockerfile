FROM jgoerzen/debian-base-security:latest
MAINTAINER gfa01


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -qy curl ca-certificates sudo libxkbfile1

ARG SLACK_URL=https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.0-amd64.deb

# Grab the client .deb
# Install the client .deb
# Cleanup
RUN curl -sSL $SLACK_URL -o /tmp/slack.deb
RUN dpkg -i /tmp/slack.deb || true
RUN apt-get -fy install
RUN rm /tmp/slack.deb \
  && rm -rf /var/lib/apt/lists/*

COPY scripts/ /var/cache/slack-desktop/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
