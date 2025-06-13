# WidgetSwiftUI

A SwiftUI playground for experimenting with drag-and-drop widgets, color palettes, and dynamic layout splitting.

This project allows users to drag colored widgets from a palette into a drop area, where each widget can be split either vertically or horizontally, with a maximum of three layouts, to create complex, nested arrangements. The splitting logic is recursive: when a new widget is dropped onto an existing one, the existing area is divided according to the chosen split direction, and the widgets are displayed side by side (or stacked). This enables users to build flexible, multi-pane interfaces interactively.

---

## Table of Contents

- Overview
- Features
- Architecture
- Key Components
- How to Use
- File Structure
- Customization
- Credits

---

## Overview

**WidgetSwiftUI** is an interactive SwiftUI app that allows users to drag colored widgets from a palette into a drop area, split and arrange them dynamically, and reset the layout. It demonstrates advanced SwiftUI concepts such as recursive view rendering, drag-and-drop, and custom layout logic.

---

## Features

- **Drag-and-drop**: Move colored widgets from a palette into a drop area.
- **Dynamic layout**: Widgets can be split vertically or horizontally.
- **Reset functionality**: Clear all widgets and start fresh.
- **Visual feedback**: Highlight widgets during drag-and-drop.
- **Custom color palette**: Easily add or modify available colors.

---

## Architecture

The project is organized into logical groups for clarity and maintainability using MVVM pattern:
- **Model**: Defines the data structures and enums representing widgets, their layout, and split directions.
- **View**: SwiftUI views responsible for rendering the UI, handling user interactions, and displaying the widget layout.
- **ViewModel**: Manages the state of the widget tree, processes drag-and-drop actions, updates the layout, and provides data binding between the Model and View.
- **Helpers**: Utility functions for color management and layout calculations, supporting the main MVVM components.

---

## Key Components

### WidgetView

The main UI, responsible for:

- Displaying the reset button.
- Rendering the drop area (with placeholder or widgets).
- Showing the color palette for draggable widgets.
- Handling drag-and-drop via a custom delegate.

### WidgetViewModel

Manages the state of the widget tree, current color selection, and highlight logic.

### DroppedWidget

Represents a widget or a split node in the layout tree.

### renderRects

A recursive function that renders the widget tree as nested rectangles, splitting frames according to the layout.

---

## How to Use

1. **Run the app** in Xcode 16 or later with iOS 17 or later.
2. **Drag a color** from the palette into the drop area to create a new widget.
3. **Split and arrange** widgets by dragging new colors onto existing widgets.
4. **Reset** the layout at any time using the reset button.

---

## File Structure

```
WidgetSwiftUI/
├── Model/
│   └── DroppedWidget.swift
├── View/
│   └── WidgetView.swift
├── ViewModel/
│   └── WidgetViewModel.swift
├── ...
```

---

## Customization

- **Add new colors**: Edit the color palette in `WidgetViewModel`.
- **Change split logic**: Modify the tree manipulation functions.
- **Adjust UI**: Tweak the SwiftUI views for different layouts or styles.

---

## Credits

Created by CHOENG HORLEANG. 

---
