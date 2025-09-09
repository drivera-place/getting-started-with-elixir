# Setup guide for Elixir environment

To get started with Elixir, you need to have Elixir installed on your machine. The most easy way to install Elixir is by using `asdf` you can download it [here](https://asdf-vm.com/guide/getting-started.html#_1-install-asdf).

The engineering team at OnNodo recommends using `asdf` to manage Elixir versions.

How to install Elixir with `asdf`, using [Homebrew](https://brew.sh/), you need to install homebrew first, you can install `asdf` by running the following command in your terminal:

```bash
brew install asdf
```

`asdf` is a version manager that allows you to easily install and manage multiple versions of Elixir and Erlang.

To install Elixir using `asdf`, you can follow these steps:
1. Install Erlang:

```bash
asdf plugin-add erlang
asdf install erlang 27.0
asdf global erlang 27.0
```

2. Install Elixir:

```bash
asdf plugin-add elixir
asdf install elixir 1.18.4
asdf global elixir 1.18.4
```

Version may change according to the latest stable release.

3. Verify the installation:

```bash
elixir -v
```

Once you have Elixir installed, you can start an interactive shell (IEx) by running the following command in your terminal:

```bash
iex
```
**To exit IEx press `Ctrl + C` twice.**

Or if you already have a Mix project, you can start IEx with the Mix environment loaded by running:

```bash
iex -S mix
```

To start an Elixir new project, you can use the Mix build tool. Create a new project by running:

```bash
mix new my_project
cd my_project
```

Formating files can be done using:

```bash
mix format
```

To run tests, you can use the following command:

```bash
mix test
```