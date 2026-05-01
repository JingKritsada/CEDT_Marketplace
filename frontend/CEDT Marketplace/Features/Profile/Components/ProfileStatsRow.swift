//
//  statsRow.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI
import Foundation

struct ProfileStatsRow: View {
    var body: some View {
        HStack {
            statItem(value: "12", label: "ITEMS SOLD")
            Divider().frame(height: 30).padding(.horizontal, 20)
            statItem(value: "4.9", label: "RATING")
            Divider().frame(height: 30).padding(.horizontal, 20)
            statItem(value: "24", label: "FOLLOWERS")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}
