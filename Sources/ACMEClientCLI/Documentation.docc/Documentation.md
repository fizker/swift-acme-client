# acme-client

A command line for managing accounts and certificates.

Following are some of the shared prerequisites that creating certificates need.


## Directory

Most commands need a directory to communicate with. This is given with the `--directory` option.

The directory can either be a URL to the directory of a server, or one of the built-in shorthands:

- `lets-encrypt-production` uses https://acme-v02.api.letsencrypt.org/directory
- `lets-encrypt-staging` uses https://acme-staging-v02.api.letsencrypt.org/directory


## Creating the account key

If a key is not yet created, it can be with
```sh
swift run acme-client account key <path to output>
```

This key will be used with all calls to verify the account.


## Creating an account with the ACME provider

Accounts can be created with

```sh
swift run acme-client account create --directory <directory> --key <path to key> --contact <email>
```
