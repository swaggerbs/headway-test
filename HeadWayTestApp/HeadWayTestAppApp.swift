//
//  HeadWayTestAppApp.swift
//  HeadWayTestApp
//

import SwiftUI
import ComposableArchitecture

@main
struct HeadWayTestAppApp: App {
    var body: some Scene {
        WindowGroup {
            BookListeningView(
                store: Store(initialState: BookListeningFeature.State(book: BookModel.testBookModel)) {
                    BookListeningFeature()
                }
            )
        }
    }
}
