//
//  TravelLocationDetail.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 19/02/21.
//

import SwiftUI

struct TravelLocationDetail: View {
    let location: TravelLocation

    @State private var images: [UIImage]?

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: VirtualTouristModel

    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Remove") {
                model.delete(location: location)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            if images == nil {
                model.photos(for: location) {
                    self.images = $0
                }
            }
        }
    }
}

struct TravelLocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        TravelLocationDetail(location: TravelLocation.sample)
            .environmentObject(VirtualTouristModel())
    }
}
