---
title: ETH-SIMPLELOGIN
name: SimpleLogin, a blockchain-based authentication system
status: raw
category: Standards Track
tags:
editor: Ramses Fernandez <ramses@status.im>
contributors:
---

## Abstract

   This document specifies SimpleLogin, a blockchain-based authentication
   system designed to provide secure user registration, session
   management, and enhanced security measures including an emergency
   lockout mechanism with dual-signature verification. The system
   facilitates 90-day sessions with refresh capabilities and supports
   batch operations for scalability.

## Motivation

   With the increasing need for secure authentication mechanisms in
   decentralized applications, SimpleLogin provides a blockchain-based
   solution that ensures user authentication, session management, and
   enhanced security features. It includes an emergency system to handle
   lockouts and provides batch operations to enhance scalability.
   It uses 90-day sessions with refresh capabilities and enhanced security measures.

## Terminology

- **User**: An entity registered within the SimpleLogin system.

- **Session**: A temporary interaction period between a user and the system,
allowing access to certain functionalities.

- **Emergency Contact**: A designated user who can manage
emergency lockout procedures for another user.

- **Nonce**: A number used once to prevent replay attacks in
cryptographic communication.

- **Signature**: A cryptographic value that proves the authenticity of
a message.

- **Multicall**: Batch operations that allow multiple actions to be
performed in a single transaction.

- **IPFS Hash**: A hash used to reference data stored on the
InterPlanetary File System (IPFS).

## Architecture Overview

   SimpleLogin is a smart contract that resides on a blockchain network,
   providing the following key functionalities:

- **User Registration and Profile Management**: Users can register by
providing a profile hash stored on IPFS and update their profiles as
needed.

- **Session Management**: Implements session creation, refreshing, and
termination with strict timeouts and inactivity limits.

- **Security Measures**: Includes reentrancy guards, signature
verification using the secp256k1 curve, and activity tracking.

- **Emergency System**: Allows users to set an emergency contact who
can enable an emergency lockout in case of security concerns.

- **Batch Operations**: Supports batch processing of multiple
operations to enhance scalability and reduce transaction costs.

The contract uses specific time durations for sessions, refresh
windows, inactivity periods, and lockout timeouts to manage user
interactions effectively.

The system includes a comprehensive set of mappings and data
structures to track user registrations, sessions, nonces, profiles,
emergency contacts, and lockout states.

The following sections detail the constants, data structures,
functions, and implementation specifics of SimpleLogin.

## Constants and Parameters

   The contract defines several constants used throughout the system:

   ```solidity
   // Duration constants for session management
   uint40 public constant SESSION_DURATION = 90 days; // Regular session length
   uint40 public constant REFRESH_WINDOW = 14 days;   // Time window when refresh is allowed
   uint40 public constant MAX_INACTIVITY = 7 days;    // Maximum allowed inactivity period
   uint40 public constant SIGNIFICANT_INACTIVITY = 1 days; // Threshold for inactivity alerts
   uint40 public constant DISABLE_REQUEST_TIMEOUT = 1 days; // Timeout for lockout disable requests

   // Constants for signature validation (secp256k1 curve parameters)
   uint256 constant SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
   uint256 constant SECP256K1_HALF_N = SECP256K1_N / 2;

   // Constants for batch operations
   uint256 public constant MAX_BATCH_SIZE = 50; // Maximum number of operations in a single batch
   uint256 public constant MIN_BATCH_SIZE = 1;  // Minimum number of operations required

   // Maximum number of session refreshes allowed
   uint8 public constant MAX_REFRESHES = 5;
   ```

   These constants are critical for managing session durations,
   inactivity thresholds, signature validations, and batch operation
   constraints.

