# Changelog


## [1.9.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.8.0...v1.9.0) - 2023-02-10

### Added
- exit early in case of Docker issues (e.g., unavailable MongoDB version)
- validate GitHub Action typings using [krzema12/github-actions-typing](https://github.com/krzema12/github-actions-typing)

### Updated
- bump dependencies


## [1.8.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.7.0...v1.8.0) - 2022-08-26

### Added
- support MongoDB 6.x. Thanks to [Evandro aka ecarruda](https://github.com/ecarruda)!
- use `mongo` for MongoDB 4.x release line
- use `mongosh` for MongoDB 5.x and 6.x release lines

### Updated
- bump dependencies
- use `@supercharge/eslint-config` instead of `eslint-config-standard`


## [1.7.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.6.0...v1.7.0) - 2021-11-16

### Added
- `mongodb-username` and `mongodb-password` inputs allowing you to configure the authentication credentials for a user created in the `admin` database (with the role of `root`)
- `mongodb-db` input allowing you to create a database that is used for creation scripts

### Updated
- bump dependencies
- use UVU and c8 for testing instead of @hapi/lab


## [1.6.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.5.0...v1.6.0) - 2021-06-01

### Added
- show replica set status after `rs.initiate()`


## [1.5.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.4.1...v1.5.0) - 2021-05-31

### Added
- refined tests for custom ports
- refined custom port handling when using replica sets
- extended output for better debugging in GitHub Actions


## [1.4.1](https://github.com/superchargejs/mongodb-github-action/compare/v1.4.0...v1.4.1) - 2021-05-24

### Updated
- use strings for `mongodb-version` in Readme and GitHub Actions Workflows


## [1.4.1](https://github.com/superchargejs/mongodb-github-action/compare/v1.4.0...v1.4.1) - 2021-05-24

### Added
- `mongodb-port` input allowing to start a MongoDB instance (or single-node replica set) on a custom port


## [1.4.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.3.0...v1.4.0) - 2021-05-11

### Added
- `mongodb-port` input allowing to start a MongoDB instance (or single-node replica set) on a custom port


## [1.3.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.2.0...v1.3.0) - 2020-04-10

### Added
- check if the `mongodb-version` input is present: if not, print a message and fail the job


## [1.2.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.1.0...v1.2.0) - 2020-03-30

### Added
- `mongodb-replica-set` input to define a MongoDB replica set name
- tests connecting to MongoDB instances (single instance, replica set) created by this GitHub Action


## [1.1.0](https://github.com/superchargejs/mongodb-github-action/compare/v1.0.0...v1.1.0) - 2019-12-18

### Updated
- switched from a Node.js workflow to a Docker-based workflow
  - reduces noise in the repo by removing the Node.js dependencies and only relying on a shell script
- green database icon in GitHub Action details


## 1.0.0 - 2019-12-17

### Added
- `1.0.0` release 🚀 🎉
