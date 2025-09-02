//
//  RequestReviewView.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import StoreKit
import SwiftUI

struct requestReviewView: View {
    @Environment(\.requestReview) var requestReview

    var body: some View {
        Button("Review the app") {
            requestReview()
        }
    }
}

#Preview {
    requestReviewView()
}