## Data Structures

   The contract uses several mappings and a struct to manage state:

   ```solidity
   // Session information storing all relevant session data
   struct Session {
       bool isValid;          // Current validity status
       uint40 expiresAt;      // Expiration timestamp
       uint40 lastActivity;   // Last activity timestamp
       uint8 refreshCount;    // Number of times refreshed
       address owner;         // Session owner address
       string dataHash;       // IPFS hash of session data
   }

   // Main storage mappings
   mapping(address => bool) public registered;        // Tracks user registration status
   mapping(address => uint256) public nonces;         // Tracks user nonces for replay protection
   mapping(address => string) public profiles;        // Stores user profile IPFS hashes
   mapping(bytes32 => Session) public sessions;       // Maps session IDs to session data
   mapping(address => bytes32) private lastSessionSalt; // Stores per-user salt for session ID generation

   // Emergency system storage
   mapping(address => address) public emergencyContact; // Maps user to their emergency contact
   mapping(address => bool) public emergencyLockout;    // Tracks if user is in emergency lockout
   mapping(address => bool) public isEmergencyContact;  // Tracks addresses that serve as emergency contacts
   mapping(address => bytes32) public pendingDisableLockouts; // Tracks pending disable requests
   mapping(address => uint40) public disableLockoutTimestamps; // Tracks when each disable request was made
   ```

   The `Session` struct is optimized for storage efficiency, with careful
   consideration of data types and struct packing.

## Function Definitions

   This section details all the functions implemented in the SimpleLogin
   contract, including their purpose, parameters, and internal processes.

### Registration and Profile Management

#### `register`

   **Description**: Allows a new user to register by providing a profile
   IPFS hash.

   **Function Definition**:

   ```solidity
   function register(string calldata profileHash) external nonReentrant {
       require(!registered[msg.sender], "SimpleLogin: already registered");
       require(bytes(profileHash).length > 0, "SimpleLogin: empty profile hash");

       registered[msg.sender] = true;
       profiles[msg.sender] = profileHash;

       emit UserRegistered(msg.sender);
   }
   ```

   **Parameters**:

- `profileHash`: The IPFS hash of the user's profile data.

   **Process**:

1. Checks if the caller is already registered.
2. Validates that the `profileHash` is not empty.
3. Marks the user as registered and stores the profile hash.
4. Emits the `UserRegistered` event.

#### `updateProfile`

   **Description**: Allows a registered user to update their profile.

   **Function Definition**:

   ```solidity
   function updateProfile(string calldata newProfileHash) external {
       require(registered[msg.sender], "SimpleLogin: not registered");
       require(bytes(newProfileHash).length > 0, "SimpleLogin: empty profile hash");
       require(!emergencyLockout[msg.sender], "SimpleLogin: emergency lockout active");

       profiles[msg.sender] = newProfileHash;
       emit UserProfileUpdated(msg.sender, newProfileHash);
   }
   ```

   **Parameters**:

- `newProfileHash`: The new IPFS hash of the user's profile data.

   **Process**:

1. Validates that the caller is registered and not under emergency lockout.
2. Ensures the `newProfileHash` is not empty.
3. Updates the user's profile hash.
4. Emits the `UserProfileUpdated` event.

### Emergency Contact Management

#### `setEmergencyContact`

   **Description**: Allows a user to designate an emergency contact.

   **Function Definition**:

   ```solidity
   function setEmergencyContact(address contact) external {
       require(contact != address(0), "SimpleLogin: invalid contact");
       require(contact != msg.sender, "SimpleLogin: cannot be own contact");
       require(registered[contact], "SimpleLogin: contact not registered");

       if (emergencyContact[msg.sender] != address(0)) {
           isEmergencyContact[emergencyContact[msg.sender]] = false;
       }

       emergencyContact[msg.sender] = contact;
       isEmergencyContact[contact] = true;

       emit EmergencyContactSet(msg.sender, contact);
   }
   ```

   **Parameters**:

- `contact`: The address of the emergency contact.

   **Process**:

1. Validates the `contact` address.
2. Checks that the contact is registered and not the caller themselves.
3. Updates the emergency contact mappings.
4. Emits the `EmergencyContactSet` event.

#### `removeEmergencyContact`

   **Description**: Allows a user to remove their emergency contact.

   **Function Definition**:

   ```solidity
   function removeEmergencyContact() external {
       require(emergencyContact[msg.sender] != address(0), "SimpleLogin: no contact set");
       require(!emergencyLockout[msg.sender], "SimpleLogin: emergency lockout active");

       address oldContact = emergencyContact[msg.sender];
       isEmergencyContact[oldContact] = false;
       emergencyContact[msg.sender] = address(0);

       emit EmergencyContactSet(msg.sender, address(0));
   }
   ```

   **Process**:

