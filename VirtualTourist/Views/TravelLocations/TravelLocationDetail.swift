//
//  TravelLocationDetail.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 19/02/21.
//

import SwiftUI

struct TravelLocationDetail: View {
    let location: TravelLocation
    let deleteLocation: () -> Void

    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Remove") {
                deleteLocation()
            }
        }
    }
}

struct TravelLocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        TravelLocationDetail(location: TravelLocation.sample, deleteLocation: {})
    }
}
