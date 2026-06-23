import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Controls which file import interactions are attached to a view.
public enum FileImportMode {
    /// Clicks and taps open the system picker; compatible drops import directly.
    case automatic

    /// Clicks and taps open the system picker; drops are not attached.
    case pickerOnly

    /// Compatible drops import directly; clicks and taps do not open the picker.
    case dropOnly
}

#if !os(tvOS) && !os(watchOS)
import CoreTransferable

public extension View {
    /// Handles file imports from both the system picker and file drops.
    ///
    /// `onFileImport` treats the modified view as a single import target. In the
    /// default `.automatic` mode, clicking or tapping the view opens the system
    /// file picker, while dropping compatible files imports them directly. Use
    /// `.pickerOnly` or `.dropOnly` when a call site needs only one interaction.
    ///
    /// ```swift
    /// DropZone()
    ///     .onFileImport(isTargeted: $isTargeted) { urls in
    ///         importFiles(urls)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - mode: The picker and drop interactions attached to the view.
    ///   - allowedContentTypes: The file types accepted by the picker and drop
    ///     paths.
    ///   - allowsMultipleSelection: Whether the picker allows selecting more
    ///     than one file.
    ///   - isTargeted: An optional binding that tracks whether a compatible file
    ///     drop is currently targeting the view.
    ///   - action: A closure called with imported file URLs.
    /// - Returns: A view that can import files.
    func onFileImport(
        mode: FileImportMode = .automatic,
        allowedContentTypes: [UTType] = [
            .item
        ],
        allowsMultipleSelection: Bool = true,
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL]) -> Void
    ) -> some View {
        modifier(
            FileImportModifier(
                mode: mode,
                allowedContentTypes: allowedContentTypes,
                allowsMultipleSelection: allowsMultipleSelection,
                isTargeted: isTargeted,
                action: action
            )
        )
    }

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
        fileDrop(
            allowedContentTypes: [
                .item
            ],
            isTargeted: isTargeted,
            perform: action
        )
    }
}

private struct FileImportModifier: ViewModifier {
    let mode: FileImportMode
    let allowedContentTypes: [UTType]
    let allowsMultipleSelection: Bool
    let isTargeted: Binding<Bool>?
    let action: ([URL]) -> Void

    @State private var isFileImporterPresented = false

    @ViewBuilder
    func body(content: Content) -> some View {
        switch mode {
        case .automatic:
            filePicker(
                for: content.fileDrop(
                    allowedContentTypes: fileImportAllowedContentTypes,
                    isTargeted: isTargeted
                ) { urls, _ in
                    action(urls)
                }
            )

        case .pickerOnly:
            filePicker(for: content)

        case .dropOnly:
            content.fileDrop(
                allowedContentTypes: fileImportAllowedContentTypes,
                isTargeted: isTargeted
            ) { urls, _ in
                action(urls)
            }
        }
    }

    private var fileImportAllowedContentTypes: [UTType] {
        normalizedFileImportContentTypes(allowedContentTypes)
    }

    private func filePicker<ImportContent: View>(
        for content: ImportContent
    ) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                isFileImporterPresented = true
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: fileImportAllowedContentTypes,
                allowsMultipleSelection: allowsMultipleSelection
            ) { result in
                handleFileImporterResult(result)
            }
    }

    private func handleFileImporterResult(
        _ result: Result<[URL], Error>
    ) {
        guard case let .success(urls) = result else {
            return
        }

        let importedURLs = fileURLs(
            urls,
            matching: fileImportAllowedContentTypes
        )

        guard !importedURLs.isEmpty else {
            return
        }

        action(importedURLs)
    }
}

private extension View {
    func fileDrop(
        allowedContentTypes: [UTType],
        isTargeted: Binding<Bool>?,
        perform action: @escaping ([URL], CGPoint) -> Void
    ) -> some View {
        modifier(
            FileDropModifier(
                allowedContentTypes: allowedContentTypes,
                isTargeted: isTargeted,
                action: action
            )
        )
    }
}

private struct FileDropModifier: ViewModifier {
    let allowedContentTypes: [UTType]
    let isTargeted: Binding<Bool>?
    let action: ([URL], CGPoint) -> Void

    private var fileImportAllowedContentTypes: [UTType] {
        normalizedFileImportContentTypes(allowedContentTypes)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            content.dropDestination(
                for: URL.self,
                action: { urls, location in
                    let importedURLs = fileURLs(
                        urls,
                        matching: fileImportAllowedContentTypes
                    )

                    guard !importedURLs.isEmpty else {
                        return false
                    }

                    action(
                        importedURLs,
                        location
                    )

                    return true
                },
                isTargeted: { targeted in
                    isTargeted?.wrappedValue = targeted
                }
            )
        } else {
            content.onDrop(
                of: [
                    .fileURL
                ],
                isTargeted: isTargeted
            ) { providers, location in
                guard !providers.isEmpty else {
                    return false
                }

                loadFileURLs(from: providers) { urls in
                    let importedURLs = fileURLs(
                        urls,
                        matching: fileImportAllowedContentTypes
                    )

                    guard !importedURLs.isEmpty else {
                        return
                    }

                    action(
                        importedURLs,
                        location
                    )
                }

                return true
            }
        }
    }
}

private func normalizedFileImportContentTypes(
    _ contentTypes: [UTType]
) -> [UTType] {
    guard !contentTypes.isEmpty else {
        return [
            .item
        ]
    }

    return contentTypes
}

private func fileURLs(
    _ urls: [URL],
    matching allowedContentTypes: [UTType]
) -> [URL] {
    let allowedContentTypes = normalizedFileImportContentTypes(
        allowedContentTypes
    )

    guard !allowedContentTypes.contains(.item) else {
        return urls
    }

    return urls.filter { url in
        fileURL(
            url,
            conformsToAnyOf: allowedContentTypes
        )
    }
}

private func fileURL(
    _ url: URL,
    conformsToAnyOf allowedContentTypes: [UTType]
) -> Bool {
    guard let contentType = contentType(for: url) else {
        return false
    }

    return allowedContentTypes.contains { allowedContentType in
        contentType.conforms(to: allowedContentType)
    }
}

private func contentType(for url: URL) -> UTType? {
    if let resourceValues = try? url.resourceValues(forKeys: [
        .contentTypeKey
    ]),
        let contentType = resourceValues.contentType {
        return contentType
    }

    guard !url.pathExtension.isEmpty else {
        return nil
    }

    return UTType(filenameExtension: url.pathExtension)
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
    /// File import is unavailable on this platform.
    ///
    /// tvOS and watchOS do not expose the file picker and file drop APIs used by
    /// SwiftUI on iOS, iPadOS, macOS, and visionOS. The unavailable overload
    /// keeps the package surface explicit so unsupported platforms fail with a
    /// clear message instead of a missing-symbol surprise.
    @available(tvOS, unavailable, message: "File import is not available on tvOS.")
    @available(watchOS, unavailable, message: "File import is not available on watchOS.")
    func onFileImport(
        mode: FileImportMode = .automatic,
        allowedContentTypes: [UTType] = [
            .item
        ],
        allowsMultipleSelection: Bool = true,
        isTargeted: Binding<Bool>? = nil,
        perform action: @escaping ([URL]) -> Void
    ) -> some View {
        self
    }

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