1. Checks that the caller has an emergency contact set.
2. Validates that the caller is not under emergency lockout.
3. Removes the emergency contact and updates mappings.
4. Emits the `EmergencyContactSet` event with a null address.

### Emergency Lockout System

#### `enableEmergencyLockout`

   **Description**: Allows an emergency contact to enable an emergency
   lockout for a user.

   **Function Definition**:

   ```solidity
   function enableEmergencyLockout(address user) external {
       require(emergencyContact[user] == msg.sender, "SimpleLogin: not emergency contact");
       require(!emergencyLockout[user], "SimpleLogin: lockout already active");

       emergencyLockout[user] = true;
       emit EmergencyLockoutEnabled(user, msg.sender);
   }
   ```

   **Parameters**:

- `user`: The address of the user to lock out.

   **Process**:

1. Validates that the caller is the emergency contact of the user.
2. Checks that the user is not already under lockout.
3. Sets the `emergencyLockout` flag for the user.
4. Emits the `EmergencyLockoutEnabled` event.

#### `initiateDisableLockout`

   **Description**: Allows a user under emergency lockout to initiate a
   request to disable the lockout.

   **Function Definition**:

   ```solidity
   function initiateDisableLockout(bytes calldata userSignature) external {
       require(emergencyLockout[msg.sender], "SimpleLogin: no lockout active");

       bytes32 message = keccak256(abi.encodePacked(
           "Disable emergency lockout",
           msg.sender,
           block.timestamp
       ));

       require(verify(message, userSignature), "SimpleLogin: invalid user signature");

       bytes32 requestId = keccak256(abi.encodePacked(msg.sender, block.timestamp));
       pendingDisableLockouts[msg.sender] = requestId;
       disableLockoutTimestamps[msg.sender] = uint40(block.timestamp);

       emit EmergencyLockoutDisableRequested(msg.sender, requestId);
   }
   ```

   **Parameters**:

- `userSignature`: The user's signature authorizing the disable request.

   **Process**:

1. Validates that the caller is under emergency lockout.
2. Creates a message for signature verification.
3. Verifies the user's signature.
4. Generates a `requestId` and stores it with a timestamp.
5. Emits the `EmergencyLockoutDisableRequested` event.

#### `confirmDisableLockout`

   **Description**: Allows the emergency contact to confirm and disable
   the emergency lockout.

   **Function Definition**:

   ```solidity
   function confirmDisableLockout(
       address user,
       bytes32 requestId,
       bytes calldata emergencyContactSignature
   ) external {
       require(emergencyContact[user] == msg.sender, "SimpleLogin: not emergency contact");
       require(pendingDisableLockouts[user] == requestId, "SimpleLogin: invalid or no request");

       bytes32 message = keccak256(abi.encodePacked(
           "Confirm disable lockout",
           user,
           requestId
       ));

       require(verify(message, emergencyContactSignature), "SimpleLogin: invalid contact signature");

       emergencyLockout[user] = false;
       delete pendingDisableLockouts[user];
       delete disableLockoutTimestamps[user];

       emit EmergencyLockoutDisabled(user, msg.sender);
   }
   ```

   **Parameters**:

- `user`: The address of the user under lockout.
- `requestId`: The identifier of the disable request.
- `emergencyContactSignature`: Signature from the emergency contact.

   **Process**:

1. Validates that the caller is the emergency contact of the user.
2. Checks that there is a valid pending disable request.
3. Verifies the emergency contact's signature.
4. Disables the emergency lockout and clears pending requests.
5. Emits the `EmergencyLockoutDisabled` event.

#### `cancelDisableLockout`

   **Description**: Allows a user to cancel a pending disable lockout request.

   **Function Definition**:

   ```solidity
   function cancelDisableLockout() external {
       require(pendingDisableLockouts[msg.sender] != bytes32(0), "SimpleLogin: no pending request");
       delete pendingDisableLockouts[msg.sender];
       delete disableLockoutTimestamps[msg.sender];
   }
   ```

   **Process**:

1. Checks that there is a pending disable request.
2. Deletes the request and timestamp from storage.

### Session Management

