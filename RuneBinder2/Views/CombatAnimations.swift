//
//  CombatAnimations.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/16/25.
//

import SwiftUI

struct FloatingTextView: View {
    let text: String
    let color: Color
    @State private var opacity = 1.0
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    var body: some View {
        Text(text)
            .font(.custom("CinzelDecorative-Regular", size: 20))
            .fontWeight(.bold)
            .foregroundColor(color)
            .strokeStyle(color: color.darker(by: 0.2), lineWidth: 1)
            .opacity(opacity)
            .offset(x: offsetX, y: offsetY)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offsetY = -screenWidth*0.09
                    offsetX = CGFloat(Float.random(in: -Float(screenWidth)*0.05...Float(screenWidth)*0.05))
                    scale = 1.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeIn(duration: 0.8)) {
                        opacity = 0
                    }
                }
            }
    }
}
extension Color {
    func darker(by amount: Double = 0.01) -> Color {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: Double(max(r - amount, 0)),
                     green: Double(max(g - amount, 0)),
                     blue: Double(max(b - amount, 0)))
    }
}
/*
 * Adapted from https://medium.com/@garejakirit/how-to-create-outlined-text-in-swiftui-253d27877a81
 */


struct StrokeModifier: ViewModifier {
    var strokeSize: CGFloat = 10
    var strokeColor: Color = .white
    func body(content: Content) -> some View {
        content
            .shadow(color: strokeColor, radius: 0, x: strokeSize, y: strokeSize)
            .shadow(color: strokeColor, radius: 0, x: -strokeSize, y: strokeSize)
            .shadow(color: strokeColor, radius: 0, x: strokeSize, y: -strokeSize)
            .shadow(color: strokeColor, radius: 0, x: -strokeSize, y: -strokeSize)
            .shadow(color: strokeColor, radius: 0, x: 0, y: strokeSize)
            .shadow(color: strokeColor, radius: 0, x: -strokeSize, y: 0)
            .shadow(color: strokeColor, radius: 0, x: 0, y: -strokeSize)
            .shadow(color: strokeColor, radius: 0, x: strokeSize, y: -0)

    }
}
extension View {
    func strokeStyle(color: Color, lineWidth: CGFloat) -> some View {
        self.modifier(StrokeModifier(strokeSize: lineWidth, strokeColor: color))
    }
}

import UIKit
import ImageIO

struct AnimatedGIFView: UIViewRepresentable {
    let name: String
    let loopCount: Int // 0 = infinite

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage.gif(name: name, loopCount: loopCount)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}
extension UIImage {
    static func gif(name: String, loopCount: Int = 0) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = NSData(contentsOfFile: path) else {  return nil }
        guard let source = CGImageSourceCreateWithData(data, nil) else {return nil }

        var images: [UIImage] = []
        var duration: Double = 0

        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            let delaySeconds = 0.05
            duration += delaySeconds
            images.append(UIImage(cgImage: cgImage))
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
