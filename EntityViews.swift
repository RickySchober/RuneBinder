import SwiftUI

struct DebuffGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var entity: Entity
    @State var scale: Double = 1.0
    var body: some View{
        ZStack{
            ForEach(entity.debuffs.indices, id: \.self) { index in
                let debuff = entity.debuffs[index]
                GeometryReader { geometry in
                    let size = geometry.size
                    ZStack(alignment: .topLeading) {
                        Image(debuff.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                            .echoEffect(
                                trigger: debuff.value,
                                            scale: 3.0,
                                            opacity: 0.4,
                                            duration: 0.8,
                                            repeats: 3
                                        )
                        Text("\(debuff.value)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .position(x: 0.8 * size.width, y: 0.8 * size.height)
                            .font(.system(size: 0.2 * min(size.width, size.height)))
                           // .scaleEffect(scale)
                    }
                }
                /*.onChange(of: debuff.value){ newValue in
                    withAnimation(.easeOut(duration: 0.25)) {
                        scale = 2.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation(.easeIn(duration: 0.25)) {
                            scale = 1.0
                        }
                    }

                }*/
                .frame(width: screenWidth * 0.04, height: screenWidth * 0.04)
                .offset(x: CGFloat(index % 4) * screenWidth * 0.04 - screenWidth*0.05,
                        y: CGFloat(index / 4) * screenWidth * 0.04)
            }
        }
        .padding(1)
    }
}
struct StatusApplied: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var entity: Entity
    @State var prevWard: Int = 0
    init(entity: Entity){
        self.entity = entity
        prevWard = entity.ward
    }
    var body: some View{
        ForEach(entity.debuffs){ debuff in
            Image(debuff.image)
                .resizable()
                .scaledToFit()
                .opacity(0.5)
                .echoEffect(scale: 2.0, opacity: 0.4, duration: 0.8, repeats: 3)
                .autoDisappear(after: 1.6)
        }
        ForEach(entity.buffs){ buff in
            Image(buff.image)
                .resizable()
                .scaledToFit()
                .opacity(0.5)
                .echoEffect(scale: 2.0, opacity: 0.4, duration: 0.8, repeats: 3)
                .autoDisappear(after: 1.6)
        }
        .onChange(of: entity.ward){ newValue in
            if(newValue > prevWard){
                Image("ward")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
                    .echoEffect(scale: 2.0, opacity: 0.4, duration: 0.8, repeats: 3)
                    .autoDisappear(after: 1.6)
            }
            print("\(prevWard) new ward: \(newValue)")
            prevWard = newValue
        }
    }
}
struct HealthBar: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var entity: Entity
    var healthRatio: CGFloat {
        CGFloat(entity.currentHealth) / CGFloat(entity.maxHealth)
    }
    var wardRatio: CGFloat {
        min(CGFloat(entity.ward) / CGFloat(entity.maxHealth), 1.0)
    }
    var body: some View{
        if(entity.ward>0){
            ZStack(alignment: .leading) { //Block bar
                Rectangle()
                    .frame(width: screenWidth*0.13, height: screenHeight*0.0075)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(3)
                Rectangle()
                    .frame(width: screenWidth*0.13*min(1 ,wardRatio), height: screenHeight*0.0075) // 50 is total width
                    .foregroundColor(.blue)
                    .cornerRadius(3)
                
                Text("\(entity.ward)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(width: screenWidth*0.13, height: screenHeight*0.02)
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
            }
            .animation(.linear(duration: 0.5), value: wardRatio)
            .padding(0)
        }
        ZStack(alignment: .leading) { //HP bar
            Rectangle()
                .frame(width: screenWidth*0.13, height: screenHeight*0.0075)
                .foregroundColor(.gray.opacity(0.3))
                .cornerRadius(3)
            Rectangle()
                .frame(width: max(0, screenWidth*0.13*healthRatio), height: screenHeight*0.0075) // 50 is total width
                .foregroundColor(.red)
                .cornerRadius(3)
            Text("\(entity.currentHealth)/\(entity.maxHealth)")
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: screenWidth*0.13, height: screenHeight*0.02)
                .minimumScaleFactor(0.5)
                .lineLimit(nil)
        }
        .padding(0)
        .animation(.linear(duration: 0.5), value: healthRatio)
    }
}

struct EchoEffect: ViewModifier {
    var maxScale: CGFloat = 2.0
    var maxOpacity: CGFloat = 0.7
    var duration: Double = 0.5
    var repeats: Int = 1
    var appearTrigger: Bool = true

    var trigger: Int //Variable that triggers animation
    @State private var animate = false
    @State var scales: [CGFloat] = []
    @State var opacities: [CGFloat] = []
    func body(content: Content) -> some View {
        ZStack {
            content
            if animate {
                ForEach(0..<repeats, id: \.self) { i in
                    content
                        .opacity(opacities[i])
                        .scaleEffect(scales[i])
                }
            }
        }
        .onChange(of: trigger) { newValue in
            Task{ await startAnimation() }
        }
        .onAppear {
            if(appearTrigger){
                Task{ await startAnimation() }
            }
        }
    }

    private func startAnimation() async {
        await MainActor.run { // Set initial values of state arrays
            scales = Array(repeating: 1.0, count: repeats)
            opacities = Array(repeating: maxOpacity, count: repeats)
        }
        guard !animate else { return } // prevent concurrent triggers
        animate = true
        
        for i in 0..<repeats {
            await MainActor.run {
                withAnimation(.linear(duration: duration)) {
                    scales[i] = maxScale
                }
                withAnimation(.easeIn(duration: duration*1.5)) {
                    opacities[i] = 0.0
                }
            }
            try? await Task.sleep(nanoseconds: UInt64(duration/2 * 1_000_000_000))
        }
        // Wait for animation to stop before removing
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        await MainActor.run {
            animate = false
        }
    }
}

extension View {
    func echoEffect(
        trigger: Int = 0,
        appearTrigger: Bool = true,
        scale: CGFloat = 2.0,
        opacity: CGFloat = 0.7,
        duration: Double = 0.5,
        repeats: Int = 1
    ) -> some View {
        self.modifier(EchoEffect(
            maxScale: scale,
            maxOpacity: opacity,
            duration: duration,
            repeats: repeats,
            appearTrigger: appearTrigger,
            trigger: trigger
        ))
    }
}

struct AutoDisappearModifier: ViewModifier {
    var delay: Double = 1.0
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isVisible = false
                    }
                }
            }
    }
}

extension View {
    func autoDisappear(after delay: Double = 1.0) -> some View {
        self.modifier(AutoDisappearModifier(delay: delay))
    }
}