#### `createSession`

   **Description**: Allows a registered user to create a new session.

   **Function Definition**:

   ```solidity
   function createSession(bytes calldata signature, string calldata dataHash) 
       external 
       nonReentrant 
       returns (bytes32) 
   {
       require(registered[msg.sender], "SimpleLogin: not registered");
       require(!emergencyLockout[msg.sender], "SimpleLogin: emergency lockout active");
       require(bytes(dataHash).length > 0, "SimpleLogin: empty data hash");

       bytes32 message = keccak256(abi.encode(msg.sender, nonces[msg.sender]));
       require(verify(message, signature), "SimpleLogin: invalid signature");

       bytes32 sessionId = generateSessionId(msg.sender, nonces[msg.sender]);

       uint40 currentTime = uint40(block.timestamp);
       sessions[sessionId] = Session({
           isValid: true,
           expiresAt: currentTime + SESSION_DURATION,
           lastActivity: currentTime,
           refreshCount: 0,
           owner: msg.sender,
           dataHash: dataHash
       });

       nonces[msg.sender]++;

       emit NewSessionCreated(msg.sender, sessionId, dataHash);
       return sessionId;
   }
   ```

   **Parameters**:

- `signature`: The user's signature to verify the session creation request.
- `dataHash`: The IPFS hash of the session data.

   **Process**:

1. Validates that the caller is registered and not under emergency lockout.
2. Checks that `dataHash` is not empty.
3. Creates a message and verifies the user's signature using the current nonce.
4. Generates a unique `sessionId`.
5. Creates a new `Session` struct and stores it.
6. Increments the user's nonce.
7. Emits the `NewSessionCreated` event.

#### `refreshSession`

   **Description**: Allows the session owner to refresh the session's expiration.

   **Function Definition**:

   ```solidity
   function refreshSession(bytes32 sessionId) external nonReentrant {
       Session storage session = sessions[sessionId];

       require(session.owner == msg.sender, "SimpleLogin: not session owner");
       require(session.isValid, "SimpleLogin: invalid session");
       require(uint40(block.timestamp) <= session.expiresAt, "SimpleLogin: session expired");
       require(!emergencyLockout[msg.sender], "SimpleLogin: emergency lockout active");
       require(
           session.expiresAt - uint40(block.timestamp) <= REFRESH_WINDOW,
           "SimpleLogin: too early to refresh"
       );
       require(session.refreshCount < MAX_REFRESHES, "SimpleLogin: max refreshes exceeded");

       uint40 currentTime = uint40(block.timestamp);
       session.expiresAt = currentTime + SESSION_DURATION;
       session.lastActivity = currentTime;
       session.refreshCount++;

       emit SessionRefreshed(sessionId, session.expiresAt);
   }
   ```

   **Parameters**:

- `sessionId`: The identifier of the session to refresh.

   **Process**:

1. Retrieves the session and validates ownership.
2. Checks that the session is valid and not expired.
3. Ensures it is within the `REFRESH_WINDOW` and `MAX_REFRESHES` has not been exceeded.
4. Updates `expiresAt`, `lastActivity`, and increments `refreshCount`.
5. Emits the `SessionRefreshed` event.

#### `endSession`

   **Description**: Allows a session owner or their emergency contact
to invalidate a session.

   **Function Definition**:

   ```solidity
   function endSession(bytes32 sessionId) external nonReentrant {
       Session storage session = sessions[sessionId];

       require(
           session.owner == msg.sender || emergencyContact[session.owner] == msg.sender,
           "SimpleLogin: not authorized"
       );
       require(session.isValid, "SimpleLogin: invalid session");

       session.isValid = false;
       session.lastActivity = uint40(block.timestamp);

       emit SessionInvalidated(sessionId);
   }
   ```

   **Parameters**:

- `sessionId`: The identifier of the session to terminate.

   **Process**:

1. Validates that the caller is authorized.
2. Checks that the session is valid.
3. Sets `isValid` to `false` and updates `lastActivity`.
4. Emits the `SessionInvalidated` event.

#### `isSessionValid`

   **Description**: Checks whether a session is currently valid.

   **Function Definition**:

   ```solidity
   function isSessionValid(bytes32 sessionId) external view returns (bool) {
       Session memory session = sessions[sessionId];
       uint40 currentTime = uint40(block.timestamp);

       return session.isValid &&
              currentTime <= session.expiresAt &&
              currentTime <= session.lastActivity + MAX_INACTIVITY &&
              session.owner == msg.sender &&
              !emergencyLockout[session.owner];
   }
   ```

   **Parameters**:

