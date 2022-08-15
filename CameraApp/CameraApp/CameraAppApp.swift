//
//  CameraAppApp.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

@main
struct CameraAppApp: App {
    @State private var isActive : Bool = false
    var body: some Scene {
        WindowGroup {
            NavigationView {
                FirstView()
            }
            .environment(\.rootPresentationMode, $isActive)
        }
    }
}
