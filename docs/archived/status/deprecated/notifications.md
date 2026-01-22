# NOTIFICATIONS

| Field | Value |
| --- | --- |
| Name | Notifications |
| Slug | 130 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |
| Contributors | Eric Dvorsak <eric@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/notifications.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/notifications.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/notifications.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/notifications.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/notifications.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/notifications.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Local Notifications

A client should implement local notifications to offer notifications
for any event in the app without the privacy cost and dependency on third party services.
This means that the client should run a background service to continuously or periodically check for updates.

### Android

Android allows running services on the device. When the user enables notifications,
the client may start a ``Foreground Service`,
and display a permanent notification indicating that the service is running,
as required by Android guidelines.
The service will simply keep the app from being killed by the system when it is in the background.
The client will then be able to run in the background
and display local notifications on events such as receiving a message in a one to one chat.

To facilitate the implementation of local notifications,
a node implementation such as `status-go` may provide a specific `notification` signal.

Notifications are a separate process in Android, and interaction with a notification generates an `Intent`.
To handle intents, the `NewMessageSignalHandler` may use a `BroadcastReceiver`,
in order to update the state of local notifications when the user dismisses or tap a notification.
If the user taps on a notification, the `BroadcastReceiver` generates a new intent to open the app should use universal links to get the user to the right place.

### iOS

We are not able to offer local notifications on iOS because there is no concept of services in iOS.
It offers background updates but they’re not consistently triggered, and cannot be relied upon.
The system decides when the background updates are triggered and the heuristics aren't known.

## Why is there no Push Notifications?

Push Notifications, as offered by Apple and Google are a privacy concern,
they require a centralized service that is aware of who the notification needs to be delivered to.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- None
