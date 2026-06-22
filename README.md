# SwiftUIKit

SwiftUIKit is a tiny SwiftUI helper package for modifiers that are useful often
enough to deserve a cleaner call site, but not large enough to become a design
system.

The package keeps the API close to SwiftUI. It avoids replacing native concepts:
colors, materials, gradients, `StrokeStyle`, `CoordinateSpace`, and SwiftUI
shapes still do the real work.

## Platforms

- iOS and iPadOS 14+
- macOS 11+
- tvOS 14+
- watchOS 7+
- visionOS 1+

File drop helpers are unavailable on tvOS and watchOS because SwiftUI does not
provide the required drop APIs on those platforms.

## Conditional Modifiers

```swift
Text("Inbox")
    .if(isEnabled) { view in
        view.foregroundStyle(.blue)
    }
```

```swift
Text("Inbox")
    .ifLet(unreadCount) { view, count in
        view.badge(count)
    }
```

## Surface And Stroke

`surface` creates a shaped background and remembers the shape for later
SwiftUIKit modifiers. `stroke` inherits that shape automatically unless you pass
an explicit override with `in:`.

```swift
Text("Hello")
    .padding()
    .surface(
        .blue,
        in: .roundedRect(cornerRadius: 20)
    )
    .stroke(
        .gray,
        width: 2
    )
```

```swift
Text("Drop files here")
    .padding()
    .surface(
        .ultraThickMaterial.opacity(0.8),
        in: .roundedRect(cornerRadius: 13),
        shadow: .drop(radius: 8),
        ignoresSafeAreaEdges: .all
    )
    .stroke(
        .accentColor,
        width: 2,
        dash: .dashed(
            length: 6,
            gap: 7
        )
    )
```

```swift
Text("Custom background")
    .padding()
    .surface(in: .roundedRect(cornerRadius: 13)) { shape in
        shape
            .fill(.ultraThickMaterial)
            .opacity(0.8)
            .shadow(radius: 8)
    }
    .stroke(
        .gray,
        style: StrokeStyle(
            lineWidth: 2,
            lineCap: .round,
            lineJoin: .round,
            dash: [
                6,
                7
            ]
        )
    )
```

```swift
Text("Override")
    .padding()
    .surface(.blue, in: .roundedRect(cornerRadius: 20))
    .stroke(
        .gray,
        width: 2,
        in: .capsule
    )
```

## Geometry

`readSize` and `readFrame` use `onGeometryChange` on newer OS versions and fall
back to `GeometryReader` on older supported versions.

```swift
Text("Measure me")
    .readSize { size in
        measuredSize = size
    }
```

```swift
Text("Track me")
    .readFrame(in: .global) { frame in
        trackedFrame = frame
    }
```

## File Drop

```swift
DropZone()
    .onFileDrop(isTargeted: $isTargeted) { urls in
        importFiles(urls)
    }
```

```swift
CanvasView()
    .onFileDrop(isTargeted: $isTargeted) { urls, location in
        importFiles(
            urls,
            at: location
        )
    }
```

## Visibility And First Appear

```swift
Text("Optional detail")
    .hidden(
        isCollapsed,
        remove: true
    )
```

```swift
ContentView()
    .onFirstAppear {
        loadInitialData()
    }
```

## Task Sleep

`Task.sleep(for:tolerance:)` accepts a SwiftUIKit duration value so projects can
use readable `.seconds`, `.milliseconds`, `.microseconds`, and `.nanoseconds`
call sites while still supporting older deployment targets.

```swift
try await Task.sleep(for: .milliseconds(300))
```

```swift
try await Task.sleep(
    for: .seconds(1),
    tolerance: .milliseconds(100)
)
```

## Versioned Modifiers

Versioned modifiers call newer SwiftUI APIs only when the runtime supports them
and otherwise leave the view unchanged.

```swift
Text("Glass")
    .glassEffectIfAvailable()
    .backgroundExtensionEffectIfAvailable()
```

```swift
ScrollView {
    Text("Row")
        .containerRelativeFrameIfAvailable(.horizontal)
}
.scrollBounceBehaviorIfAvailable(.basedOnSize)
.scrollClipDisabledIfAvailable()
.contentMarginsIfAvailable(.horizontal, 12)
```

```swift
Text("Sheet")
    .presentationCornerRadiusIfAvailable(24)
    .onChangeCompat(of: count, initial: true) { oldValue, newValue in
        update(
            from: oldValue,
            to: newValue
        )
    }
```