- `sessionId`: The identifier of the session to validate.

   **Process**:

1. Retrieves the session data.
2. Validates session state, expiration, inactivity, ownership, and lockout status.
3. Returns a boolean indicating validity.

#### `getSessionData`

   **Description**: Retrieves the session data hash after validating the session.

   **Function Definition**:

   ```solidity
   function getSessionData(bytes32 sessionId) external returns (string memory) {
       Session storage session = sessions[sessionId];
       uint40 currentTime = uint40(block.timestamp);

       require(session.owner == msg.sender, "SimpleLogin: not session owner");
       require(session.isValid, "SimpleLogin: invalid session");
       require(currentTime <= session.expiresAt, "SimpleLogin: session expired");
       require(!emergencyLockout[session.owner], "SimpleLogin: emergency lockout active");
       require(
           currentTime <= session.lastActivity + MAX_INACTIVITY,
           "SimpleLogin: session inactive"
       );

       _updateActivity(sessionId);
       return session.dataHash;
   }
   ```

   **Parameters**:

- `sessionId`: The identifier of the session.

   **Process**:

1. Validates session ownership, validity, expiration, and inactivity.
2. Updates the session's activity timestamp.
3. Returns the `dataHash`.

#### `getSessionDetails`

   **Description**: Retrieves detailed information about a session.

   **Function Definition**:

   ```solidity
   function getSessionDetails(bytes32 sessionId) external view returns (
       bool isValid,
       uint40 expiresAt,
       uint40 lastActivity,
       string memory dataHash,
       address owner,
       uint8 refreshCount
   ) {
       Session memory session = sessions[sessionId];
       require(
           session.owner == msg.sender || 
           emergencyContact[session.owner] == msg.sender,
           "SimpleLogin: not authorized"
       );

       return (
           session.isValid,
           session.expiresAt,
           session.lastActivity,
           session.dataHash,
           session.owner,
           session.refreshCount
       );
   }
   ```

   **Parameters**:

- `sessionId`: The identifier of the session.

   **Process**:

1. Validates that the caller is authorized.
2. Returns detailed session information.

#### `_updateActivity`

   **Description**: Internal function to update the session's last activity timestamp.

   **Function Definition**:

   ```solidity
   function _updateActivity(bytes32 sessionId) internal {
       Session storage session = sessions[sessionId];
       uint40 currentTime = uint40(block.timestamp);
       uint40 inactivePeriod = currentTime - session.lastActivity;
       session.lastActivity = currentTime;

       emit ActivityUpdated(sessionId, currentTime);

       if(inactivePeriod > SIGNIFICANT_INACTIVITY) {
           emit SignificantInactivity(sessionId, inactivePeriod);
       }
   }
   ```

   **Process**:

1. Calculates the inactive period.
2. Updates the `lastActivity` timestamp.
3. Emits `ActivityUpdated` and possibly `SignificantInactivity` events.

### Batch Operations (Multicall)

#### `createMultipleSessions`

   **Description**: Allows creating multiple sessions in a single transaction.

   **Function Definition**:

   ```solidity
   function createMultipleSessions(
       address[] calldata users,
       bytes[] calldata signatures,
       string[] calldata dataHashes
   ) external nonReentrant returns (bytes32[] memory) {
       require(
           users.length == signatures.length && 
           signatures.length == dataHashes.length,
           "SimpleLogin: array length mismatch"
       );

       require(users.length >= MIN_BATCH_SIZE, "SimpleLogin: batch too small");
       require(users.length <= MAX_BATCH_SIZE, "SimpleLogin: batch too large");

       bytes32[] memory sessionIds = new bytes32[](users.length);

       for(uint i = 0; i < users.length; i++) {
           require(registered[users[i]], "SimpleLogin: user not registered");
           require(!emergencyLockout[users[i]], "SimpleLogin: emergency lockout active");
           require(bytes(dataHashes[i]).length > 0, "SimpleLogin: empty data hash");

           bytes32 message = keccak256(abi.encode(users[i], nonces[users[i]]));
           bytes memory signature = signatures[i];

           require(
               recoverSigner(message, signature) == users[i],
               "SimpleLogin: invalid signature"
           );

           sessionIds[i] = generateSessionId(users[i], nonces[users[i]]);

           uint40 currentTime = uint40(block.timestamp);
           sessions[sessionIds[i]] = Session({
               isValid: true,
               expiresAt: currentTime + SESSION_DURATION,
               lastActivity: currentTime,
               refreshCount: 0,
               owner: users[i],
               dataHash: dataHashes[i]
           });

           nonces[users[i]]++;

           emit NewSessionCreated(users[i], sessionIds[i], dataHashes[i]);
       }

       return sessionIds;
   }
   ```

   **Parameters**:

