//
//  MultiDatePicker.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI

struct MultiDatePickerView: View {
    @Environment(\.calendar) var calendar
    @State var dates: Set<DateComponents> = []
    
    var body: some View {
        VStack {
            MultiDatePicker("Select your preferred dates", selection: $dates, in: Date.now...)
            Text(summary)
        }
        .padding()
    }
    
    var summary: String {
        dates.compactMap { components in
            calendar.date(from: components)?.formatted(date: .long, time: .omitted)
        }.formatted()
    }
}

#Preview {
    MultiDatePickerView()
}
