import SwiftUI

public extension View {
    /// Runs an action only the first time a view appears.
    ///
    /// SwiftUI views can appear more than once as navigation, tab changes,
    /// conditional rendering, or parent updates move them through the hierarchy.
    /// Native `onAppear` intentionally reports each appearance. Many app tasks,
    /// however, want the first appearance only: initial loading, one-time
    /// analytics, setup work, or a single animation trigger. `onFirstAppear`
    /// captures that pattern without repeating `@State` guard code in every
    /// view.
    ///
    /// ```swift
    /// ContentView()
    ///     .onFirstAppear {
    ///         loadInitialData()
    ///     }
    /// ```
    ///
    /// - Parameter action: The closure to run the first time the view appears.
    /// - Returns: A view that performs the action once.
    func onFirstAppear(
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(FirstAppearModifier(action: action))
    }
}

private struct FirstAppearModifier: ViewModifier {
    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else {
                return
            }

            hasAppeared = true
            action()
        }
    }
}
