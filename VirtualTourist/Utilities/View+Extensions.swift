//
//  View+Extensions.swift
//  OnTheMap
//
//  Created by Ataias Pereira Reis on 31/01/21.
//

import SwiftUI

struct ConditionalHide: ViewModifier {
    var hidden: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if hidden {
            content.hidden()
        } else {
            content
        }
    }
}

extension View {
    func hidden(if hidden: Bool) -> some View {
        self.modifier(ConditionalHide(hidden: hidden))
    }
}

