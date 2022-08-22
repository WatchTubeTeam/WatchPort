# WatchPort
Unavailable SwiftUI Views ported to watchOS

## Why?
We thought Apple gave watchOS devs a lacking experience. A lot of SwiftUI Views are marked as unavailable for watchOS and it leaves a lot to be desired. 

WatchPort tries to bring back missing functionality for you to use!

## Installation
### Swift Package Manager

[SPM](https://swift.org/package-manager/) is integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Specify the following in your `Package.swift`:

```swift
.package(url: "https://github.com/WatchTubeTeam/WatchPort", .branch("main")),
```

## Usage

WatchPort acts as a drop-in replacement. You can use unavailable SwiftUI Views as normal. Importing WatchPort will get rid of `'x' is unavailable in watchOS` errors where supported!

![](https://github.com/WatchTubeTeam/WatchPort/raw/main/imgs/DisclosureGroupGif.gif)

## Contributing

Contributions are welcome! Please open an issue or pull request if you find a bug or want to contribute.
Adding ports for new SwiftUI Views have a few requirements:
- [ ] Port swift file should be in /Sources/WatchPort/Ports/
- [ ] Port's name must be the same as the SwiftUI View's name
- [ ] Initializer must be the same as the original SwiftUI View's initializer for cross-compatibility
- [ ] DocC comments must be added to the port's initializers, pulled directly from SwiftUI
- [ ] Port must have all initializers that the original SwiftUI View has
- [ ] Port should have similar UI and behavior to the original SwiftUI View, adaptations for watchOS are allowed
- [ ] Port View should be wrapped with `#if os(watchOS)` `#endif` to avoid build issues

This criteria is just to make sure that writing UI with WatchPort is uncompromising.

## Ported Views
| View | Ported |
| ---- | --------- |
| ColorPicker | ❌ |
| DisclosureGroup | ✅ |

> More to come!
