//
//  EnvironmentValues+.swift
//  CameraApp
//
//  Created by Serhii Palash on 15/08/2022.
//

import SwiftUI

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}
