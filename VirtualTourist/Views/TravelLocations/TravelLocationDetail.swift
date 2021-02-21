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
        VStack(spacing: 10) {
            Text("Hello, World!")
            Button("Get Photos") {
                getPhotos()
            }
            Button("Remove Location") {
                model.locations.delete(location: location)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            if images == nil {
                getPhotos()
            }
        }
    }

    func getPhotos() {
        model.photos(for: location) {
            self.images = $0
        }
    }
}

struct TravelLocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        TravelLocationDetail(location: TravelLocation.sample)
            .add(model: VirtualTouristModel())
    }
}
