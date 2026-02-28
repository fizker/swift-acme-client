# Validating via HTTP

The acme-client app supports validation via HTTP.


## Running the command

The command for validating via HTTP is

```
swift run acme-client order create --method http <options> <domain> [<additional domains>...]
```

The following options are required:

- `--directory`: The directory to use.
- `--account-key`: A path to the private key.
- `--output`: A path that the resulting certificates should be written to.

Optionally, an URL to the account can be given with `--account-url`. If this is omitted,
it will be fetched from the server.


## Validating challenges

While running, the app will output some challenges issued by the ACME provider.

These need to be hosted on a web-server running on the domains that is being validated.

These challenges must be served with the content-type `application/octet-stream`.

While any web-server can do this, one such server specializing in this can be
found at [https://github.com/fizker/http-validation-server](https://github.com/fizker/http-validation-server).