- `users`: Array of user addresses.
- `signatures`: Array of signatures for each user.
- `dataHashes`: Array of IPFS hashes for session data.

   **Process**:

1. Validates array lengths and batch size.
2. Iterates over each user to perform session creation steps.
3. Verifies signatures and increments nonces.
4. Emits `NewSessionCreated` events.
5. Returns an array of `sessionIds`.

#### `endMultipleSessions`

   **Description**: Ends multiple sessions in a single transaction.

   **Function Definition**:

   ```solidity
   function endMultipleSessions(bytes32[] calldata sessionIds) external nonReentrant {
       require(sessionIds.length >= MIN_BATCH_SIZE, "SimpleLogin: batch too small");
       require(sessionIds.length <= MAX_BATCH_SIZE, "SimpleLogin: batch too large");

       for(uint i = 0; i < sessionIds.length; i++) {
           Session storage session = sessions[sessionIds[i]];

           require(
               session.owner == msg.sender || emergencyContact[session.owner] == msg.sender,
               "SimpleLogin: not authorized"
           );
           require(session.isValid, "SimpleLogin: invalid session");

           session.isValid = false;
           session.lastActivity = uint40(block.timestamp);

           emit SessionInvalidated(sessionIds[i]);
       }
   }
   ```

   **Parameters**:

- `sessionIds`: Array of session identifiers to terminate.

   **Process**:

1. Validates batch size.
2. Iterates over each `sessionId`.
3. Validates authorization and session validity.
4. Sets `isValid` to `false` and updates `lastActivity`.
5. Emits `SessionInvalidated` events.

#### `updateMultipleProfiles`

   **Description**: Updates profiles for multiple users in a single transaction.

   **Function Definition**:

   ```solidity
   function updateMultipleProfiles(
       address[] calldata users,
       string[] calldata newProfileHashes
   ) external nonReentrant {
       require(
           users.length == newProfileHashes.length,
           "SimpleLogin: array length mismatch"
       );

       require(users.length >= MIN_BATCH_SIZE, "SimpleLogin: batch too small");
       require(users.length <= MAX_BATCH_SIZE, "SimpleLogin: batch too large");

       for(uint i = 0; i < users.length; i++) {
           require(users[i] == msg.sender, "SimpleLogin: not authorized");
           require(registered[users[i]], "SimpleLogin: not registered");
           require(!emergencyLockout[users[i]], "SimpleLogin: emergency lockout active");
           require(bytes(newProfileHashes[i]).length > 0, "SimpleLogin: empty profile hash");

           profiles[users[i]] = newProfileHashes[i];

           emit UserProfileUpdated(users[i], newProfileHashes[i]);
       }
   }
   ```

   **Parameters**:

- `users`: Array of user addresses.
- `newProfileHashes`: Array of new IPFS profile hashes.

   **Process**:

1. Validates array lengths and batch size.
2. Iterates over each user.
3. Validates authorization and status.
4. Updates profiles and emits events.

#### `enableMultipleEmergencyLockouts`

   **Description**: Allows an emergency contact to enable lockouts for multiple users.

   **Function Definition**:

   ```solidity
   function enableMultipleEmergencyLockouts(
       address[] calldata users
   ) external nonReentrant {
       require(users.length >= MIN_BATCH_SIZE, "SimpleLogin: batch too small");
       require(users.length <= MAX_BATCH_SIZE, "SimpleLogin: batch too large");

       for(uint i = 0; i < users.length; i++) {
           require(
               emergencyContact[users[i]] == msg.sender,
               "SimpleLogin: not emergency contact"
           );
           require(!emergencyLockout[users[i]], "SimpleLogin: lockout already active");

           emergencyLockout[users[i]] = true;

           emit EmergencyLockoutEnabled(users[i], msg.sender);
       }
   }
   ```

   **Parameters**:

