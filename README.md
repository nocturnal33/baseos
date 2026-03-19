# Base OS
Currently based on Ubuntu 24.04 Noble

- Full XFCE Environment
- Username: operator

This container has sudo access

To run:
```bash
docker pull np003/baseos:noble
docker run -d -p 6901:6901 --rm --name base baseos
```

~/workspce is intened to be persistent.
```bash
mkdir DATA
docker run -d -p 6901:6901 -v $(pwd)/DATA:~/workspace --name base baseos
```

Open a web browser and go to 
http://localhost:6901

You can also clone this repo and build the docker
```bash
docker build -t baseos .
docker run -d -p 6901:6901 <any other options> baseos
```

