import SwiftUI

extension Color {
    static let skyBlue = Color(red: 0/255, green: 207/255, blue: 255/255) // #00CFFF
    static let hotPink = Color(red: 255/255, green: 92/255, blue: 147/255) // #FF5C93
    static let brightYellow = Color(red: 255/255, green: 235/255, blue: 59/255) //#FFEB3B
    static let limeGreen = Color(red: 174/255, green: 234/255, blue: 0/255) // #AEEA00
    static let vibrantOrange = Color(red: 255/255, green: 109/255, blue: 0/255) // #FF6D00

    var name: String {
        switch self {
            case .skyBlue: return "skyBlue"
            case .hotPink: return "hotPink"
            case .brightYellow: return "brightYellow"
            case .limeGreen: return "limeGreen"
            case .vibrantOrange: return "vibrantOrange"
            default: return "unknown"
        }
    }
}
