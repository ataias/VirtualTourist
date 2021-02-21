//
//  TravelLocationsView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import SwiftUI
import MapKit

struct TravelLocationsView: View {

    // MARK: - Input
    @Binding var locations: [TravelLocation]

    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: VirtualTouristModel

    // MARK: - State and Properties
    @AppStorage("coordinateRegion") private var coordinateRegion = CoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389),
        span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
    @State private var selectedPlace: TravelLocation?

    var body: some View {
        ZStack {
            MapView(
                region: $coordinateRegion.region,
                selectedPlace: $selectedPlace,
                locations: $locations
            )
        }
        .sheet(item: $selectedPlace) { place in
            TravelLocationDetail(location: place)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    model.logout()
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
            // TODO use sample array
            TravelLocationsView(locations: .constant(TravelLocation.sampleArray))
                .environmentObject(VirtualTouristModel())
        }
    }
}

