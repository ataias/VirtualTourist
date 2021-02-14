//
//  VirtualTouristApp.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 13/02/21.
//

import SwiftUI

@main
struct VirtualTouristApp: App {
    @StateObject var model = VirtualTouristModel()
    @State private var isLoggingIn = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                NavigationLink(
                    destination:
                        Text("Logged In!")
                    ,
                    // We intentionally pass a constant binding to avoid the navigation link from changing the authentication setting, which is set up through other actions (login/logout buttons)
                    isActive: .constant(model.isAuthenticated),
                    label: {
                        AuthenticationView(loginAction: {}, isLoggingIn: isLoggingIn)
                    })
                    .disabled(isLoggingIn)
            }
        }
    }
}
