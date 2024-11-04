---
slug: 14
title: 14/Dapp browser API usage
name: Dapp browser API usage
status: draft
description: This document describes requirements that an application must fulfill in order to provide a proper environment for Dapps running inside a browser.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
---

## Abstract

This document describes requirements for applications to support Dapps  
running inside a browser.
It includes a description of the Status Dapp API,
an overview of the bidirectional communication underlying the API,  
and a list of EIPs implemented by this API.

## Definitions

| Term              | Description                                                                               |
|-------------------|-------------------------------------------------------------------------------------------|
| Webview           | Platform-specific browser core implementation.                                            |
| Ethereum Provider | JS object (`window.ethereum`) injected into each web page opened in the browser, providing a web3-compatible provider. |
| Bridge            | Facilities allowing bidirectional communication between JS code and the application.      |

## Overview

The application should expose an Ethereum Provider object (`window.ethereum`)  
to JavaScript running inside the browser.  
The `window.ethereum` object must be available before the page loads,  
as Dapps may not function correctly otherwise.

The browser component should also enable bidirectional communication  
between JavaScript code and the application.

## Usage in Dapps

Dapps can use the following properties and methods of the `window.ethereum` object.

### Properties

- **isStatus**  
  Returns `true`. Indicates if the Dapp is running inside Status.

- **status**
Returns a `StatusAPI` object.
Currently, it supports one method: `getContactCode`,
which sends a contact-code request to Status.

### Methods

- **isConnected**  
Similar to the Ethereum JS API documentation, it checks if a node connection exists.
In Status, this function always returns `true` since the node is automatically started.

- **scanQRCode**  
  Sends a QR code request to the Status API.

- **request**  
  Implements the `request` method as defined by EIP-1193.

### Unused (Legacy)

Below are deprecated methods that some Dapps may still use.

- **enable** *(DEPRECATED)*  
Sends a web3 Status API request
and returns the first account in the list of available accounts.
Follows the legacy `enable` method from EIP-1102.

- **send** *(DEPRECATED)*  
  Legacy `send` method as per EIP-1193.

- **sendAsync** *(DEPRECATED)*  
  Legacy `sendAsync` method as per EIP-1193.

- **sendSync** *(DEPRECATED)*  
  Legacy `send` method.

## Implementation

Status uses a forked version of `react-native-webview` to display web or Dapp content.
This fork provides an Android implementation of JavaScript injection
before the page loads,
which is required to inject the Ethereum Provider object correctly.

Status injects two JavaScript scripts:

1. **provider.js**: Injects the `window.ethereum` object.
2. **webview.js**: Overrides `history.pushState` for internal use.

Dapps in the browser communicate with the Status Ethereum node  
via a bridge provided by `react-native-webview`,  
allowing bidirectional communication between the browser and Status.  
A special `ReactNativeWebView` object is injected into each loaded page.

On the Status (React Native) end, `react-native-webview` provides  
the `WebView.injectJavascript` function,  
which enables execution of arbitrary code inside the webview.  
This allows injecting a function call to pass Status node responses back to the Dapp.

| Direction        | Side | Method                      |
|------------------|------|-----------------------------|
| Browser -> Status| JS   | `ReactNativeWebView.postMessage()` |
| Browser -> Status| RN   | `WebView.onMessage()`       |
| Status -> Browser| JS   | `ReactNativeWebView.onMessage()` |
| Status -> Browser| RN   | `WebView.injectJavascript()`|

## Compatibility

Status browser supports the following EIPs:

- **EIP-1102**: `eth_requestAccounts` support.
- **EIP-1193**: `connect`, `disconnect`, `chainChanged`,
and `accountsChanged` event support are not implemented.

## Changelog

| Version | Comment          |
|---------|-------------------|
| 0.1.0   | Initial release.  |

## Copyright

Copyright and related rights waived via CC0.
