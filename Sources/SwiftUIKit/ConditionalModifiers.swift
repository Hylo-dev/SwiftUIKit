import SwiftUI

public extension View {
    /// Applies a transform only when a condition is true.
    ///
    /// SwiftUI often pushes small conditional styling decisions into an outer
    /// `if` statement. That works, but it also forces the original view to be
    /// written twice: once with the extra modifier and once without it. This
    /// helper keeps the view chain intact, which makes the intent easier to
    /// scan and reduces the chance of the two branches drifting apart.
    ///
    /// Use this when the view should remain the same view conceptually and only
    /// a modifier or small wrapper changes with state. Prefer a normal Swift
    /// `if` when the branches represent meaningfully different view structures.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .if(isEnabled) { view in
    ///         view.foregroundStyle(.blue)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - condition: The condition that decides whether `transform` is used.
    ///   - transform: A closure that receives the current view and returns the
    ///     modified view for the true branch.
    /// - Returns: The transformed view when `condition` is true, otherwise the
    ///   original view.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies a transform only when an optional value exists.
    ///
    /// Optional-driven modifiers are common in SwiftUI: a badge, label, overlay,
    /// accessibility hint, selection value, or data-dependent style may only
    /// exist for some states. A normal `if let` usually duplicates the base
    /// view. This helper keeps the base view in one chain while still exposing
    /// the unwrapped value to the modifier that needs it.
    ///
    /// Use this when the optional value changes how a view is decorated, not
    /// when the absence of the value should replace the view with a different
    /// screen or component.
    ///
    /// ```swift
    /// Text("Inbox")
    ///     .ifLet(unreadCount) { view, count in
    ///         view.badge(count)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The optional value that gates the transform.
    ///   - transform: A closure that receives the current view and the unwrapped
    ///     value.
    /// - Returns: The transformed view when `value` is non-nil, otherwise the
    ///   original view.
    @ViewBuilder
    func ifLet<Value, Content: View>(
        _ value: Value?,
        @ViewBuilder transform: (Self, Value) -> Content
    ) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