- `users`: Array of user addresses to lock out.

   **Process**:

1. Validates batch size.
2. Iterates over each user.
3. Validates that the caller is the emergency contact.
4. Sets `emergencyLockout` to `true`.
5. Emits `EmergencyLockoutEnabled` events.

### Signature Verification

#### `verify`

   **Description**: Verifies the authenticity of a message signed by a user.

   **Function Definition**:

   ```solidity
   function verify(bytes32 message, bytes memory signature) internal view returns (bool) {
       (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

       if (uint256(r) == 0 || uint256(r) >= SECP256K1_N) return false;
       if (uint256(s) == 0 || uint256(s) > SECP256K1_HALF_N) return false;
       if (v != 27 && v != 28) return false;

       address recovered = ecrecover(
           keccak256(
               abi.encodePacked("\x19Ethereum Signed Message:\n32", message)
           ),
           v,
           r,
           s
       );

       return recovered == msg.sender;
   }
   ```

   **Parameters**:

- `message`: The hashed message that was signed.
- `signature`: The signature bytes.

   **Process**:

1. Splits the signature into `r`, `s`, and `v` components.
2. Validates `r`, `s`, and `v` according to secp256k1 standards.
3. Recovers the signer's address.
4. Compares the recovered address with `msg.sender`.

#### `splitSignature`

   **Description**: Splits a signature into its components.

   **Function Definition**:

   ```solidity
   function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
       require(sig.length == 65, "SimpleLogin: invalid signature length");

       assembly {
           r := mload(add(sig, 32))
           s := mload(add(sig, 64))
           v := byte(0, mload(add(sig, 96)))
       }

       if (v < 27) v += 27;

       return (r, s, v);
   }
   ```

   **Parameters**:

- `sig`: The signature bytes.

   **Process**:

1. Validates the length of the signature.
2. Extracts `r`, `s`, and `v` components.
3. Adjusts `v` if necessary.

#### `recoverSigner`

   **Description**: Helper function for signature recovery in batch operations.

   **Function Definition**:

   ```solidity
   function recoverSigner(
       bytes32 message,
       bytes memory signature
   ) internal pure returns (address) {
       bytes32 prefixedMessage = keccak256(
           abi.encodePacked("\x19Ethereum Signed Message:\n32", message)
       );

       (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

       require(uint256(s) <= SECP256K1_HALF_N, "SimpleLogin: invalid signature 's' value");
       require(v == 27 || v == 28, "SimpleLogin: invalid signature 'v' value");

       address recovered = ecrecover(prefixedMessage, v, r, s);
       require(recovered != address(0), "SimpleLogin: invalid signature");

       return recovered;
   }
   ```

   **Parameters**:

- `message`: The hashed message.
- `signature`: The signature bytes.

   **Process**:

1. Creates a prefixed message.
2. Splits the signature.
3. Validates `s` and `v` values.
4. Recovers the signer's address.

### View Functions

#### `getProfile`

   **Description**: Retrieves the profile hash of a registered user.

   **Function Definition**:

   ```solidity
   function getProfile(address user) external view returns (string memory) {
       require(registered[user], "SimpleLogin: user not registered");
       return profiles[user];
   }
   ```

   **Parameters**:

- `user`: The address of the user.

   **Process**:

1. Validates that the user is registered.
2. Returns the profile hash.

#### `getUserNonce`

   **Description**: Retrieves the current nonce of a user.

   **Function Definition**:

   ```solidity
   function getUserNonce(address user) external view returns (uint256) {
       return nonces[user];
   }
   ```

   **Parameters**:

- `user`: The address of the user.

   **Process**:

1. Returns the user's nonce.

#### `isDisableRequestValid`

   **Description**: Checks if a pending disable lockout request is still valid.

   **Function Definition**:

   ```solidity
   function isDisableRequestValid(address user) external view returns (bool) {
       bytes32 requestId = pendingDisableLockouts[user];
       if (requestId == bytes32(0)) return false;

       uint40 requestTimestamp = disableLockoutTimestamps[user];
       uint40 currentTime = uint40(block.timestamp);
       return currentTime <= requestTimestamp + DISABLE_REQUEST_TIMEOUT;
   }
   ```

   **Parameters**:

