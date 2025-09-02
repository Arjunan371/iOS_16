//
//  PasteButtonView.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI

struct PasteButtonView: View {
    @State private var username = "@twostraws"

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            PasteButton(payloadType: String.self) { strings in
                guard let first = strings.first else { return }
                username = first
            }
            .buttonBorderShape(.capsule)
        }
        .padding()
    }
}

#Preview {
    PasteButtonView()
}
