import SwiftUI

struct PriceTag: View {
    let amount: Double
    var label: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(CurrencyFormatter.format(amount))
                .font(.subheadline.weight(.semibold))
        }
    }
}
