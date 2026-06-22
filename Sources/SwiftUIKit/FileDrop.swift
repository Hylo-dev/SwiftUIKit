import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if !os(tvOS) && !os(watchOS)
import CoreTransferable

public extension View {
    /// Handles dropped files as file URLs.
    ///
    /// SwiftUI's native drop APIs are flexible because they expose the lower
    /// level transfer machinery. For the common "user dropped files here" case,
    /// that flexibility usually means repeating UTType lists, item-provider
    /// loading, and target-state plumbing at every drop zone. `onFileDrop`
    /// keeps that common case focused on the value the app wants: `[URL]`.
    ///
    /// The helper uses modern Transferable URL drops on newer systems and falls
    /// back to the `onDrop(of: [.fileURL])` provider flow on older supported
    /// systems. The public call site stays the same across those OS versions.
    ///
    /// ```swift
    /// RoundedRectangle(cornerRadius: 16)
    ///     .stroke(.secondary)
    ///     .onFileDrop(isTargeted: $isTargeted) { urls in
    ///         importFiles(urls)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - isTargeted: An optional binding that tracks whether a compatible
    ///     file drop is currently targeting the view.
    ///   - action: A closure called with dropped file URLs.
    /// - Returns: A view that accepts file URL drops.
    func onFileDrop(
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL]) -> Void
    ) -> some View {
        onFileDrop(isTargeted: isTargeted) { urls, _ in
            action(urls)
        }
    }

    /// Handles dropped files as file URLs and includes the drop location.
    ///
    /// Use this overload when the drop position matters, such as inserting an
    /// asset at a canvas point or choosing the nearest row, column, or region.
    /// The location is the same point SwiftUI reports from its native drop APIs.
    ///
    /// ```swift
    /// CanvasView()
    ///     .onFileDrop(isTargeted: $isTargeted) { urls, location in
    ///         importFiles(urls, at: location)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - isTargeted: An optional binding that tracks whether a compatible
    ///     file drop is currently targeting the view.
    ///   - action: A closure called with dropped file URLs and the drop
    ///     location.
    /// - Returns: A view that accepts file URL drops.
    @ViewBuilder
    func onFileDrop(
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL], CGPoint) -> Void
    ) -> some View {
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            dropDestination(
                for: URL.self,
                action: { urls, location in
                    guard !urls.isEmpty else {
                        return false
                    }

                    action(
                        urls,
                        location
                    )

                    return true
                },
                isTargeted: { targeted in
                    isTargeted?.wrappedValue = targeted
                }
            )
        } else {
            onDrop(
                of: [
                    .fileURL
                ],
                isTargeted: isTargeted
            ) { providers, location in
                guard !providers.isEmpty else {
                    return false
                }

                loadFileURLs(from: providers) { urls in
                    guard !urls.isEmpty else {
                        return
                    }

                    action(
                        urls,
                        location
                    )
                }

                return true
            }
        }
    }
}

private func loadFileURLs(
    from providers: [NSItemProvider],
    action: @escaping ([URL]) -> Void
) {
    let group = DispatchGroup()
    let lock = NSLock()
    var urls: [URL] = []

    for provider in providers {
        group.enter()

        provider.loadItem(
            forTypeIdentifier: UTType.fileURL.identifier,
            options: nil
        ) { item, _ in
            if let url = fileURL(from: item) {
                lock.lock()
                urls.append(url)
                lock.unlock()
            }

            group.leave()
        }
    }

    group.notify(queue: .main) {
        action(urls)
    }
}

private func fileURL(from item: NSSecureCoding?) -> URL? {
    if let url = item as? URL {
        return url
    }

    if let url = item as? NSURL {
        return url as URL
    }

    if let data = item as? Data {
        return fileURL(from: data)
    }

    if let string = item as? String {
        return URL(string: string)
    }

    return nil
}

private func fileURL(from data: Data) -> URL? {
    guard let string = String(
        data: data,
        encoding: .utf8
    ) else {
        return nil
    }

    return URL(string: string)
}
#endif

#if os(tvOS) || os(watchOS)
public extension View {
    /// File drop is unavailable on this platform.
    ///
    /// tvOS and watchOS do not expose the file drop APIs used by SwiftUI on
    /// iOS, iPadOS, macOS, and visionOS. The unavailable overload keeps the
    /// package surface explicit so unsupported platforms fail with a clear
    /// message instead of a missing-symbol surprise.
    @available(tvOS, unavailable, message: "File drop is not available on tvOS.")
    @available(watchOS, unavailable, message: "File drop is not available on watchOS.")
    func onFileDrop(
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL]) -> Void
    ) -> some View {
        self
    }

    /// File drop with location is unavailable on this platform.
    ///
    /// tvOS and watchOS do not expose the file drop APIs used by SwiftUI on
    /// iOS, iPadOS, macOS, and visionOS. The unavailable overload keeps the
    /// package surface explicit so unsupported platforms fail with a clear
    /// message instead of a missing-symbol surprise.
    @available(tvOS, unavailable, message: "File drop is not available on tvOS.")
    @available(watchOS, unavailable, message: "File drop is not available on watchOS.")
    func onFileDrop(
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL], CGPoint) -> Void
    ) -> some View {
        self
    }
}
#endif
