//
//  TravelLocationDetail.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 19/02/21.
//

import SwiftUI

struct TravelLocationDetail: View {
    let location: TravelLocation

    @State private var images: [UIImage] = []

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: VirtualTouristModel

    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        VStack(spacing: 10) {
            Text("Hello, World!")
            Button("Get Photos") {
                getPhotos()
            }
            Button("Remove Location") {
                model.travelLocationModel.delete(location: location)
                self.presentationMode.wrappedValue.dismiss()
            }
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) {
                        Image(uiImage: $0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }.font(.largeTitle)
            }
        }
        .onAppear {
            if images.count == 0 {
                getPhotos()
            }
        }
    }

    func getPhotos() {
        model.photos(for: location) {
            self.images.append($0)
        }
    }
}

struct TravelLocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        TravelLocationDetail(location: TravelLocation.sample)
            .add(model: VirtualTouristModel())
    }
}
