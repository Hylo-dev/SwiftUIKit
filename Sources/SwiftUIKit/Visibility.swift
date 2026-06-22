import SwiftUI

public extension View {
    /// Hides a view while choosing whether it should still occupy layout space.
    ///
    /// SwiftUI's native `hidden()` keeps the view in layout, while an `if`
    /// statement removes it entirely. Both behaviors are useful, but switching
    /// between them usually makes call sites noisy. This helper puts that
    /// choice in one modifier so state-driven visibility stays close to the
    /// view it affects.
    ///
    /// Use `remove: false` when surrounding layout should remain stable. Use
    /// `remove: true` when the hidden view should behave as if it is not in the
    /// hierarchy.
    ///
    /// ```swift
    /// Text("Optional detail")
    ///     .hidden(isCollapsed, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - isHidden: Whether the view should be hidden.
    ///   - remove: Whether the view should be removed from layout.
    /// - Returns: The original, hidden, or removed view.
    @ViewBuilder
    func hidden(
        _ isHidden: Bool,
        remove: Bool = false
    ) -> some View {
        if isHidden {
            if remove {
                EmptyView()
            } else {
                self.hidden()
            }
        } else {
            self
        }
    }
}
