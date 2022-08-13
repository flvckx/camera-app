//
//  FirstView.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct FirstView: View {
    @FocusState private var userIdIsFocused: Bool

    @State private var userId = ""
    @State private var isShowingCameraView = false

    var inputIsInvalid: Bool {
        return userId.isEmpty || Int(userId) == nil
    }

    var body: some View {
        ZStack {
            Color(.white)
                .onTapGesture {
                    userIdIsFocused = false
                }

            VStack {
                TextField("User ID", text: $userId)
                .frame(width: 200, height: 40)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($userIdIsFocused)

                Button {
                    userIdIsFocused = false
                    isShowingCameraView = true
                } label: {
                    NavigationLink(
                        destination: CameraView(),
                        isActive: $isShowingCameraView
                    ) { Text("Enter") }
                        .frame(width: 250, height: 40)
                }
                .border(.black, width: 1)
                .disabled(inputIsInvalid)
                .padding(.top, 50)
            }
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