- `user`: The address of the user.

   **Process**:

1. Checks if there is a pending request.
2. Validates the request based on the timestamp and timeout.

## Implementation Details

### Reentrancy Guard

   The contract uses a `nonReentrant` modifier to prevent reentrant calls
   to functions that modify critical state.

   **Modifier Definition**:

   ```solidity
   modifier nonReentrant() {
       require(!_locked, "SimpleLogin: reentrant call");
       _locked = true;
       _;
       _locked = false;
   }
   ```

   **Process**:

1. Checks if the `_locked` state is `false`.
2. Sets `_locked` to `true` before function execution.
3. Resets `_locked` to `false` after execution.

### Session ID Generation

   **Function**: `generateSessionId`

   **Description**: Generates a unique session identifier using entropy
   from the blockchain and user-specific data.

   **Function Definition**:

   ```solidity
   function generateSessionId(address user, uint256 nonce) private returns (bytes32) {
       bytes32 blockEntropy = blockhash(block.number - 1);

       bytes32 prevSalt = lastSessionSalt[user];
       if (prevSalt == bytes32(0)) {
           prevSalt = keccak256(
               abi.encodePacked(
                   block.timestamp,
                   block.prevrandao,
                   block.coinbase,
                   user
               )
           );
       }

       bytes32 newSalt = keccak256(
           abi.encodePacked(
               prevSalt,
               blockEntropy,
               block.timestamp,
               block.prevrandao
           )
       );

       lastSessionSalt[user] = newSalt;

       return keccak256(
           abi.encodePacked(
               user,
               nonce,
               block.timestamp,
               blockEntropy,
               newSalt,
               block.prevrandao,
               block.coinbase
           )
       );
   }
   ```

   **Process**:

1. Retrieves entropy from the blockchain.
2. Uses a per-user salt updated with each session creation.
3. Combines user address, nonce, timestamps, and entropy to generate a unique `sessionId`.

### Nonce Management

   Nonces are used to prevent replay attacks during signature verification.

- Each user has an associated nonce stored in the `nonces` mapping.
- Nonces increment with each session creation.

### Event Logging

   The contract emits events to facilitate monitoring and logging of key actions:

- `UserRegistered(address indexed user);`
- `NewSessionCreated(address indexed user, bytes32 indexed sessionId, string dataHash);`
- `SessionInvalidated(bytes32 indexed sessionId);`
- `SessionRefreshed(bytes32 indexed sessionId, uint40 newExpiry);`
- `EmergencyContactSet(address indexed user, address indexed contact);`
- `EmergencyLockoutEnabled(address indexed user, address indexed triggeredBy);`
- `EmergencyLockoutDisabled(address indexed user, address indexed emergencyContact);`
- `EmergencyLockoutDisableRequested(address indexed user, bytes32 requestId);`
- `SignificantInactivity(bytes32 indexed sessionId, uint40 inactivePeriod);`
- `ActivityUpdated(bytes32 indexed sessionId, uint40 timestamp);`
- `UserProfileUpdated(address indexed user, string newProfileHash);`

## Security Considerations

- **Replay Protection**: Uses nonces to prevent replay attacks during
session creation and emergency procedures.

- **Signature Validation**: Ensures that signatures conform to
secp256k1 standards and are correctly verified.

- **Emergency Lockout**: Provides a mechanism for users to secure their
accounts in case of compromise, with dual-signature verification for
disabling lockouts.

- **Reentrancy Guard**: Protects against reentrancy attacks by using a
`nonReentrant` modifier on critical functions.

- **Session Inactivity**: Monitors inactivity and invalidates sessions
that exceed `MAX_INACTIVITY`.

- **Entropy Sources**: Uses blockchain-provided entropy sources like
`blockhash` and `block.prevrandao` for generating session IDs, but
acknowledges the limitations and potential predictability.

- **Access Control**: Validates that only authorized users can perform
certain actions, such as ending sessions or updating profiles.

- **Batch Operations Risks**: Ensures that batch operations do not
exceed predefined sizes to prevent denial-of-service through large
transactions.

## References

- EIP-155: Ethereum Improvement Proposal 155 - Simple replay
attack protection.

- SECP256K1: Standards for Efficient Cryptography Group,
"Recommended Elliptic Curve Domain Parameters", 2010.