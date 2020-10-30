# Docker files and service

```bash
# docker service
systemctl cat docker.service
systemctl edit docker.service

[Service]
ExecStart=/usr/bin/dockerd -H fd:// --log-level=debug --containerd=/run/containerd/containerd.sock


systemctl status docker.service
systemctl restart docker.service



# docker important directories and files
/var/lib/docker/

/run/containerd/containerd.sock


~/.docker/config.json

{
  "auths": {
    "https://index.docker.io/v1/": {}
  },
  "HttpHeaders": {
    "User-Agent": "Docker-Client/19.03.4 (linux)"
  },
  "psFormat": "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}",
  "imagesFormat": "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}",
  "credsStore": "pass",
  "experimental": "enabled"
}

```
