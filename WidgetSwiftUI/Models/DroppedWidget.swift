import SwiftUI

enum SplitDirection {
    case horizontal, vertical
}

// Represents a rectangle that can be either a leaf (with a color) or a container (with children and split direction)
struct DroppedWidget: Identifiable, Equatable {
    let id = UUID()
    var color: Color? // nil for container nodes
    var fraction: CGFloat
    var split: SplitDirection? // nil for leafs
    var children: [DroppedWidget]? // nil for leafs

    // Leaf initializer
    init(color: Color, fraction: CGFloat) {
        self.color = color
        self.fraction = fraction
        self.split = nil
        self.children = nil
    }

    // Container initializer
    init(fraction: CGFloat, split: SplitDirection, children: [DroppedWidget]) {
        self.color = nil
        self.fraction = fraction
        self.split = split
        self.children = children
    }
}
