import SwiftUI

/// Describes the common shadow used by `surface`.
///
/// SwiftUI's native `shadow` modifier is already flexible, but it becomes
/// noisy when the surface itself is trying to express the usual card-like
/// background: fill, outline, and shadow. `SurfaceShadow` keeps the
/// common drop-shadow case close to the surface declaration while still mapping
/// directly to SwiftUI's own shadow rendering.
///
/// ```swift
/// Text("Card")
///     .padding()
///     .surface(
///         .regularMaterial,
///         in: .roundedRect(cornerRadius: 18),
///         shadow: .drop(radius: 12, y: 4)
///     )
/// ```
public struct SurfaceShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Creates a drop shadow for a surface.
    ///
    /// The default color is intentionally subtle because `surface` is meant to
    /// be safe for repeated app UI, not just large showcase cards. Pass an
    /// explicit color when the design system needs a stronger or themed shadow.
    ///
    /// - Parameters:
    ///   - color: The shadow color.
    ///   - radius: The blur radius.
    ///   - x: The horizontal offset.
    ///   - y: The vertical offset.
    /// - Returns: A reusable surface shadow value.
    public static func drop(
        color: Color = .black.opacity(0.18),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> SurfaceShadow {
        SurfaceShadow(
            color: color,
            radius: radius,
            x: x,
            y: y
        )
    }
}

public extension View {
    /// Adds a shaped visual surface behind the view and records that shape for
    /// later SwiftUIKit modifiers.
    ///
    /// Native SwiftUI can express the same visual result with `background`,
    /// `RoundedRectangle`, `fill`, `shadow`, and sometimes
    /// `ignoresSafeArea`. The result is powerful but verbose, and the same shape
    /// often has to be repeated again for a border overlay. `surface` keeps the
    /// common case close to the view it styles and makes the selected shape
    /// available to `.stroke(...)`.
    ///
    /// Use this overload when a single `ShapeStyle` describes the surface: a
    /// color, semantic style such as `.primary`, material, or gradient. Use the
    /// builder overload when the background needs custom composition beyond
    /// shadow and safe-area behavior.
    ///
    /// ```swift
    /// Text("Save")
    ///     .padding(.horizontal, 16)
    ///     .padding(.vertical, 10)
    ///     .surface(.blue, in: .capsule)
    ///
    /// Text("Panel")
    ///     .padding()
    ///     .surface(
    ///         .ultraThickMaterial.opacity(0.86),
    ///         in: .roundedRect(cornerRadius: 16),
    ///         shadow: .drop(radius: 10, y: 3)
    ///     )
    ///     .stroke(.primary.opacity(0.1))
    /// ```
    ///
    /// - Parameters:
    ///   - style: The SwiftUI shape style used to fill the surface.
    ///   - shape: The shape used for the surface and inherited by later
    ///     SwiftUIKit stroke modifiers.
    ///   - fillStyle: The SwiftUI fill rule.
    ///   - shadow: An optional drop shadow applied to the filled surface.
    ///   - edges: The safe-area edges ignored by the background content.
    /// - Returns: A view with a shaped background surface.
    func surface<Style: ShapeStyle>(
        _ style: Style,
        in shape: SurfaceShape = .rect,
        fillStyle: FillStyle = FillStyle(),
        shadow: SurfaceShadow? = nil,
        ignoresSafeAreaEdges edges: Edge.Set = Edge.Set()
    ) -> some View {
        surface(in: shape) { shape in
            shape
                .fill(
                    style,
                    style: fillStyle
                )
                .surfaceShadow(shadow)
                .ignoresSafeArea(edges: edges)
        }
    }

    /// Adds a custom shaped background while still recording the surface shape.
    ///
    /// This overload exists for the moment when a background starts as a simple
    /// material or color and then grows: perhaps it needs opacity, a blend mode,
    /// a shadow, or a more specific fill composition. The closure receives the
    /// same `SurfaceShape` that `.stroke(...)` can inherit later, so the custom
    /// background and border stay visually aligned without repeating the shape
    /// at the call site.
    ///
    /// ```swift
    /// Text("Drop files here")
    ///     .padding()
    ///     .surface(in: .roundedRect(cornerRadius: 13)) { shape in
    ///         shape
    ///             .fill(.ultraThickMaterial)
    ///             .opacity(0.8)
    ///             .shadow(radius: 8)
    ///     }
    ///     .stroke(.accentColor, width: 2)
    /// ```
    ///
    /// - Parameters:
    ///   - shape: The shape used for the custom background and inherited by
    ///     later SwiftUIKit stroke modifiers.
    ///   - content: A builder that receives the selected shape and returns the
    ///     background view.
    /// - Returns: A view with a custom shaped background surface.
    func surface<Background: View>(
        in shape: SurfaceShape = .rect,
        @ViewBuilder content: (SurfaceShape) -> Background
    ) -> some View {
        background(content(shape))
        .preference(
            key: SurfaceShapePreferenceKey.self,
            value: shape
        )
    }
}

private extension View {
    @ViewBuilder
    func surfaceShadow(_ shadow: SurfaceShadow?) -> some View {
        if let shadow {
            self.shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
        } else {
            self
        }
    }
}
