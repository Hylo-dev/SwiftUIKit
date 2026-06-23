# Unified File Import Modifier Design

## Goal

Unify file picker and file drop behavior behind one SwiftUI modifier. A view using
the modifier should behave as a single import target: clicking or tapping can open
the system file picker, while dropping compatible files can import them directly.

The public API should remove the conceptual split between "file importer" and
"file drop" without forcing every caller to enable both behaviors.

## Public API

Add a public mode enum:

```swift
public enum FileImportMode {
    case automatic
    case pickerOnly
    case dropOnly
}
```

Add a new modifier named `onFileImport`, with a default mode of `.automatic`:

```swift
.onFileImport(
    mode: .automatic,
    allowedContentTypes: [.item],
    allowsMultipleSelection: true,
    isTargeted: $isTargeted
) { urls in
    importFiles(urls)
}
```

The modifier should expose the same simple output shape as `onFileDrop`: imported
files arrive as `[URL]`.

## Behavior

- `.automatic`: click or tap opens the system picker; compatible file drops import
  directly.
- `.pickerOnly`: click or tap opens the system picker; file drops are not attached.
- `.dropOnly`: compatible file drops import directly; click or tap does not open
  the picker.

`allowedContentTypes` should be shared by picker and drop paths so one modifier
configuration describes the allowed imports. The picker uses those types directly.
The drop path accepts file URL transfers and filters the resulting URLs against the
same type list where type information can be resolved.

## Architecture

Implement the new API as a `ViewModifier` with private `@State` used to present
SwiftUI's `fileImporter`. The modifier composes two optional behaviors:

- picker presentation, enabled for `.automatic` and `.pickerOnly`
- drop handling, enabled for `.automatic` and `.dropOnly`

The existing drop implementation should be reused rather than duplicated. The
current `dropDestination` path remains available on iOS 16, macOS 13, and
visionOS 1 or newer. Older supported systems keep the current `onDrop(of:
[.fileURL])` fallback.

The existing `onFileDrop` API should remain source-compatible and delegate to the
same private drop helper used by `onFileImport`.

## Error Handling

The action closure is called only when at least one URL is available. Picker
cancellation should be ignored. Picker failures should not call the import action.
The initial implementation does not need a public error callback because the
existing file drop API also exposes only successful URL imports.

## Platform Availability

Keep tvOS and watchOS unavailable for these file import helpers. They should fail
with explicit unavailable overloads, matching the existing `onFileDrop` behavior.

The package's deployment targets remain unchanged.

## Tests And Docs

Update compile tests to cover:

- `.onFileImport` with default `.automatic`
- `.onFileImport(mode: .pickerOnly)`
- `.onFileImport(mode: .dropOnly)`
- existing `.onFileDrop` overloads

Update README examples to introduce the unified modifier and keep a small note for
drop-only usage if `onFileDrop` stays public.
