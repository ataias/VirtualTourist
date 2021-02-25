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

    private var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: location.coordinate,
            span:
                MKCoordinateSpan(
                    latitudeDelta: 10,
                    longitudeDelta: 15
                )
        )
    }

    private var animation: Animation {
        Animation.linear(duration: 3.0)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        VStack(spacing: 10) {
            ScrollView {
                Map(coordinateRegion: .constant(coordinateRegion),
                    annotationItems: [location],
                    annotationContent: mapAnnotation(location:)
                )
                .frame(height: 200)
                .disabled(true)
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
                Button(action: {
                    getPhotos()
                    withAnimation {
                        isReloading = true
                    }
                    defaultLog.debug("isReloading: set")
                    
                }) {
                    // TODO find out why animations don't work here...
                    // For whatever reason if you add something other than "Image" you can see the rotation effect take place and also the background color
                    // TODO I think I need to make that button become "Update" without animation and then I put the animation outside the toolbar items
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("")
                    }
                    .background(Color.green)
//                    .rotationEffect(Angle.degrees(60))
                    .rotationEffect(Angle.degrees(isReloading ? 360 : 0))
                    .animation(animation)
//                    Text("Update")

                }


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
            self.images.append($0)
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
