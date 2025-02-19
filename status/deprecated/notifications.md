---
title: NOTIFICATIONS
name: Notifications
status: deprecated
description: A client should implement local notifications to offer notifications for any event in the app without the privacy cost and dependency on third party services.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Eric Dvorsak <eric@status.im>
---

## Local Notifications

A client should implement local notifications to offer notifications  
for any event in the app without the privacy cost and dependency on third-party services.
This approach requires the client to run a background service to continuously  
or periodically check for updates.

### Android

Android allows running services on the device.  
When the user enables notifications, the client may start a `Foreground Service`
and display a permanent notification indicating that the service is running,  
as required by Android guidelines.  
This service ensures that the app is not killed by the system
when it runs in the background.  
The client can then run in the background
and display local notifications on events,  
such as receiving a message in a one-to-one chat.

To facilitate implementing local notifications,
a node implementation like `status-go` may provide a specific notification signal.

Notifications run as a separate process on Android,  
and interacting with a notification generates an Intent.  
The `NewMessageSignalHandler` may use a `BroadcastReceiver` to handle intents  
and update the state of local notifications
when the user dismisses or taps a notification.  
If the user taps on a notification,
the `BroadcastReceiver` generates a new intent to open the app,
using universal links to navigate the user to the correct place.

### iOS

Local notifications cannot be offered on iOS,  
as there is no concept of persistent background services in iOS.  
It does support background updates, but these are not consistently triggered  
and cannot be relied upon. The system determines when background updates occur,
based on unknown heuristics.

### Why Are There No Push Notifications?

Push Notifications, as provided by Apple and Google, present a privacy concern,
as they require a centralized service that knows the recipient of each notification.

## Copyright

Copyright and related rights waived via CC0.
