//
//  RotatedView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 25/02/21.
//

import SwiftUI

struct RotatedView: View {
    @State private var isReloading = false
    var body: some View {
        Button(action: {
            withAnimation {
                isReloading = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isReloading = false
                }
            }

        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100, alignment: .center)
                .rotationEffect(.degrees(isReloading ? 360 : 0))
        }
    }
}

struct RotatedView_Previews: PreviewProvider {
    static var previews: some View {
        RotatedView()
    }
}
