# Home Automation

My home automation system, running on a Raspberry Pi 4.

## Upgrade

Upgrade the whole environment:

```sh
make install ENV=live
```

Upgrade a specific component (e.g. the Dashboard):

```sh
make install ENV=live TAGS=dashboard
```

## Architecture

                                                  +-----------+
                                                  |  Grafana  |
        +------------------------------+          +-----------+
        |                              |                ^
        V                              |                |
+-----------+    +-------------+   +---------+    +----------+
| mosquitto |<---| zigbee2mqtt |   | nodered |<---| Telegraf |
+-----------+    +-------------+   +---------+    +----------+
      ^                      ^        ^
      |                      |        |
      |                      |        |
+------------+              +-----------+
| homebridge |<-------------| dashboard |
+------------+              +-----------+
      |
      V
+------------+
|   HomeKit  |
+------------+