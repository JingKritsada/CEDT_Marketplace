//
//  RangeSlider.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.pink)
                    .frame(width: CGFloat((maxPrice - minPrice) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 6)
                    .offset(x: CGFloat((minPrice - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width)

                thumbView
                    .offset(x: CGFloat((minPrice - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 14)
                    .gesture(DragGesture().onChanged { value in
                        let rawValue = Double(value.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        
                        let steppedValue = (rawValue / step).rounded() * step
                        
                        minPrice = min(max(steppedValue, range.lowerBound), maxPrice - step)
                    })

                thumbView
                    .offset(x: CGFloat((maxPrice - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 14)
                    .gesture(DragGesture().onChanged { value in
                        let rawValue = Double(value.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        
                        let steppedValue = (rawValue / step).rounded() * step
                        
                        maxPrice = max(min(steppedValue, range.upperBound), minPrice + step)
                    })
            }
        }
        .frame(height: 30)
    }

    private var thumbView: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 28, height: 28)
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            .overlay(Circle().stroke(Color.pink, lineWidth: 3))
    }
}
