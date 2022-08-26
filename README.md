<div align="center">
  <a href="https://superchargejs.com">
    <img width="471" style="max-width:100%;" src="https://superchargejs.com/images/supercharge-text.svg" />
  </a>
  <br/>
  <br/>
  <p>
    <h3>MongoDB in GitHub Actions</h3>
  </p>
  <p>
    Start a MongoDB server in your GitHub Actions.
  </p>
  <br/>
  <p>
    <a href="#usage"><strong>Usage</strong></a>
  </p>
  <br/>
  <br/>
  <p>
    <em>Follow <a href="http://twitter.com/marcuspoehls">@marcuspoehls</a> and <a href="http://twitter.com/superchargejs">@superchargejs</a> for updates!</em>
  </p>
</div>

---


## Introduction
This GitHub Action starts a MongoDB server or MongoDB replica set. By default, the MongoDB server is available on the default port `27017`. You can configure a custom port using the `mongodb-port` input. The examples show how to use a custom port.

The MongoDB version must be specified using the `mongodb-version` input. The used version must exist in the published [`mongo` Docker hub tags](https://hub.docker.com/_/mongo?tab=tags). Default value is `latest`, other popular choices are `4.2`, `4.4`, `5.0` or `6.0`.

This is useful when running tests against a MongoDB database.


## Usage
A code example says more than a 1000 words. Here’s an exemplary GitHub Action using a MongoDB server in versions `4.2` and `4.4` to test a Node.js app:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
        mongodb-version: ['4.2', '4.4', '5.0', '6.0']

    steps:
    - name: Git checkout
      uses: actions/checkout@v3

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.8.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}

    - run: npm install

    - run: npm test
      env:
        CI: true
```


### Using a Custom MongoDB Port
You can start the MongoDB instance on a custom port. Use the `mongodb-port: 12345` input to configure port `12345` for MongoDB. Replace `12345` with the port you want to use in your test runs.

The following example starts a MongoDB server on port `42069`:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
        mongodb-version: ['4.2', '4.4', '5.0', '6.0']

    steps:
    - name: Git checkout
      uses: actions/checkout@v3

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.8.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-replica-set: test-rs
        mongodb-port: 42069

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```


### With a Replica Set (MongoDB `--replSet` Flag)
You can run your tests against a MongoDB replica set by adding the `mongodb-replica-set: your-replicate-set-name` input in your action’s workflow. The value for `mongodb-replica-set` defines the name of your replica set. Replace `your-replicate-set-name` with the replica set name you want to use in your tests.

The following example uses the replica set name `test-rs`:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
        mongodb-version: ['4.2', '4.4', '5.0', '6.0']

    steps:
    - name: Git checkout
      uses: actions/checkout@v3

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.8.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-replica-set: test-rs
        mongodb-port: 42069

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```


### With Authentication (MongoDB `--auth` Flag)
Setting the `mongodb-username` and `mongodb-password` inputs. As per the [Dockerhub documentation](https://hub.docker.com/_/mongo), this automatically creates an admin user and enables `--auth` mode.

The following example uses the username `supercharge`, password `secret` and also sets an initial `supercharge` database:

```yaml
name: Run tests with authentication

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
        mongodb-version: ['4.2', '4.4', '5.0', '6.0']

    steps:
    - name: Git checkout
      uses: actions/checkout@v3

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.8.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-username: supercharge
        mongodb-password: secret
        mongodb-db: supercharge

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```

**Caveat:** due to [this issue](https://github.com/docker-library/mongo/issues/211), you **cannot enable user creation AND replica sets** initially. Therefore, if you use this action to setup a replica set, please create your users through a separate script.


## License
MIT © [Supercharge](https://superchargejs.com)

---

> [superchargejs.com](https://superchargejs.com) &nbsp;&middot;&nbsp;
> GitHub [@supercharge](https://github.com/supercharge) &nbsp;&middot;&nbsp;
> Twitter [@superchargejs](https://twitter.com/superchargejs)
