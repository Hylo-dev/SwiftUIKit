import SwiftUI

/// A small, SwiftUI-shaped vocabulary for the reusable shapes used by
/// `surface` and `stroke`.
///
/// SwiftUI already has a `Shape` protocol, so this package avoids introducing a
/// public type with that name. `SurfaceShape` exists to make common background
/// and border shapes easy to write, easy to pass between helpers, and stable
/// enough for a later `.stroke(...)` modifier to reuse the shape chosen by
/// `.surface(...)`.
///
/// The type intentionally covers a compact set of shapes that are repeatedly
/// used for controls, cards, badges, pills, and drop targets. It is not meant
/// to replace custom SwiftUI shapes; when a design needs a completely custom
/// outline, native SwiftUI APIs should remain the escape hatch.
///
/// ```swift
/// Text("Continue")
///     .padding()
///     .surface(.blue, in: .capsule)
///
/// Text("Card")
///     .padding()
///     .surface(.regularMaterial, in: .roundedRect(cornerRadius: 16))
///     .stroke(.primary.opacity(0.12))
/// ```
public struct SurfaceShape: InsettableShape {
    private enum Kind {
        case rect
        case roundedRect(CGFloat, RoundedCornerStyle)
        case capsule(RoundedCornerStyle)
        case circle
        case ellipse
    }

    private let kind: Kind
    private let insetAmount: CGFloat

    private init(
        kind: Kind,
        insetAmount: CGFloat = 0
    ) {
        self.kind = kind
        self.insetAmount = insetAmount
    }

    /// A rectangular surface shape.
    ///
    /// Use `.rect` when the view already has the right outline or when the
    /// surface is meant to behave like a plain SwiftUI background.
    public static var rect: SurfaceShape {
        SurfaceShape(kind: .rect)
    }

    /// Creates a rounded rectangle surface shape.
    ///
    /// Rounded rectangles are the most common surface shape in app UI. Keeping
    /// them in `SurfaceShape` lets `.surface(...)` and `.stroke(...)` share the
    /// same radius without repeating `RoundedRectangle(cornerRadius:)` at every
    /// call site.
    ///
    /// - Parameters:
    ///   - cornerRadius: The radius used by the rounded rectangle.
    ///   - style: The SwiftUI corner style. The default favors the continuous
    ///     look commonly used in modern Apple UI.
    /// - Returns: A reusable rounded rectangle surface shape.
    public static func roundedRect(
        cornerRadius: CGFloat,
        style: RoundedCornerStyle = .continuous
    ) -> SurfaceShape {
        SurfaceShape(kind: .roundedRect(cornerRadius, style))
    }

    /// A capsule surface shape.
    ///
    /// Capsules are useful for pills, tags, compact buttons, and drag/drop
    /// targets where the horizontal length can change while the outline remains
    /// visually soft.
    public static var capsule: SurfaceShape {
        SurfaceShape(kind: .capsule(.continuous))
    }

    /// A circular surface shape.
    ///
    /// Use `.circle` for square icon buttons, avatars, counters, and other
    /// surfaces whose intended outline is a true circle.
    public static var circle: SurfaceShape {
        SurfaceShape(kind: .circle)
    }

    /// An elliptical surface shape.
    ///
    /// Use `.ellipse` when the view is not square but the desired outline should
    /// still be curved evenly inside the available rectangle.
    public static var ellipse: SurfaceShape {
        SurfaceShape(kind: .ellipse)
    }

    public func path(in rect: CGRect) -> Path {
        switch kind {
        case .rect:
            Rectangle()
                .inset(by: insetAmount)
                .path(in: rect)

        case let .roundedRect(cornerRadius, style):
            RoundedRectangle(
                cornerRadius: cornerRadius,
                style: style
            )
            .inset(by: insetAmount)
            .path(in: rect)

        case let .capsule(style):
            Capsule(style: style)
                .inset(by: insetAmount)
                .path(in: rect)

        case .circle:
            Circle()
                .inset(by: insetAmount)
                .path(in: rect)

        case .ellipse:
            Ellipse()
                .inset(by: insetAmount)
                .path(in: rect)
        }
    }

    public func inset(by amount: CGFloat) -> SurfaceShape {
        SurfaceShape(
            kind: kind,
            insetAmount: insetAmount + amount
        )
    }
}

struct SurfaceShapePreferenceKey: PreferenceKey {
    static var defaultValue: SurfaceShape {
        .rect
    }

    static func reduce(
        value: inout SurfaceShape,
        nextValue: () -> SurfaceShape
    ) {
        value = nextValue()
    }
}
