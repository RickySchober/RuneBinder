import SwiftUI

struct MapNodeView: View {
    var node: MapNode
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State private var pulse = false
    var body: some View {
        Circle()
            .fill(Color.red) //(for: node.type))
            .frame(width: 40, height: 40)
            .scaleEffect(node.selectable ? (pulse ? 1.3 : 1.0) : 1.0)
            .onAppear {
                if node.selectable {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
            }
            .onTapGesture {
                if node.selectable {
                    viewModel.selectNode(node: node)
                    viewRouter.currentScreen = setScene()
                }
            }
    }
    func setScene() -> GameScreen{
        if(node.type == .shop){
            return GameScreen.shop
        }
        else if(node.type == .event){
            return GameScreen.event
            
        }
        return GameScreen.combat
    }
}


struct MapView: View {
    let map: [[MapNode]]
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        GeometryReader { geometry in
            let layerSpacing = geometry.size.height / CGFloat(map.count + 1)

            ZStack {
                Image("Rune1")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.original)
                    .frame(width: screenWidth, height: screenHeight)
                    .edgesIgnoringSafeArea(.top)
                ForEach(map.flatMap { $0 }, id: \.id) { node in
                    ForEach(node.nextNodes, id: \.id) { target in
                        Path { path in
                            let start = point(for: node, in: geometry.size)
                            let end = point(for: target, in: geometry.size)
                            path.move(to: start)
                            path.addLine(to: end)
                        }
                        .stroke(Color.red.opacity(0.8), lineWidth: 4)
                    }
                }
                

                // Draw nodes
                ForEach(map.flatMap { $0 }, id: \.id) { node in
                    MapNodeView(node: node)
                        .position(point(for: node, in: geometry.size))
                }
            }
        }
    }

    func point(for node: MapNode, in size: CGSize) -> CGPoint {
        let layerCount = map.count
        let nodesInLayer = map[node.layer].count
        let layerSpacing = size.height / CGFloat(layerCount + 1)
        let nodeSpacing = size.width / CGFloat(nodesInLayer + 1)

        let x = nodeSpacing * CGFloat(node.position + 1)
        let y = layerSpacing * CGFloat(node.layer + 1)
        return CGPoint(x: x, y: y)
    }
}
