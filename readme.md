# swift-acme-client

An ACME client written in Swift.

It exposes both a CLI as well as API for integrating cert management directly
into web servers.

## How to use

1. Add the package to the list of dependencies in your Package.swift file.
    ```swift
    .package(url: "https://github.com/fizker/swift-acme-client.git", from: "0.2.0")
    ```
2. Add the product to the dependencies of the targets:
    ```swift
    .product(name: "ACMEClient", package: "swift-acme-client")
    ```
3. Add `import ACMEClient` in the file.

The data models used are also exposed in a separate package:

```swift
.product(name: "ACMEClientModels", package: "swift-acme-client")
```

Then `import ACMEClientModels` allows the models to be used.
