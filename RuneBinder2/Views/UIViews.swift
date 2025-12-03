//
//  UIViews.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/28/25.
//
/* Custom Fonts:
 * IM_FELL_English_SC
 * IM_FELL_English_Roman
 * MedievalSharp
 * PirataOne-Regular
 */

import SwiftUI

struct RuneBinderButtonStyle: ViewModifier {
    var cornerColor: Color = Color(red: 0.5, green: 0.35, blue: 0.2)
    var backgroundColor: Color = Color(red: 0.96, green: 0.9, blue: 0.75)
    var borderColor: Color = Color(red: 0.4, green: 0.25, blue: 0.1)
    var inActive: Bool = false
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .font(.custom("IM_FELL_English_Roman", size: 20))
            .foregroundColor(cornerColor)
            .opacity(inActive ? 0.4 : 1.0)
            .background(
                ZStack {
                    Rectangle()
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                    Rectangle()
                        .stroke(borderColor, lineWidth: 6)
                        .overlay(
                            VStack {
                                HStack {
                                    cornerDecoration()
                                    Spacer()
                                    cornerDecoration()
                                        .rotationEffect(.degrees(90))
                                }
                                Spacer()
                                HStack {
                                    cornerDecoration()
                                        .rotationEffect(.degrees(270))
                                    Spacer()
                                    cornerDecoration()
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            .padding(6)
                        )
                    Rectangle()
                        .stroke(cornerColor, lineWidth: 4)
                    Rectangle()
                        .stroke(backgroundColor, lineWidth: 2)
                }
            )
    }
    
    // Helper corner decoration (pixel-style corner)
    private func cornerDecoration() -> some View {
        VStack(spacing: 1) {
            Rectangle()
                .fill(cornerColor)
                .frame(width: 4, height: 2)
            Rectangle()
                .fill(cornerColor)
                .frame(width: 2, height: 4)
        }
    }
}

extension View {
    func runeBinderButtonStyle(inActive: Bool = false) -> some View {
        self.modifier(RuneBinderButtonStyle(inActive: inActive))
    }
}

// Must define as a shape to conform to VectorArithmetic allowing proper animation
struct TrapezoidEdge: Shape {
    enum Edge {
        case top, bottom, left, right
    }
    
    var edge: Edge
    var depth: CGFloat
    
    var animatableData: CGFloat { //Define variable to be interpolated for animation
        get { depth }
        set { depth = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch edge {
        case .top:
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width - depth, y: depth))
            path.addLine(to: CGPoint(x: depth, y: depth))
        case .bottom:
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width - depth, y: rect.height - depth))
            path.addLine(to: CGPoint(x: depth, y: rect.height - depth))
        case .left:
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: depth, y: rect.height - depth))
            path.addLine(to: CGPoint(x: depth, y: depth))
        case .right:
            path.move(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width - depth, y: rect.height - depth))
            path.addLine(to: CGPoint(x: rect.width - depth, y: depth))
        }
        path.closeSubpath()
        return path
    }
}


