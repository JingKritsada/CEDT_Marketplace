//
//  studentStatusBanner.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI
import Foundation

struct StudentStatusBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("STUDENT STATUS").font(.caption2).bold().foregroundColor(.blue.opacity(0.6))
                Text("Verified Engineering Member").font(.subheadline).bold().foregroundColor(.blue)
            }
            Spacer()
            Image(systemName: "academiccap.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue.opacity(0.2))
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
