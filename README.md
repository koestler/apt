# koestler apt repository

Signed apt repository: https://apt.koestler.ch

## Install

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://apt.koestler.ch/key.gpg | sudo tee /etc/apt/keyrings/koestler.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/koestler.sources >/dev/null <<EOF
Types: deb
URIs: https://apt.koestler.ch
Suites: stable
Components: main
Signed-By: /etc/apt/keyrings/koestler.gpg
EOF
sudo apt update
```

## Packages

* [go-iotdevice](https://github.com/koestler/go-iotdevice) - Reads parameters from Victron Energy devices, Modbus, GPIO, HTTP and MQTT devices and exposes them via a web interface, a REST api and MQTT.