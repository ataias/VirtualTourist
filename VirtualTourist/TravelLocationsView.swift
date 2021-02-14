//
//  TravelLocationsView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import SwiftUI

struct TravelLocationsView: View {

    let logout: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Text("Hello, World!")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.logout()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                        Text("Logout")
                    }
                }
            }
    }
}

struct TravelLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TravelLocationsView(logout: {})
        }
    }
}
