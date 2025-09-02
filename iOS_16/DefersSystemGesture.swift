
//
//  DefersSystemGesture.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI

struct DefersSystemView: View {
    @State private var input = 0.0

    var body: some View {
        Text("Current value: \(input)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture().onChanged { value in
                    input = value.location.y - value.startLocation.y
                }
            )
            .defersSystemGestures(on: .vertical)
    }
}

#Preview {
    DefersSystemView()
}
