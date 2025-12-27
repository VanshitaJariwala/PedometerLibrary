//
//  KonfettiView.swift
//  NewPedometer
//
//  Created by Vanshita Jariwala on 20/12/25.
//

import SwiftUI
import ConfettiSwiftUI

struct KonfettiView: View {
    @Binding var counter: Int
    var colors: [Color]
    var num: Int = 50
    var confettiSize: CGFloat = 10.0
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 0, height: 0)
            .confettiCannon(
                trigger: $counter,
                num: num,
                colors: colors,
                confettiSize: confettiSize
            )
    }
}

