import SwiftUI

extension String {
    var toColor: Color? {
        switch self {
            case "skyBlue": return .skyBlue
            case "hotPink": return .hotPink
            case "brightYellow": return .brightYellow
            case "limeGreen": return .limeGreen
            case "vibrantOrange": return .vibrantOrange
            default: return nil
        }
    }
}

