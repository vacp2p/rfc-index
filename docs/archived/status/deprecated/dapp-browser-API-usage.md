# Dapp browser API usage

| Field | Value |
| --- | --- |
| Name | Dapp browser API usage |
| Slug | 126 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/dapp-browser-API-usage.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/dapp-browser-API-usage.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/dapp-browser-API-usage.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/dapp-browser-API-usage.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/dapp-browser-API-usage.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/dapp-browser-API-usage.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This document describes requirements that an application must fulfill in order to provide a proper environment for Dapps running inside a browser.
A description of the Status Dapp API is provided, along with an overview of bidirectional communication underlying the API implementation.
The document also includes a list of EIPs that this API implements.

## Definitions

| Term       | Description                                                                         |
|------------|-------------------------------------------------------------------------------------|
| **Webview**   | Platform-specific browser core implementation.                                    |
| **Ethereum Provider** | A JS object (`window.ethereum`) injected into each web page opened in the browser providing web3 compatible provider. |
| **Bridge** | A set of facilities allow bidirectional communication between JS code and the application. |

## Overview

The application should expose an Ethereum Provider object (`window.ethereum`) to JS code running inside the browser.
It is important to have the `window.ethereum` object available before the page loads, otherwise Dapps might not work correctly.

Additionally, the browser component should also provide bidirectional communication between JS code and the application.

## Usage in Dapps

Dapps can use the below properties and methods of `window.ethereum` object.

### Properties

#### `isStatus`

Returns true. Can be used by the Dapp to find out whether it's running inside Status.

#### `status`

Returns a `StatusAPI` object. For now it supports one method: `getContactCode` that sends a `contact-code` request to Status.

### Methods

#### `isConnected`

Similarly to Ethereum JS API [docs](https://github.com/ethereum/wiki/wiki/JavaScript-API#web3isconnected),
it should be called to check if connection to a node exists. On Status, this fn always returns true, as once Status is up and running, node is automatically started.

#### `scanQRCode`

Sends a `qr-code` Status API request.

#### `request`

`request` method as defined by EIP-1193.

### Unused

Below are some legacy methods that some Dapps might still use.

#### `enable` (DEPRECATED)

Sends a `web3` Status API request. It returns a first entry in the list of available accounts.

Legacy `enable` method as defined by [EIP1102](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1102.md).

#### `send` (DEPRECATED)

Legacy `send` method as defined by [EIP1193](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md).

#### `sendAsync` (DEPRECATED)

Legacy `sendAsync` method as defined by [EIP1193](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md).

#### `sendSync` (DEPRECATED)

Legacy `send` method.

## Implementation

Status uses a [forked version](https://github.com/status-im/react-native-webview) of [react-native-webview](https://github.com/react-native-community/react-native-webview)  to display web or dapps content.
The fork provides an Android implementation of JS injection before page load.
It is required in order to properly inject Ethereum Provider object.

Status injects two JS scripts:

- [provider.js](https://github.com/status-im/status-mobile/blob/develop/resources/js/provider.js): `window.ethereum` object
- [webview.js](https://github.com/status-im/status-mobile/blob/develop/resources/js/webview.js): override for `history.pushState` used internally

Dapps running inside a browser communicate with Status Ethereum node by means of a *bridge* provided by react-native-webview library.
The bridge allows for bidirectional communication between browser and Status. In order to do so, it injects a special `ReactNativeWebview` object into each page it loads.

On Status (React Native) end, `react-native-webview` library provides `WebView.injectJavascript` function
on a webview component that allows to execute arbitrary code inside the webview.
Thus it is possible to inject a function call passing Status node response back to the Dapp.

Below is the table briefly describing what functions/properties are used. More details available in package [docs](https://github.com/react-native-community/react-native-webview/blob/master/docs/Guide.md#communicating-between-js-and-native).

| Direction | Side | Method |
|-----------|------|-----------|
| Browser->Status | JS | `ReactNativeWebView.postMessage()`|
| Browser->Status | RN | `WebView.onMessage()`|
| Status->Browser | JS | `ReactNativeWebView.onMessage()`|
| Status->Browser | RN | `WebView.injectJavascript()`|

## Compatibility

Status browser supports the following EIPs:

- [EIP1102](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1102.md): `eth_requestAccounts` support
- [EIP1193](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md): `connect`, `disconnect`, `chainChanged`, and `accountsChanged` event support is not implemented

## Changelog

| Version | Comment |
| :-----: | ------- |
| 0.1.0 | Initial Release |

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [Ethereum JS API docs](https://github.com/ethereum/wiki/wiki/JavaScript-API#web3isconnected)
- [EIP1102](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1102.md)
- [EIP1193](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md)
- [forked version](https://github.com/status-im/react-native-webview)
- [react-native-webview](https://github.com/react-native-community/react-native-webview)
- [provider.js](https://github.com/status-im/status-mobile/blob/develop/resources/js/provider.js)
- [webview.js](https://github.com/status-im/status-mobile/blob/develop/resources/js/webview.js)
- [docs](https://github.com/react-native-community/react-native-webview/blob/master/docs/Guide.md#communicating-between-js-and-native)
