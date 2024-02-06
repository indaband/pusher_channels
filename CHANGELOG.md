## 0.5.0 - February 6, 2024
- Add support for trigger events

## 0.4.0 - January 26, 2023
- Add a dedicated checker for connection status. 
  This will improve the automatic reconnection resilience.

## 0.3.0 - November 6, 2022
- Replace pedantic by linter

## 0.2.0 - May 11, 2022
- Update mocktail dependency

## 0.1.6 - January 25, 2022

- resubscribe channels on reconnect
- reconnect after a connection error (status between 4200 and 4300)
- use the existent binds on channel resubscription

## 0.1.5 - November 23, 2021

- Change auto retry to be less aggressive

## 0.1.4 - November 17, 2021

- Implements auto retry when the connection is lost

## 0.1.3 - October 18, 2021

- Implements the pusher.bindGlobal and pusher.unbindGlobal

## 0.1.2 - October 14, 2021

- Fix pusher url

## 0.1.1 - October 14, 2021

- Downgrade the required version of mocktail

## 0.1.0 - October 14, 2021

- This is an initial and unstable implementation of Pusher Channels with supporting for public channels only
