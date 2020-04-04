This project is fully inspired of [mdouchement](https://github.com/mdouchement) [zoom.us](https://github.com/gfa01/slack-desktop)'s containerization.

# gfa/docker-slack-desktop

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image with [Slack](http://www.slack.com) for Linux with support for audio/video calls.

The image uses [X11](http://www.x.org) and [Pulseaudio](http://www.freedesktop.org/wiki/Software/PulseAudio/) unix domain sockets on the host to enable audio/video support in Slack. These components are available out of the box on pretty much any modern linux distribution.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/gfa01/slack-desktop) and is the recommended method of installation.

```bash
docker pull gfa01/slack-desktop:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t gfa01/slack-desktop github.com/gfa/docker-slack-desktop
```

With the image locally available, install the wrapper scripts using:

```bash
docker run -it --rm \
  --volume /usr/local/bin:/target \
  gfa01/slack-desktop:latest install
```

This will install a wrapper script to launch `slack`.

> **Note**
>
> If Slack is installed on the host then the host binary is launched instead of starting a Docker container. To force the launch of Slack in a container use the `slack-desktop-wrapper` script. For example, `slack-desktop-wrapper slack` will launch Slack inside a Docker container regardless of whether it is installed on the host or not.

## How it works

The wrapper scripts volume mount the X11 and pulseaudio sockets in the launcher container. The X11 socket allows for the user interface display on the host, while the pulseaudio socket allows for the audio output to be rendered on the host.

When the image is launched the following directories are mounted as volumes

- `${HOME}/.config/Slack`
- `XDG_DOWNLOAD_DIR` or if it is missing `${HOME}/Downloads`

This makes sure that your profile details are stored on the host and files received via Slack are available on your host in the appropriate download directory.


# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull gfa01/slack-desktop:latest
  ```

  2. Run `install` to make sure the host scripts are updated.

  ```bash
  docker run -it --rm \
    --volume /usr/local/bin:/target \
    gfa01/slack-desktop:latest install
  ```

## Uninstallation

```bash
docker run -it --rm \
  --volume /usr/local/bin:/target \
  gfa01/slack-desktop:latest uninstall
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it slack-desktop bash
```
