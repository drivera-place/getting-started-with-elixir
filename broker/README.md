# Broker IoT

**This the Broker IoT Server implementation**

This project uses GenServer to handle the state of connected devices and their messages.

## Architecture

The Application starts a supervision tree with the following supervisors and workers:

```
OnNodoBroker.Application
└── Broker.TCPAcceptor.Supervisor (Supervisor GenServer)
    └── Broker.TCPAcceptor (GenServer)
        └── Broker.TCPConnection (GenServer)
    └── Broker.UDPAcceptor (GenServer)
        └── Broker.UDPConnection (GenServer)
```
- `OnNodoBroker.Application`: The main application module that starts the supervision tree.
- `Broker.TCPAcceptor.Supervisor`: A supervisor that manages TCP acceptor processes.
- `Broker.TCPAcceptor`: A GenServer that listens for incoming TCP connections and spawns `Broker.TCPConnection` processes for each connection.
- `Broker.TCPConnection`: A GenServer that handles communication with a connected TCP client.
- `Broker.UDPAcceptor`: A GenServer that listens for incoming UDP messages and spawns `Broker.UDPConnection` processes for each message.
- `Broker.UDPConnection`: A GenServer that handles communication with a UDP client.

Each TCP/UDP Acceptor listens on a specified port (e.g.: 4000) and spawns a new connection process for each incoming connection/message. The `Broker.XXXConnection` processes handle the actual communication with the clients, is important to mention that different devices and protocols may be chatty, for instance the vendor Teltonika Codec8 for TCP requires first receive the IME message from the client and then server should response with accept/deny before receive the next reporting messages.

The current architecture would allow to configure and deploy different acceptors for different ports and transport protocols, those modules should be loaded as **options pattern** in some kind of IoC. The same applies for the connection modules, and the specific vendor AVL protocol implementations, different devices may require different handling of the messages.



## Execution

```bash
mix run --no-halt
```
To stop the server, use `Ctrl + C` twice.

## Testing

```bash
mix test
```
## Documentation

```bash
mix docs
```
