//
//  TravelLocationDetail.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 19/02/21.
//

import SwiftUI
import MapKit

struct TravelLocationDetail: View {
    let location: TravelLocation

    @State private var images: [UIImage] = []
    @State private var isReloading = false

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: VirtualTouristModel

    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 2)

    private var animation: Animation {
        Animation.easeInOut
    }

    var body: some View {
        VStack(spacing: 10) {
            ScrollView {
                Map(coordinateRegion: .constant(location.coordinateRegion),
                    annotationItems: [location],
                    annotationContent: mapAnnotation(location:)
                )
                .overlay(VStack {
                    Button(action: {
                        getPhotos()
                        withAnimation {
                            isReloading = true
                        }
                        defaultLog.debug("isReloading: set")

                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .rotationEffect(Angle.degrees(isReloading ? 360 : 0))
                    }

                }
                .background(Color.white.opacity(0.9).blur(radius: 3.0))
                .padding(), alignment: .topTrailing)
                .frame(height: 200)
                Text("Hello, World!")
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
        .navigationTitle("Travel Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {



            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") {
                    model.travelLocationModel.delete(location: location)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    func getPhotos() {
        model.photos(for: location) {
            if let image = $0 {
                self.images.append(image)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isReloading = false
                }
                defaultLog.debug("isReloading: unset")
            }


        }
    }

    func mapAnnotation(location: TravelLocation) -> MapPin {
        MapPin(coordinate: location.coordinate)
    }
}

struct TravelLocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TravelLocationDetail(location: TravelLocation.sample)
                .add(model: VirtualTouristModel())
        }
    }
}
