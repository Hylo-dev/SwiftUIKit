import SwiftUI

/// A source-stable version of SwiftUI's `ScrollBounceBehavior`.
///
/// SwiftUI's native type is not available on SwiftUIKit's oldest deployment
/// targets, so exposing it directly would force call sites back into
/// `#available` checks. This small mirror keeps the public wrapper callable on
/// every supported platform and maps to the native value only when it exists.
public enum CompatibleScrollBounceBehavior: Equatable, Sendable {
    case automatic
    case always
    case basedOnSize
}

public extension View {
    /// Applies SwiftUI's Liquid Glass effect when the runtime supports it.
    ///
    /// On older OS versions, on visionOS, or when compiling with a toolchain
    /// that does not know the API yet, this modifier leaves the view unchanged.
    @ViewBuilder
    func glassEffectIfAvailable() -> some View {
        #if compiler(>=6.3) && !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            glassEffect()
        } else {
            self
        }
        #else
        self
        #endif
    }

    /// Extends a view's background effect when the runtime supports it.
    ///
    /// On older OS versions, or when compiling with a toolchain that does not
    /// know the API yet, this modifier leaves the view unchanged.
    @ViewBuilder
    func backgroundExtensionEffectIfAvailable(
        isEnabled: Bool = true
    ) -> some View {
        #if compiler(>=6.3)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            backgroundExtensionEffect(isEnabled: isEnabled)
        } else {
            self
        }
        #else
        self
        #endif
    }

    /// Applies SwiftUI's scroll bounce behavior when the runtime supports it.
    @ViewBuilder
    func scrollBounceBehaviorIfAvailable(
        _ behavior: CompatibleScrollBounceBehavior,
        axes: Axis.Set = [.vertical]
    ) -> some View {
        if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
            scrollBounceBehavior(
                behavior.swiftUIScrollBounceBehavior,
                axes: axes
            )
        } else {
            self
        }
    }

    /// Disables scroll clipping when the runtime supports it.
    @ViewBuilder
    func scrollClipDisabledIfAvailable(
        _ disabled: Bool = true
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollClipDisabled(disabled)
        } else {
            self
        }
    }

    /// Flashes scroll indicators for a changed value when supported.
    @ViewBuilder
    func scrollIndicatorsFlashIfAvailable<Value: Equatable>(
        trigger value: Value
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollIndicatorsFlash(trigger: value)
        } else {
            self
        }
    }

    /// Flashes scroll indicators on appear when supported.
    @ViewBuilder
    func scrollIndicatorsFlashIfAvailable(
        onAppear: Bool
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollIndicatorsFlash(onAppear: onAppear)
        } else {
            self
        }
    }

    /// Applies content margins when the runtime supports them.
    @ViewBuilder
    func contentMarginsIfAvailable(
        _ edges: Edge.Set = .all,
        _ insets: EdgeInsets
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            contentMargins(
                edges,
                insets
            )
        } else {
            self
        }
    }

    /// Applies content margins when the runtime supports them.
    @ViewBuilder
    func contentMarginsIfAvailable(
        _ edges: Edge.Set = .all,
        _ length: CGFloat?
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            contentMargins(
                edges,
                length
            )
        } else {
            self
        }
    }

    /// Applies equal content margins on all edges when supported.
    @ViewBuilder
    func contentMarginsIfAvailable(
        _ length: CGFloat
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            contentMargins(length)
        } else {
            self
        }
    }

    /// Applies a container-relative frame when the runtime supports it.
    @ViewBuilder
    func containerRelativeFrameIfAvailable(
        _ axes: Axis.Set,
        alignment: Alignment = .center
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            containerRelativeFrame(
                axes,
                alignment: alignment
            )
        } else {
            self
        }
    }

    /// Applies a counted container-relative frame when supported.
    @ViewBuilder
    func containerRelativeFrameIfAvailable(
        _ axes: Axis.Set,
        count: Int,
        span: Int = 1,
        spacing: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            containerRelativeFrame(
                axes,
                count: count,
                span: span,
                spacing: spacing,
                alignment: alignment
            )
        } else {
            self
        }
    }

    /// Applies a custom container-relative frame when supported.
    @ViewBuilder
    func containerRelativeFrameIfAvailable(
        _ axes: Axis.Set,
        alignment: Alignment = .center,
        _ length: @escaping (CGFloat, Axis) -> CGFloat
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            containerRelativeFrame(
                axes,
                alignment: alignment,
                length
            )
        } else {
            self
        }
    }

    /// Binds a scroll position id when the runtime supports it.
    @ViewBuilder
    func scrollPositionIfAvailable<ID: Hashable>(
        id: Binding<ID?>,
        anchor: UnitPoint? = nil
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollPosition(
                id: id,
                anchor: anchor
            )
        } else {
            self
        }
    }

    /// Applies a presentation corner radius when the runtime supports it.
    @ViewBuilder
    func presentationCornerRadiusIfAvailable(
        _ cornerRadius: CGFloat?
    ) -> some View {
        if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
            presentationCornerRadius(cornerRadius)
        } else {
            self
        }
    }

    /// Runs an old/new value action for changes across supported OS versions.
    @ViewBuilder
    func onChangeCompat<Value: Equatable>(
        of value: Value,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(
                of: value,
                initial: initial,
                action
            )
        } else {
            modifier(
                OnChangeCompatModifier(
                    value: value,
                    initial: initial,
                    action: action
                )
            )
        }
    }
}

private extension CompatibleScrollBounceBehavior {
    @available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *)
    var swiftUIScrollBounceBehavior: ScrollBounceBehavior {
        switch self {
        case .automatic:
            return .automatic

        case .always:
            return .always

        case .basedOnSize:
            return .basedOnSize
        }
    }
}

private struct OnChangeCompatModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let initial: Bool
    let action: (_ oldValue: Value, _ newValue: Value) -> Void

    @State private var hasAppeared = false
    @State private var previousValue: Value?

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else {
                    return
                }

                hasAppeared = true
                previousValue = value

                if initial {
                    action(
                        value,
                        value
                    )
                }
            }
            .onChange(of: value) { newValue in
                let oldValue = previousValue ?? newValue

                previousValue = newValue
                action(
                    oldValue,
                    newValue
                )
            }
    }
}
