import SwiftUI

// MARK: - Drop Delegate
/// DropWidgetDelegate is a SwiftUI DropDelegate implementation for handling drag-and-drop of colored rectangles.
/// It manages the preview, insertion, and highlighting logic for dropping new blocks into a hierarchical layout.
struct DropWidgetDelegate: DropDelegate {
    @ObservedObject var widgetVM: WidgetViewModel
    var geoSize: CGSize
    
    /// Called when a drag-and-drop operation enters the drop target area.
    /// - Parameter info: The `DropInfo` object containing information about the drop event.
    /// - Note: This method updates `widgetVM.originalRect` to match the current `widgetVM.rootRect` when a drop enters.
    func dropEntered(info: DropInfo) {
        widgetVM.originalRect = widgetVM.rootRect
    }
    
    /// Called when a drag-and-drop operation exits the drop target area.
    /// - Parameter info: The `DropInfo` object containing information about the drop event.
    /// - Note: This method restores `widgetVM.rootRect` to `widgetVM.originalRect` and clears any highlight.
    func dropExited(info: DropInfo) {
        widgetVM.rootRect = widgetVM.originalRect
        widgetVM.highlightBlockId = nil
    }
    
    /// Handles the drop operation when the user releases the dragged item.
    /// - Parameter info: The `DropInfo` object containing information about the drop event.
    /// - Returns: A Boolean value indicating whether the drop was handled.
    /// - Note: This method updates `widgetVM.rootRect` and clears any highlight.
    func performDrop(info: DropInfo) -> Bool {
        widgetVM.highlightBlockId = nil
        
        // Calculate normalized drop location and direction
        let location = info.location
        let dropX = location.x / geoSize.width
        let dropY = location.y / geoSize.height
        let dx = abs(dropX - 0.5)
        let dy = abs(dropY - 0.5)
        let direction: SplitDirection = dx > dy ? .vertical : .horizontal
        
        // Attempt to extract a color name from the dropped item and update the rootRect accordingly.
        if let item = info.itemProviders(for: [.utf8PlainText]).first {
            _ = item.loadObject(ofClass: String.self) { colorName, _ in
                if let colorName,
                   let color = colorName.toColor {
                    DispatchQueue.main.async {
                        widgetVM.performDrop(color: color, dropX: dropX, dropY: dropY, direction: direction)
                    }
                }
            }
            return true
        }
        return false
    }
    
    /// Called repeatedly as the drag item moves within the drop target area.
    /// - Parameter info: The `DropInfo` object containing information about the drop event.
    /// - Returns: A `DropProposal` indicating the type of drop operation.
    /// - Note: This method updates the preview of the drop and highlights the potential new block.
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // Calculate normalized drop location and direction
        let location = info.location
        let dropX = location.x / geoSize.width
        let dropY = location.y / geoSize.height
        let dx = abs(dropX - 0.5)
        let dy = abs(dropY - 0.5)
        let direction: SplitDirection = dx > dy ? .vertical : .horizontal
        
        // Update the preview of the drop and highlight the potential new block
        DispatchQueue.main.async {
            widgetVM.updatePreview(dropX: dropX, dropY: dropY, direction: direction)
        }
        return DropProposal(operation: .move)
    }
}
