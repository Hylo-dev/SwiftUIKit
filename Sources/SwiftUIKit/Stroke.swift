import SwiftUI

/// Describes a compact dash pattern for SwiftUIKit strokes.
///
/// SwiftUI's `StrokeStyle` accepts dash arrays such as `[6, 7]`, where the
/// numbers alternate between drawn and skipped lengths along the outline. That
/// native form is powerful, but it is not self-describing at the call site. This
/// type keeps the common dashed-border case readable while still allowing the
/// native array form when a design needs a more specific rhythm.
///
/// ```swift
/// Text("Import")
///     .padding()
///     .surface(.regularMaterial, in: .roundedRect(cornerRadius: 16))
///     .stroke(.accentColor, width: 2, dash: .dashed(length: 6, gap: 7))
///
/// Text("Advanced")
///     .stroke(.secondary, width: 1, dash: .pattern([10, 4, 2, 4]))
/// ```
public struct StrokeDash: Equatable {
    let values: [CGFloat]
    let phase: CGFloat

    /// A solid stroke with no dash pattern.
    public static var solid: StrokeDash {
        StrokeDash(
            values: [],
            phase: 0
        )
    }

    /// Creates the common two-value dash pattern.
    ///
    /// The `length` value is the painted segment. The `gap` value is the empty
    /// segment. SwiftUI repeats those values around the shape path.
    ///
    /// - Parameters:
    ///   - length: The length of each painted segment.
    ///   - gap: The length of each skipped segment.
    ///   - phase: The distance into the dash pattern where drawing begins.
    /// - Returns: A dash pattern suitable for the convenience stroke overload.
    public static func dashed(
        length: CGFloat,
        gap: CGFloat,
        phase: CGFloat = 0
    ) -> StrokeDash {
        StrokeDash(
            values: [
                length,
                gap
            ],
            phase: phase
        )
    }

    /// Creates a native SwiftUI dash pattern.
    ///
    /// Use this when the border rhythm needs more than the simple drawn/gap
    /// pair. The array follows SwiftUI's native `StrokeStyle` convention: values
    /// alternate between painted and skipped lengths along the shape path.
    ///
    /// - Parameters:
    ///   - values: The dash pattern passed to SwiftUI.
    ///   - phase: The distance into the dash pattern where drawing begins.
    /// - Returns: A dash pattern suitable for the convenience stroke overload.
    public static func pattern(
        _ values: [CGFloat],
        phase: CGFloat = 0
    ) -> StrokeDash {
        StrokeDash(
            values: values,
            phase: phase
        )
    }

    func strokeStyle(width: CGFloat) -> StrokeStyle {
        StrokeStyle(
            lineWidth: width,
            dash: values,
            dashPhase: phase
        )
    }
}

public extension View {
    /// Draws a stroke around the view using the nearest SwiftUIKit surface
    /// shape.
    ///
    /// Native SwiftUI usually expresses a shaped border as an overlay that
    /// repeats the background shape:
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding()
    ///     .background(.blue, in: RoundedRectangle(cornerRadius: 20))
    ///     .overlay {
    ///         RoundedRectangle(cornerRadius: 20)
    ///             .stroke(.gray, lineWidth: 2)
    ///     }
    /// ```
    ///
    /// This helper removes that repetition. When the view already has a
    /// SwiftUIKit `.surface(...)`, the stroke inherits its `SurfaceShape`. Pass
    /// `in:` when the border should deliberately use a different shape.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding()
    ///     .surface(.blue, in: .roundedRect(cornerRadius: 20))
    ///     .stroke(.gray, width: 2)
    ///
    /// Text("Override")
    ///     .stroke(.gray, width: 2, in: .capsule)
    /// ```
    ///
    /// - Parameters:
    ///   - style: The SwiftUI shape style used for the stroke.
    ///   - width: The line width.
    ///   - shape: An optional shape override. When omitted, the nearest
    ///     SwiftUIKit surface shape is used, falling back to `.rect`.
    ///   - dash: A compact dash description for the stroke.
    /// - Returns: A view with a shaped stroke overlay.
    func stroke<Style: ShapeStyle>(
        _ style: Style,
        width: CGFloat = 1,
        in shape: SurfaceShape? = nil,
        dash: StrokeDash = .solid
    ) -> some View {
        surfaceStroke(
            style,
            strokeStyle: dash.strokeStyle(width: width),
            shape: shape
        )
    }

    /// Draws a stroke around the view with a native SwiftUI `StrokeStyle`.
    ///
    /// This overload exists so the convenience API does not trap advanced
    /// callers in a simplified model. Use it when the border needs line caps,
    /// joins, miter limits, dash arrays, or dash phases exactly as SwiftUI
    /// defines them.
    ///
    /// ```swift
    /// Text("Advanced")
    ///     .padding()
    ///     .surface(.regularMaterial, in: .roundedRect(cornerRadius: 16))
    ///     .stroke(
    ///         .gray,
    ///         style: StrokeStyle(
    ///             lineWidth: 2,
    ///             lineCap: .round,
    ///             lineJoin: .round,
    ///             dash: [6, 7]
    ///         )
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - style: The SwiftUI shape style used for the stroke.
    ///   - strokeStyle: The native SwiftUI stroke style.
    ///   - shape: An optional shape override. When omitted, the nearest
    ///     SwiftUIKit surface shape is used, falling back to `.rect`.
    /// - Returns: A view with a shaped stroke overlay.
    func stroke<Style: ShapeStyle>(
        _ style: Style,
        style strokeStyle: StrokeStyle,
        in shape: SurfaceShape? = nil
    ) -> some View {
        surfaceStroke(
            style,
            strokeStyle: strokeStyle,
            shape: shape
        )
    }

    @ViewBuilder
    private func surfaceStroke<Style: ShapeStyle>(
        _ style: Style,
        strokeStyle: StrokeStyle,
        shape: SurfaceShape?
    ) -> some View {
        if let shape {
            overlay(
                shape.strokeBorder(
                    style,
                    style: strokeStyle
                )
            )
        } else {
            overlayPreferenceValue(SurfaceShapePreferenceKey.self) { inheritedShape in
                inheritedShape.strokeBorder(
                    style,
                    style: strokeStyle
                )
            }
        }
    }
}
