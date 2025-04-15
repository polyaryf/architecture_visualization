import Foundation

struct GridPosition {
    let row: Int
    let column: Int
}

extension CGRect {
    func gridPosition(cellSize: CGSize) -> GridPosition {
        let column = Int(self.midX / cellSize.width)
        let row = Int(self.midY / cellSize.height)
        return GridPosition(row: row, column: column)
    }
}

func manhattanPath(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
    var path: [GridPosition] = []
    var current = start

    while current.column != end.column {
        current = GridPosition(row: current.row, column: current.column + (current.column < end.column ? 1 : -1))
        path.append(current)
    }

    while current.row != end.row {
        current = GridPosition(row: current.row + (current.row < end.row ? 1 : -1), column: current.column)
        path.append(current)
    }

    return path
}
