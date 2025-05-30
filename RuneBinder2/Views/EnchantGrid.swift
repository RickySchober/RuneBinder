import SwiftUI

struct EnchantmentGridView: View {
    let enchantments: [Enchantment]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(enchantments, id: \.id) { enchant in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(enchant.description)
                            .font(.headline)
                            .foregroundColor(enchant.color)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 12).fill(enchant.color.opacity(0.1)))
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle("Enchantments")
    }
}
