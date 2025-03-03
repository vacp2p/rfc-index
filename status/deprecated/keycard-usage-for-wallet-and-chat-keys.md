---
title: Keycard Usage for Wallet and Chat Keys
name: Keycard Usage for Wallet and Chat Keys
status: deprecated
description: In this specification, we describe how Status communicates with Keycard to create, store and use multiaccount.
editor: Filip Dimitrijevic <filip@status.im>
contributors:

---

## Abstract

This document specifies the integration of Keycard with Status
for creating, storing, and managing multiaccounts.

## Definitions

- **Keycard Hardwallet**: Refer to [Keycard Documentation](https://keycard.tech/docs/).

---

## Multiaccount Creation/Restoring

### Creation and Restoring via Mnemonic

1. **Retrieve Application Info**

   ```clojure

   status-im.hardwallet.card/get-application-info
   ```

2. **Initialize Card**

   ```clojure

   status-im.hardwallet.card/init-card
   ```

3. **Pairing and Key Generation**

   ```clojure
   status-im.hard
   wallet.card/generate-and-load-keys
   ```

### Restoring via Pairing

Used for pairing a card with an existing multiaccount:

1. **Retrieve Application Info**
2. **Pair Card**
3. **Generate and Load Keys**

---

## Multiaccount Unlocking

1. **Retrieve Application Info**
2. **Get Keys with PIN**
3. **Verify Pairing Status**

---

## Transaction Signing

1. **Retrieve Application Info**
2. **Sign Transaction**

   ```clojure

   status-im.hardwallet.card/sign
   ```

---

## Account Derivation

1. **Verify PIN**
2. **Export Account Key**

   ```clojure

   status-im.hardwallet.card/export-key
   ```

---

## PIN Management

### Reset PIN

- Change current PIN to new PIN.

### Unblock PIN

- If the PIN is entered incorrectly three times, use the PUK to reset.

---

## Status-Go Calls

### Required Status-Go API Calls

- **SaveAccountAndLoginWithKeycard**
- **LoginWithKeycard**
- **HashTransaction/HashMessage**
- **SendTransactionWithSignature**

---

## Key Storage

### Keycard-Backed Account

All keys are securely stored on the Keycard, retrieved as needed.

### Database Encryption

A Keycard account’s database uses the `encryption-public-key` as a password.

---

## Copyright

Copyright and related rights waived via CC0.
