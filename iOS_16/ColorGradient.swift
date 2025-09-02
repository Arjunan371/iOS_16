//
//  ColorGradient.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI

struct ColorGradientView: View {
    let colors: [Color] = [.blue, .cyan, .green, .yellow, .orange, .red, .purple]

    var body: some View {
        VStack {
            ForEach(colors, id: \.self) { color in
                HStack {
                    Circle()
                        .fill(.red.shadow(.drop(color: .black, radius: 1)))
                        .padding()
                    Circle()
                        .fill(.red.shadow(.inner(color: .black, radius: 1)))
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ColorGradientView()
}
