# mqttbroker - A broker for messages on MQTT

## Installation

### Installation using Docker

```
docker run -it --rm --name mqttbroker -v mqttbroker.conf:/etc/mqttbroker.conf docker.io/gbeine/mqttbroker
```

### Installation using Podman

```
podman run -it --rm --name mqttbroker -v mqttbroker.conf:/etc/mqttbroker.conf docker.io/gbeine/mqttbroker
```

### Native installation with Python venv

The installation requires at least Python 3.9.

Philosophy is to install it under /usr/local/lib/mqttbroker and control it via systemd.

```
cd /usr/local/lib
git clone https://github.com/gbeine/mqttbroker.git
cd mqttbroker
./install
```

The `install` script creates a virtual python environment using the `venv` module.
All required libraries are installed automatically.
Depending on your system this may take some time.

## Configuration

The configuration is located in `/etc/mqttbroker.conf`.

Each configuration option is also available as command line argument.

- copy `mqttbroker.conf.example`
- configure as you like

| option               | default                 | arguments                  | comment                                                                                |
|----------------------|-------------------------|----------------------------|----------------------------------------------------------------------------------------|
| `mqtt_host`          | 'localhost'             | `-m`, `--mqtt_host`        | The hostname of the MQTT server.                                                       |
| `mqtt_port`          | 1883                    | `--mqtt_port`              | The port of the MQTT server.                                                           |
| `mqtt_keepalive`     | 30                      | `--mqtt_keepalive`         | The keep alive interval for the MQTT server connection in seconds.                     |
| `mqtt_clientid`      | 'airrohr2mqtt'          | `--mqtt_clientid`          | The clientid to send to the MQTT server.                                               |
| `mqtt_user`          | -                       | `-u`, `--mqtt_user`        | The username for the MQTT server connection.                                           |
| `mqtt_password`      | -                       | `-p`, `--mqtt_password`    | The password for the MQTT server connection.                                           |
| `mqtt_topic`         | 'airrohr'               | `-t`, `--mqtt_topic`       | The topic to publish MQTT message.                                                     |
| `mqtt_tls`           | -                       | `--mqtt_tls`               | Use SSL/TLS encryption for MQTT connection.                                            |
| `mqtt_tls_version`   | 'TLSv1.2'               | `--mqtt_tls_version`       | The TLS version to use for MQTT. One of TLSv1, TLSv1.1, TLSv1.2.                       |
| `mqtt_verify_mode`   | 'CERT_REQUIRED'         | `--mqtt_verify_mode`       | The SSL certificate verification mode. One of CERT_NONE, CERT_OPTIONAL, CERT_REQUIRED. |
| `mqtt_ssl_ca_path`   | -                       | `--mqtt_ssl_ca_path`       | The SSL certificate authority file to verify the MQTT server.                          |
| `mqtt_tls_no_verify` | -                       | `--mqtt_tls_no_verify`     | Do not verify SSL/TLS constraints like hostname.                                       |
| `verbose`            | -                       | `-v`, `--verbose`          | Be verbose while running.                                                              |
| -                    | '/etc/mqttbroker.conf'  | `-c`, `--config`           | The path to the config file.                                                           |
| `topics`             | see below               | -                          | The configuration for the topics handling.                                             |

## Topics handling

### Forwarding topics

The most easy case - just forward one topic on another

```
{
    "topic": "target/topic/1",
    "sources": [
      "source/topic/1"
    ]
}
```

There can be many sources, the last one wins

```
{
    "topic": "target/topic/1",
    "sources": [
      "source/topic/1",
      "source/topic/2"
    ]
}
```

Connect topics bidirectional

```
{
    "topic": "target/topic/1"
    "sources": [
      "source/topic/1"
    ],
},
{
    "topic": "source/topic/1"
    "sources": [
      "target/topic/1"
    ],
}
```

### Dealing with data types

`type` can be one of `str`, `int`, `float`, `bool` ('true' or 'false' in lower cases), and `bool_int` ('1' or '0').
`bool` accepts 'true', '1', 'on', 'yes' as values for `true`.

For all data types it is possible to set an initial value using `init`.
This is helpful if values should be combined and there is no SLA when partial values will be published on MQTT. 

```
{
    "topic": "target/topic/str_example",
    "sources": [
      "source/topic/str_example"
    ],
    "type": "str"
},
{
    "topic": "target/topic/int_example",
    "sources": [
      "source/topic/int_example"
    ],
    "type": "int"
},
{
    "topic": "target/topic/float_example",
    "sources": [
      "source/topic/float_example"
    ],
    "type": "float"
},
{
    "topic": "target/topic/bool_example",
    "sources": [
      "source/topic/bool_example"
    ],
    "type": "bool"
},
{
    "topic": "target/topic/bool_int_example",
    "sources": [
      "source/topic/bool_int_example"
    ],
    "type": "bool_int"
},
{
    "topic": "target/topic/bool_example",
    "sources": [
      "source/topic/bool_example"
    ],
    "type": "bool",
    "init": "false"
},
{
    "topic": "target/topic/bool_int_example",
    "sources": [
      "source/topic/bool_int_example"
    ],
    "type": "bool_int",
    "init": 1
}
```

