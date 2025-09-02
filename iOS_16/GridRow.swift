//
//  GridRow.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    var body: some View {
        Grid(horizontalSpacing:0, verticalSpacing: 0) {
            ForEach(0..<8) { row in
                GridRow {
                    ForEach(0..<8) { col in
                        if (row + col).isMultiple(of: 2) {
                            Rectangle()
                                .fill(.black)
                        } else {
                            Rectangle()
                                .fill(.white)
                        }
                    }
                }
                .onTapGesture { location in
                        print("Tapped at \(location)")
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .border(.black, width: 1)
        .padding()
        .task {
            var local: Bool? = true
            var global: Bool = false
            if local == nil || local == false || !global {
                print("valid")
            }
//            let x = IntegerRef(10)
//            let example = Example(id: .init(x))
//            print("example====>", example)
//            let y = x
//
//            print(ObjectIdentifier(x) == ObjectIdentifier(y))
//            // Prints "true"
//            print(x === y)
//            // Prints "true"
//
//            let z = IntegerRef(10)
//            print(ObjectIdentifier(x) == ObjectIdentifier(z))
//            // Prints "false"
//            print(x === z)
            // Prints "false"
        }
    }
}

#Preview {
    ContentView()
}

     class IntegerRef {
         let value: Int
         init(_ value: Int) {
             self.value = value
         }
     }
///


struct Example: Identifiable {
    var id: ObjectIdentifier
}

