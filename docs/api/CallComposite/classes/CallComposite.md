**CLASS**

# `CallComposite`

```swift
public class CallComposite
```

## Description

This is the main class representing the entry point for the Call Composite. 

## Methods

### `init`

Create an instance of `CallComposite` with options.

```swift
public init(withOptions options: CallCompositeOptions)
```

#### Parameters
* `options` - The CallCompositeOptions used to configure the experience.

### `launch`

Start call composite experience with joining a group call.

```swift
public func launch(with options: GroupCallOptions)
```

#### Parameters
* `options` - The GroupCallOptions used to locate the group call.  

Start call composite experience with joining a Teams meeting.

```swift
public func launch(with options: TeamsMeetingOptions)
```

#### Parameters
* `options` - The TeamsMeetingOptions used to locate the Teams meetings.


### `setTarget`
Assign an action to perform when an error occurs. 

```swift
public func setTarget(didFail action: ((CallCompositeError) -> Void)?)
```
#### Parameters
* `action` - The closure on subscribing the error thrown from Call Composite. 
