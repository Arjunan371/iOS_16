//
//  ShareLink.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI

struct ShareLinkView: View {
    let link = URL(string: "https://www.hackingwithswift.com")!
    var body: some View {
        VStack(spacing: 20) {
            ShareLink(item: link)
//            ShareLink("Learn Swift here", item: link)
//            ShareLink(item: link) {
//                Label("Learn Swift here", systemImage: "swift")
//            }
        }
    }
}

#Preview {
    ShareLinkView()
}
