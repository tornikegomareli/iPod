import Foundation

enum RepeatMode: String, CaseIterable {
    case off = "Off"
    case one = "One"
    case all = "All"
    
    var systemImageName: String {
        switch self {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1"
        case .all:
            return "repeat"
        }
    }
}