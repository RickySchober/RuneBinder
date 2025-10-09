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
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(enchantments.filter(filter), id: \.id) { enchant in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(enchant.description)
                            .font(.headline)
                            .foregroundColor(enchant.color)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 12).fill(enchant.color.opacity(0.1)))
                            .onTapGesture {
                                onTap(enchant)
                            }
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle("Enchantments")
    }
}
