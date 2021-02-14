//
//  OnTheMapPinView.swift
//  OnTheMap
//
//  Created by Ataias Pereira Reis on 30/01/21.
//

import SwiftUI

struct OnTheMapPinView: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "mappin")
                .font(.title)
                .foregroundColor(.green)
        }
    }
}

struct OnTheMapPinView_Previews: PreviewProvider {
    static var previews: some View {
        OnTheMapPinView(action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
