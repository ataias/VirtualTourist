//
//  View+Extensions.swift
//  OnTheMap
//
//  Created by Ataias Pereira Reis on 31/01/21.
//

import SwiftUI
import CoreHaptics

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

struct VirtualTouristModelModifier: ViewModifier {
    var model: VirtualTouristModel

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .environmentObject(model)
            .environment(\.managedObjectContext, Persistency.persistentContainer.viewContext)
    }
}

extension View {
    func add(model: VirtualTouristModel) -> some View {
        self.modifier(VirtualTouristModelModifier(model: model))
    }
}

// MARK: - Haptics
extension View {
    /// Generates simple success haptic feedback
    func simpleHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
