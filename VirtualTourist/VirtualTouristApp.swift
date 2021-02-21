//
//  VirtualTouristApp.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 13/02/21.
//

import SwiftUI
import OAuthSwift
import os

let defaultLog = Logger(subsystem: "br.com.ataias.VirtualTourist", category: "app")

@main
struct VirtualTouristApp: App {
    @StateObject var model = VirtualTouristModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                NavigationLink(
                    destination: TravelLocationsView(),
                    // We intentionally pass a constant binding to avoid the navigation link from changing the authentication setting, which is set up through other actions (login/logout buttons)
                    isActive: .constant(model.isAuthenticated),
                    label: {
                        AuthenticationView(loginAction: model.login, isLoggingIn: model.isLoggingIn)
                    })
                    .disabled(model.isLoggingIn)
            }
            .onOpenURL(perform: { url in
                guard isValid(url: url) else {
                    defaultLog.notice("URL \(url) is invalid. Ignoring. Authentication handler will not be called")
                    return
                }

                OAuthSwift.handle(url: url)
            })
            .add(model: model)
        }
    }

    private func isValid(url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        return components?.scheme == "virtualtourist" && components?.path == "/authenticate"
    }
}
