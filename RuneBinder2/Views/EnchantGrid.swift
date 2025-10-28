import SwiftUI

struct EnchantmentGridView: View {
    let enchantments: [Enchantment]
        let onTap: (Enchantment) -> Void
        let filter: (Enchantment) -> Bool
        
        init(
            enchantments: [Enchantment],
            onTap: @escaping (Enchantment) -> Void = { _ in },
            filter: @escaping (Enchantment) -> Bool = { _ in true }
        ) {
            self.enchantments = enchantments
            self.onTap = onTap
            self.filter = filter
        }
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(enchantments.filter(filter), id: \.id) { enchant in
                    VStack(alignment: .leading, spacing: 1) {
                        Image(enchant.image)
                            .resizable()
                            .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                            .padding(screenWidth*0.01)
                            .runeTileStyle(shadowDepth: 0.09)
                        Text(enchant.description)
                            .font(.custom("Trattatello", size: 0.05*screenWidth))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }
                    .frame(width: screenWidth*0.44, height: screenWidth*0.5)
                    .runeBinderButtonStyle()
                    .onTapGesture {
                        onTap(enchant)
                    }
                }
            }
            .padding(1)
        }
        .background(Color.black)
        .navigationTitle("Enchantments")
    }
}
