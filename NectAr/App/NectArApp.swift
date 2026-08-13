//
//  NectArApp.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

@main
struct NectArApp: App {
    init() {
        SystemRegistration.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            TestLoaderView()
//            ContentView()
        }
    }
}
