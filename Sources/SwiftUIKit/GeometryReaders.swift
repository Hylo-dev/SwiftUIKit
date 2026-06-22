import SwiftUI

public extension View {
    /// Reads the laid-out size of a view when that size changes.
    ///
    /// SwiftUI layout information is intentionally not pulled directly from a
    /// view. The native way to observe size has also evolved over time:
    /// `onGeometryChange` is the modern API, while older deployment targets
    /// still need the `GeometryReader` and preference-key pattern. `readSize`
    /// keeps call sites stable across those OS versions and lets app code focus
    /// on the value it actually needs.
    ///
    /// Use this when the size is an input to nearby UI state, such as aligning
    /// an overlay, sizing a sibling, tracking a card, or debugging a layout
    /// measurement. Avoid using it to build custom layout behavior that would
    /// be better expressed with SwiftUI's `Layout` protocol.
    ///
    /// ```swift
    /// Text("Measure me")
    ///     .readSize { size in
    ///         measuredSize = size
    ///     }
    /// ```
    ///
    /// - Parameter action: A closure called with the current size whenever
    ///   SwiftUI reports a changed value.
    /// - Returns: A view that reports its laid-out size.
    @ViewBuilder
    func readSize(
        _ action: @escaping (CGSize) -> Void
    ) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                action(size)
            }
        } else {
            background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                action(size)
            }
        }
    }

    /// Reads the laid-out frame of a view in a coordinate space.
    ///
    /// `readFrame` is the frame-focused companion to `readSize`. It exists
    /// because callers usually want either the size or the frame, and forcing a
    /// generic geometry transform into every call site makes the simple case
    /// harder to read. The helper uses `onGeometryChange` on newer systems and
    /// keeps a fallback for older supported deployment targets.
    ///
    /// Use `.local` when the value should describe the view inside its own
    /// coordinate space, `.global` when the value needs screen/window position,
    /// and `.named(...)` when the frame should be measured inside an explicit
    /// SwiftUI coordinate space.
    ///
    /// ```swift
    /// Text("Track me")
    ///     .readFrame(in: .global) { frame in
    ///         trackedFrame = frame
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - coordinateSpace: The SwiftUI coordinate space used for the frame.
    ///   - action: A closure called with the current frame whenever SwiftUI
    ///     reports a changed value.
    /// - Returns: A view that reports its laid-out frame.
    @ViewBuilder
    func readFrame(
        in coordinateSpace: CoordinateSpace,
        _ action: @escaping (CGRect) -> Void
    ) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: coordinateSpace)
            } action: { frame in
                action(frame)
            }
        } else {
            background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: FramePreferenceKey.self,
                        value: proxy.frame(in: coordinateSpace)
                    )
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) { frame in
                action(frame)
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize {
        .zero
    }

    static func reduce(
        value: inout CGSize,
        nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect {
        .zero
    }

    static func reduce(
        value: inout CGRect,
        nextValue: () -> CGRect
    ) {
        value = nextValue()
    }
}
