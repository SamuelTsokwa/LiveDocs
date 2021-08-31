//
//  ProgressBar.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import SwiftUI


struct ProgressBar: View {
    @Binding var isAnimating: Bool
    let count: UInt
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let scaleRange: ClosedRange<Double>
    let opacityRange: ClosedRange<Double>

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.41)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            ActivityIndicator()
        }
        .opacity(self.isAnimating ? 1 : 0)
        
    }

}

struct ActivityIndicator: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var width : CGFloat = 10
    @State var progress : CGFloat = 10
    @State var capsuleWidth : CGFloat = 180
    var body: some View {
        ZStack {
            Capsule()
            .stroke(Color.gray)
            .frame(width: capsuleWidth, height: 20)
            .overlay(
                VStack (alignment: .leading) {
                    Capsule()
                        .fill(Color.appAccent)
                        .frame(width: self.width, height: 15, alignment: .leading)
                        .padding([.leading, .trailing], 5)
                        .animation(Animation.linear(duration: 0.5))
                }
                .frame(width: capsuleWidth, height: 20, alignment: .leading)
            ).onReceive(timer) { (_) in
                self.width += self.progress
                if self.width >= self.capsuleWidth {
                    self.width = 0
                }
                
            }
            
        }
    }
}


public extension View {
    func loadingView(isAnimating: Binding<Bool>) -> some View {

        return ZStack {
            self
            ProgressBar(isAnimating: isAnimating, count: 4, spacing: 3, cornerRadius: 2, scaleRange: 1...1, opacityRange: 1...1)
        }
    }
}
