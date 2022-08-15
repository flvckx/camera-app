//
//  RootPresentationMode.swift
//  CameraApp
//
//  Created by Serhii Palash on 15/08/2022.
//

import SwiftUI

typealias RootPresentationMode = Bool

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension RootPresentationMode {

    public mutating func dismiss() {
        self.toggle()
    }
}