### Math on MQTT

`int` and `float` can be modified by a factor (multiply) and rounded to a specific number of digits.
The factor is always applied before rounding. 

```
{
    "topic": "target/topic/rounded_by_2",
    "sources": [
      "source/topic/1"
    ],
    "type": "float",
    "round": 2
},
{
    "topic": "target/topic/multiplied_by_10",
    "sources": [
      "source/topic/1"
    ],
    "type": "int",
    "factor": 10
},
{
    "topic": "target/topic/multiplied_by_0_01_rounded_by_2",
    "sources": [
      "source/topic/1"
    ],
    "type": "float",
    "factor": 0.01,
    "round": 2
}
```

Numeric values can be added and the min and max values can be determined.
Of course, `factor` and `round` can be applied to the results.

```
{
    "topic": "target/topic/1_plus_2",
    "sources": [
      "source/topic/1",
      "source/topic/2"
    ],
    "handle": "add",
    "type": "float"
},
{
    "topic": "target/topic/minimum",
    "sources": [
      "source/topic/1",
      "source/topic/2",
      "source/topic/3"
    ],
    "handle": "min",
    "type": "int",
    "factor": 10
},
{
    "topic": "target/topic/maximum",
    "sources": [
      "source/topic/1",
      "source/topic/2",
      "source/topic/3"
    ],
    "handle": "max",
    "type": "float",
    "round": 2
}
```

### Combining topics

Multiple topics can be combined to a string.
If a certain length is required, the missing values can be appended.

```
{
    "topic": "target/topic/combined",
    "sources": [
      "source/topic/1",
      "source/topic/2"
    ],
    "handle": "combine"
},
{
    "topic": "target/topic/combined_append",
    "sources": [
      "source/topic/1",
      "source/topic/2",
      "source/topic/3"
    ],
    "handle": "combine",
    "append": [0, "test", 0, 0, 0, 0, 10]
}
```


### Splitting topics

And topics containing multiple values can be splitted, of course.
The split is based on spaces in the payload string.
The selection uses array counting, so the first value has index 0, the second value has index 1, and so on.

```
{
    "topic": "target/topic/selected_1",
    "sources": [
      "source/topic/1"
    ],
    "handle": "split",
    "select": 0,
    "type": int
},
{
    "topic": "target/topic/selected_2",
    "sources": [
      "source/topic/1"
    ],
    "handle": "split"
    "select": 2,
    "type": float,
    "factor": 0.1,
    "round": 1
}
```

### Querying JSON

JSON payload can be parsed using [RFC9535 JSONPath](https://datatracker.ietf.org/doc/html/rfc9535) syntax.

Currently, only pointers to distinct values are supported for querying, see [JSON Pointers](https://jg-rp.github.io/python-jsonpath/pointers/) in [python-jsonpath](https://jg-rp.github.io/python-jsonpath/) documentation. 

```
{
    "topic": "target/topic/query/result",
    "sources": [
      "source/topic/json"
    ],
    "handle": "json",
    "query": "/path/to/key"
},
{
    "topic": "target/topic/query/result",
    "sources": [
      "source/topic/json"
    ],
    "handle": "first",
    "query": "/array/0/element/number"
}
```

### Mapping values

Map incoming payloads using equals-based rules. First matching rule wins.

- `map`: list of rules: `{ "from": <value>, "to": <value> }`.

Example (string normalization via explicit rules):

```
{
    "topic": "target/topic/mapping/result",
    "sources": [
      "source/topic/1"
    ],
    "handle": "map",
    "type": "str",
    "map": [
      {"from": "Comfort", "to": "comfort"},
      {"from": "Standby", "to": "home"},
      {"from": "Night", "to": "sleep"},
      {"from": "Frost Protection", "to": "away"}
    ]
}
```

Boolean mapping examples (DPT 1.001 Switch):

- HA → KNX command mapping (ON/OFF to 0/1):

```
{
    "topic": "bus/knx/5/3/65",
    "sources": [
      "homeassistant/whatever/command"
    ],
    "handle": "map",
    "map": [
      {"from": "OFF", "to": "0"},
      {"from": "ON",  "to": "1"}
    ]
}
```

- KNX → HA state mapping (0/1 to ON/OFF):

```
{
    "topic": "home/dachgeschoss/buero_andre/switch/steckdose_2/state",
    "sources": [
      "bus/knx/6/3/65"
    ],
    "handle": "map",
    "map": [
      {"from": "0", "to": "OFF"},
      {"from": "1",  "to": "ON"}
    ]
}
```

## Running mqttbroker

I use [systemd](https://systemd.io/) to manage my local services.

## Support

I have not the time (yet) to provide professional support for this project.
But feel free to submit issues and PRs, I'll check for it and honor your contributions.

## License

The whole project is licensed under BSD-3-Clause license. Stay fair.
