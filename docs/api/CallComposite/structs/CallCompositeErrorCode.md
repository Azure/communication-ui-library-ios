**STRUCT**

# `CallCompositeErrorCode`

Call Composite runtime error types.

```swift
public struct CallCompositeErrorCode
```

## Properties

### `callJoin`

Error when local user fails to join a call.

```swift
public static let callJoin: String = "callJoin"
```

### `callEnd`

Error when a call disconnects unexpectedly or fails on ending.

```swift
public static let callEnd: String = "callEnd"
```

### `tokenExpired`

Error when the input token is expired. 

```swift
public static let tokenExpired: String = "tokenExpired"
```
