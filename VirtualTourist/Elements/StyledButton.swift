//
//  StyledButton.swift
//  OnTheMap
//
//  Created by Ataias Pereira Reis on 02/02/21.
//

import SwiftUI

struct StyledButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack {
                Spacer()
                Text(text.uppercased())
                    .foregroundColor(.white)
                    .bold()
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15.0)
            )
        })
    }
}

struct StyledButton_Previews: PreviewProvider {
    static var previews: some View {
        StyledButton(text: "Press Me", action: {})
    }
}
