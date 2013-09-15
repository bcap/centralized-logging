# Centralized Logging

Puppet classes to setup a centralized logging solution with:

    ┏━━━━━━━━━━┓                          ┏━━━━━━━━━━━━━━━━━━┓
    ┃ server 1 ┠──┐                   ┌──>┃ elastic search 1 ┃<──┐
    ┗━━━━━━━━━━┛  │   ┏━━━━━━━━━━━━┓  │   ┗━━━━━━━━┯━━━━━━━━━┛   │
                  ├──>┃ logstash 1 ┠──┤            │             │
    ┏━━━━━━━━━━┓  │   ┗━━━━━━━━━━━━┛  │   ┏━━━━━━━━┷━━━━━━━━━┓   │  ┏━━━━━━━━┓
    ┃ server 2 ┠──┤                   ├──>┃ elastic search 2 ┃<──┼──┨ kibana ┃
    ┗━━━━━━━━━━┛  │   ┏━━━━━━━━━━━━┓  │   ┗━━━━━━━━┯━━━━━━━━━┛   │  ┗━━━━━━━━┛
                  ├──>┃ logstash N ┠──┤            │             │
    ┏━━━━━━━━━━┓  │   ┗━━━━━━━━━━━━┛  │   ┏━━━━━━━━┷━━━━━━━━━┓   │
    ┃ server N ┠──┘                   └──>┃ elastic search N ┃<──┘
    ┗━━━━━━━━━━┛                          ┗━━━━━━━━━━━━━━━━━━┛

#### server

Any kind of server that holds applications and generates logs. Logs can be sent directly from the application to logstash servers or to the internal syslog and them syslog ships them to logstash

#### logstash

Transform, filter and send normalized logs to the elastic search cluster. Each server can work as a synchronous pipe or as a asynchronous buffer

##### as a pipe

There is one logstash process that is configured to receive and send to the ES cluster in a blocking way. Simpler setup that works for a small amount/throughput of logging

##### as a buffer

There are 2 logstash processes, one receiving and sending to rabbit mq OR redis, and the other one consuming this queue and sending to the ES cluster. Its a more complex setup that can buffer messages without blocking and thus can handle bursts and a larger amount of logging

#### elastic search

Cluster of elastic search nodes that comunicate with each other and are the storage for the log messages. By default each index holds messages for one given day, but as this setup grows by adding more application servers with different roles, each index should be configured to hold messages for one given role for a given day

#### kibana

Web interface that uses the elastic search to generate pretty data visualization. Thats what makes your users happy :)