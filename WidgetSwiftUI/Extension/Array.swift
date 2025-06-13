import SwiftUI

// Extension to add a scan function, which returns an array of accumulated values
extension Array {
    func scan<T>(_ initial: T, _ combine: (T, Element) -> T) -> [T] {
        var result: [T] = []
        var running = initial
        for x in self {
            result.append(running)
            running = combine(running, x)
        }
        return result
    }
}
