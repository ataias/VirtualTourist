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

    @State private var images: [(Flickr.Photo, UIImage?)] = []
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
                .disabled(true)
                .overlay(locationControls, alignment: .topTrailing)
                .frame(height: 200)

                if isReloading {
                    VStack {
                        ProgressView()
                    }
                    .padding()
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(images, id: \.0) { (photo, uiImage) in
                            if let uiImage = uiImage {
                                NavigationLink(
                                    destination: ImageDetail(photo: photo, uiImage: uiImage, delete: {
                                        deletePhoto(photo: photo)
                                    }),
                                    label: {
                                        ImageView(uiImage: uiImage)
                                            .onTapGesture(count: 2, perform: {
                                                withAnimation {
                                                    deletePhoto(photo: photo)
                                                }
                                            })
                                    })
                            } else {
                                ProgressView()
                                    .frame(width: 200, height: 200)
                                    .background(Color.yellow)
                            }
                        }
                    }.font(.largeTitle)
                }
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
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Label("Back", systemImage: "chevron.left")
                }
            }
        }
    }

    @ViewBuilder
    var locationControls: some View {
        VStack(spacing: 10) {
            reloadControl
            deleteControl
        }
        .padding()
        .background(Color.white.opacity(0.9).blur(radius: 3.0))
    }

    @ViewBuilder
    var reloadControl: some View {
        Button(action: {
            downloadNewPhotos()
            withAnimation {
                isReloading = true
            }
            defaultLog.debug("isReloading: set")

        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(Angle.degrees(isReloading ? 360 : 0))
        }
    }

    @ViewBuilder
    var deleteControl: some View {
        Button(action: {
            model.travelLocationModel.delete(location: location)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "trash")
        }
    }

    func deletePhoto(photo: Flickr.Photo) {
        model.travelLocationModel.delete(photo: photo, from: location)
        images.removeAll { $0.0.id == photo.id }
    }

    func getPhotos() {
        model.getPhotos(for: location, onPhotoUpdate: process(updates:))
    }

    func downloadNewPhotos() {
        self.images = []
        model.downloadPhotos(for: location) {
            process(updates: $0)
            withAnimation {
                isReloading = false
            }
        }
    }

    func process(updates: [Flickr.PhotoUpdate]) {
        for update in updates {
            switch update {
            case .downloading(let photo):
                self.images.append((photo, nil))
            case .downloaded(let photo, let image):
                let index = self.images.firstIndex(where: { $0.0.id == photo.id })!
                self.images[index] = (photo, image)
            case .full(let photo, let image):
                self.images.append((photo, image))
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
