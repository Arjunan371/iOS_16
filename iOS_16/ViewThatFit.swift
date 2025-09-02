//
//  Tooltip.swift
//  iOS_16
//
//  Created by Arjunan on 18/08/25.
//

import SwiftUI

struct ViewThatFit: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
            bodyView
        }
    }
    
    var bodyView: some View {
        HStack {
            ForEach(0...20, id: \.self) { ind in
                ViewThatFits {
                    HStack { Text("Horizontal \(ind)") }
                    VStack { Text("Horizontal \(ind)") }
                }
                .padding(12)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .padding(8)
            }
        }
    }
}

#Preview {
    ViewThatFit()
}


struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }

        let proposedWidth = proposal.width ?? .infinity
        var maxRowWidth = CGFloat.zero
        var rowCount = CGFloat.zero
        var x = CGFloat.zero
        for subSize in subSizes {
            // This prevents empty rows if any subviews are wider than proposedWidth.
            let lineBreakAllowed = x > 0

            if lineBreakAllowed, x + subSize.width > proposedWidth {
                rowCount += 1
                x = 0
            }

            x += subSize.width
            maxRowWidth = max(maxRowWidth, x)
        }

        if x > 0 {
            rowCount += 1
        }

        let rowHeight = subSizes.lazy.map { $0.height }.max() ?? 0
        return CGSize(
            width: proposal.width ?? maxRowWidth,
            height: rowCount * rowHeight
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }
        let rowHeight = subSizes.lazy.map { $0.height }.max() ?? 0
        let proposedWidth = proposal.width ?? .infinity

        var p = CGPoint.zero
        for (subview, subSize) in zip(subviews, subSizes) {
            // This prevents empty rows if any subviews are wider than proposedWidth.
            let lineBreakAllowed = p.x > 0

            if lineBreakAllowed, p.x + subSize.width > proposedWidth {
                p.x = 0
                p.y += rowHeight
            }

            subview.place(
                at: CGPoint(
                    x: bounds.origin.x + p.x,
                    y: bounds.origin.y + p.y + 0.5 * (rowHeight - subSize.height)
                ),
                proposal: proposal
            )

            p.x += subSize.width
        }
    }
}
