//
//  AuthenticationView.swift
//  Shared
//
//  Created by Ataias Pereira Reis on 03/01/21.
//

import SwiftUI
import Foundation
import Combine

struct AuthenticationView: View {
    let loginAction: () -> Void
    let isLoggingIn: Bool

    var body: some View {
            ZStack {
                Color("Mint Cream")
                    .ignoresSafeArea()
                VStack {
                    Image("travel")
                        .resizable()
                        .frame(width: 120, height: 120, alignment: .center)
                        .padding(.bottom)

                    StyledButton(text: "Login", action: loginAction)
                        .padding(.bottom)
                    ProgressView()
                        .hidden(if: !isLoggingIn)

                }
                .padding()
            }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AuthenticationView(loginAction: {}, isLoggingIn: true)
            }
            NavigationView {
                AuthenticationView(loginAction: {}, isLoggingIn: false)
            }
        }
    }
}
