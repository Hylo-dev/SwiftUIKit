import SwiftUI
@testable import SwiftUIKit
@testable import SwiftUIKitDemoSupport
import UniformTypeIdentifiers
import XCTest

final class SwiftUIKitCompileTests: XCTestCase {
    func testConditionalModifiersCompile() {
        let optionalBadge: Int? = 3

        _ = Text("Inbox")
            .if(true) { view in
                view.foregroundStyle(.blue)
            }
            .ifLet(optionalBadge) { view, badge in
                view.badge(badge)
            }
    }

    func testSurfaceAndStrokeModifiersCompile() {
        _ = Text("Hello")
            .padding()
            .surface(
                .blue,
                in: .roundedRect(cornerRadius: 20)
            )
            .stroke(
                .gray,
                width: 2
            )

        _ = Text("Hello")
            .surface(
                .ultraThickMaterial.opacity(0.8),
                in: .roundedRect(cornerRadius: 13),
                shadow: .drop(radius: 8),
                ignoresSafeAreaEdges: .all
            )
            .stroke(
                .gray,
                width: 2,
                dash: .dashed(
                    length: 6,
                    gap: 7
                )
            )

        _ = Text("Hello")
            .surface(in: .roundedRect(cornerRadius: 13)) { shape in
                shape
                    .fill(.ultraThickMaterial)
                    .opacity(0.8)
            }
            .stroke(
                .gray,
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: [
                        6,
                        7
                    ]
                )
            )

        _ = Text("Hello")
            .stroke(
                .gray,
                width: 2,
                in: .capsule
            )
    }

    func testGeometryModifiersCompile() {
        _ = Text("Hello")
            .readSize { size in
                _ = size
            }
            .readFrame(in: .global) { frame in
                _ = frame
            }
    }

    func testFileDropModifiersCompile() {
        #if !os(tvOS) && !os(watchOS)
        _ = Text("Drop")
            .onFileDrop { urls in
                _ = urls
            }

        _ = Text("Drop")
            .onFileDrop { urls, location in
                _ = urls
                _ = location
            }
        #endif
    }

    func testFileImportModifiersCompile() {
        #if !os(tvOS) && !os(watchOS)
        @State var isTargeted = false
        let mode: FileImportMode = .automatic

        _ = Text("Import")
            .onFileImport { urls in
                _ = urls
            }

        _ = Text("Import")
            .onFileImport(
                mode: .pickerOnly,
                allowedContentTypes: [
                    .image
                ],
                allowsMultipleSelection: false,
                isTargeted: $isTargeted
            ) { urls in
                _ = urls
            }

        _ = Text("Import")
            .onFileImport(
                mode: .dropOnly,
                allowedContentTypes: [
                    .pdf
                ],
                isTargeted: $isTargeted
            ) { urls in
                _ = urls
            }

        _ = mode
        #endif
    }

    func testFileImportDemoViewCompiles() {
        #if !os(tvOS) && !os(watchOS)
        _ = SwiftUIKitDemoView()
        _ = FileImportComparisonDemoView()
        _ = SurfaceStrokeComparisonDemoView()
        _ = ConditionalVisibilityComparisonDemoView()
        _ = GeometryComparisonDemoView()
        #endif
    }

    func testVisibilityAndLifecycleModifiersCompile() {
        _ = Text("Hello")
            .hidden(
                true,
                remove: true
            )
            .onFirstAppear {
                _ = "loaded"
            }
    }

    func testTaskSleepDurationCompatCompiles() async throws {
        let duration: TaskSleepDuration = .nanoseconds(1)
        let tolerance: TaskSleepDuration = .nanoseconds(0)

        try await Task.sleep(
            for: duration,
            tolerance: tolerance
        )
    }

    func testTaskSleepDurationScalesToNanoseconds() {
        XCTAssertEqual(
            TaskSleepDuration.nanoseconds(7).nanoseconds,
            7
        )
        XCTAssertEqual(
            TaskSleepDuration.microseconds(7).nanoseconds,
            7_000
        )
        XCTAssertEqual(
            TaskSleepDuration.milliseconds(7).nanoseconds,
            7_000_000
        )
        XCTAssertEqual(
            TaskSleepDuration.seconds(7).nanoseconds,
            7_000_000_000
        )
    }

    func testVersionedModifiersCompile() {
        @State var scrollID: Int?
        @State var changeCount = 0

        _ = Text("Glass")
            .glassEffectIfAvailable()
            .backgroundExtensionEffectIfAvailable()

        _ = ScrollView {
            Text("Row")
                .containerRelativeFrameIfAvailable(.horizontal)
        }
        .scrollBounceBehaviorIfAvailable(.basedOnSize)
        .scrollClipDisabledIfAvailable()
        .scrollIndicatorsFlashIfAvailable(trigger: changeCount)
        .contentMarginsIfAvailable(.horizontal, 12)
        .scrollPositionIfAvailable(id: $scrollID)

        _ = Text("Sheet")
            .presentationCornerRadiusIfAvailable(24)
            .onChangeCompat(
                of: changeCount,
                initial: true
            ) { oldValue, newValue in
                _ = oldValue
                _ = newValue
            }
    }
}