struct ToolTipStyle: ViewModifier {
    var baseColor: Color = Color(hue: 0, saturation: 0, brightness: 0.18)
    var shadowDepth: CGFloat = 5
    func body(content: Content) -> some View {
        let depth = shadowDepth
        content
            .font(.custom("IM_FELL_English_Roman", size: 0.05*screenWidth))
            .foregroundColor(.white)
            .padding(depth*1.5)
            .background(
                
                ZStack {
                    baseColor
                    TrapezoidEdge(edge: .top, depth: depth)
                        .fill(Color.white.opacity(0.5))
                    TrapezoidEdge(edge: .left, depth: depth)
                        .fill(Color.white.opacity(0.4))
                    TrapezoidEdge(edge: .right, depth: depth)
                        .fill(Color.white.opacity(0.2))
                    TrapezoidEdge(edge: .bottom, depth: depth)
                        .fill(Color.white.opacity(0.3))
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        .padding(depth)
                        .shadow(radius: 3)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            )
    }
}
extension View {
    func tooltipStyle(
        baseColor: Color = Color(hue: 0, saturation: 0, brightness: 0.27),
        shadowDepth: CGFloat = 5
    ) -> some View {
        self.modifier(ToolTipStyle(baseColor: baseColor, shadowDepth: shadowDepth))
    }
}

struct RuneTileStyle: ViewModifier {
    var baseColor: Color = Color(red: 0.95, green: 0.90, blue: 0.70)
    var shadowDepth: CGFloat = 0.05
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    let depth = min(geo.size.width, geo.size.height) * shadowDepth
                    ZStack {
                        baseColor
                        TrapezoidEdge(edge: .top, depth: depth)
                            .fill(Color.white.opacity(0.4))
                        TrapezoidEdge(edge: .left, depth: depth)
                            .fill(Color.black.opacity(0.2))
                        TrapezoidEdge(edge: .right, depth: depth)
                            .fill(Color.black.opacity(0.2))
                        TrapezoidEdge(edge: .bottom, depth: depth)
                            .fill(Color.black.opacity(0.5))
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            .padding(depth*2/3)
                    }
                })
    }
}
extension View {
    func runeTileStyle(
        baseColor: Color = Color(red: 0.95, green: 0.90, blue: 0.70),
        lightEdge: Color = Color.white.opacity(0.8),
        darkEdge: Color = Color.black.opacity(0.35),
        shadowDepth: CGFloat = 0.1
    ) -> some View {
        self.modifier(RuneTileStyle(baseColor: baseColor, shadowDepth: shadowDepth))
    }
}

struct ImageBorderView<Content: View>: View {
    let content: Content
    let cornerImage: String
    let edgeVert: String
    let edgeHori: String
    let cornerSize: CGFloat
    let edgeThickness: CGFloat

    init(
        cornerImage: String,
        edgeVert: String,
        edgeHori: String,
        cornerSize: CGFloat = 24,
        edgeThickness: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerImage = cornerImage
        self.edgeHori = edgeHori
        self.edgeVert = edgeVert
        self.cornerSize = cornerSize
        self.edgeThickness = edgeThickness
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Content centered inside
            content
                .padding(edgeThickness + (cornerSize-edgeThickness)/2)
                .background(Color(red: 0.89, green: 0.66, blue: 0.43))
                .overlay(
            GeometryReader { geo in
                ZStack {
                    // Top & Bottom edges
                    VStack {
                        Image(edgeHori)
                            .resizable(resizingMode: .stretch)
                            .frame(height: edgeThickness)
                            .padding(.top, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                        Spacer()
                        Image(edgeHori)
                            .resizable(capInsets: EdgeInsets(.zero), resizingMode: .stretch)
                            .frame(height: edgeThickness)
                            .padding(.bottom, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(1.0), radius: edgeThickness/2)
                    }

                    // Left & Right edges
                    HStack {
                        Image(edgeVert)
                            .resizable(resizingMode: .stretch)
                            .frame(width: edgeThickness)
                            .padding(.leading, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                        Spacer()
                        Image(edgeVert)
                            .resizable(resizingMode: .stretch)
                            .rotationEffect(.degrees(180))
                            .frame(width: edgeThickness)
                            .padding(.trailing, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                    }

                    // --- Corners ---
                    VStack {
                        HStack {
                            Image(cornerImage)
                                .resizable()
                                .frame(width: cornerSize, height: cornerSize)
                            Spacer()
                            Image(cornerImage)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: cornerSize, height: cornerSize)
                        }
                        Spacer()
                        HStack {
                            Image(cornerImage)
                                .resizable()
                                .frame(width: cornerSize, height: cornerSize)
                            Spacer()
                            Image(cornerImage)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: cornerSize, height: cornerSize)
                        }
                    }
                }
            }
            )
        }
    }
}

// Source - https://stackoverflow.com/questions/56573373/how-to-get-size-of-child/79233275#79233275
// Posted by Benzy Neez
// Retrieved 2025-11-05, License - CC BY-SA 4.0

struct SizeReader: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self, of: \.size) { newVal in
                if size != newVal {
                    DispatchQueue.main.async {
                        size = newVal
                    }
                }
            }
    }
}
extension View {
    func sizeReader(size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
    }
}
