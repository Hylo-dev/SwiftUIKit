import SwiftUI
import SwiftUIKit
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
                .ultraThickMaterial,
                in: .roundedRect(cornerRadius: 13),
                opacity: 0.8,
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
}
