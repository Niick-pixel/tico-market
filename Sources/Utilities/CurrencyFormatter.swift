import Foundation

enum CurrencyFormatter {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_CR")
        formatter.currencySymbol = "₡"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "₡\(Int(amount))"
    }
}
