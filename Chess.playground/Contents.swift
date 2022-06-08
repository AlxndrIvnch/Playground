enum PieceNames: String, CaseIterable {
    case king
    case queen
    case bishop
    case knight
    case rook
    case pawn
}

enum BlackOrWhite: String, CaseIterable {
    case black
    case white
    
    mutating func toggle() {
        self = self == .white ? .black : .white
    }
}

enum PieceSymbols: String {
    case whiteking = "♚"
    case blackking = "♔"
    case whitequeen = "♛"
    case blackqueen = "♕"
    case whitebishop = "♝"
    case blackbishop = "♗"
    case whiteknight = "♞"
    case blackknight = "♘"
    case whiterook = "♜"
    case blackrook = "♖"
    case whitepawn = "♟"
    case blackpawn = "♙"
}

enum ColumnNames: Character, CaseIterable {
    case a = "a"
    case b = "b"
    case c = "c"
    case d = "d"
    case e = "e"
    case f = "f"
    case g = "g"
    case h = "h"
    
    func toIndex() -> Int {
        switch self {
        case .a: return 0
        case .b: return 1
        case .c: return 2
        case .d: return 3
        case .e: return 4
        case .f: return 5
        case .g: return 6
        case .h: return 7
        }
    }
}

extension Character {
    func toColumnNames() -> ColumnNames? {
        switch self {
        case "a": return .a
        case "b": return .b
        case "c": return .c
        case "d": return .d
        case "e": return .e
        case "f": return .f
        case "g": return .g
        case "h": return .h
        default:
            return nil
        }
    }
    func toRowNames() -> RowNames? {
        switch self {
        case "1": return .one
        case "2": return .two
        case "3": return .three
        case "4": return .four
        case "5": return .five
        case "6": return .six
        case "7": return .seven
        case "8": return .eight
        default:
            return nil
        }
    }
}

enum RowNames: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    
    func toIndex() -> Int {
        switch self {
        case .one: return 0
        case .two: return 1
        case .three: return 2
        case .four: return 3
        case .five: return 4
        case .six: return 5
        case .seven: return 6
        case .eight: return 7
        }
    }
}

enum Directions: CaseIterable {
    case up
    case down
    case left
    case right
    case upRight
    case downRight
    case upLeft
    case downLeft
    case up2Right1
    case down2Right1
    case up2Left1
    case down2Left1
    case up1Right2
    case down1Right2
    case up1Left2
    case down1Left2

}

struct Position: Equatable {
    
    var column: ColumnNames
    var row: RowNames
    
    init(column: ColumnNames, row: RowNames) {
        self.column = column
        self.row = row
    }
    	
    func toString() -> String {
        return "\(column)\(row.toIndex() + 1)"
    }
}

class Piece {
    
    let name: PieceNames
    let color: BlackOrWhite
    var symbol: String {
        switch (name, color) {
        case (PieceNames.king, .white): return PieceSymbols.whiteking.rawValue
        case (PieceNames.queen, .white): return PieceSymbols.whitequeen.rawValue
        case (PieceNames.bishop, .white): return PieceSymbols.whitebishop.rawValue
        case (PieceNames.knight, .white): return PieceSymbols.whiteknight.rawValue
        case (PieceNames.rook, .white): return PieceSymbols.whiterook.rawValue
        case (PieceNames.pawn, .white): return PieceSymbols.whitepawn.rawValue
        case (PieceNames.king, .black): return PieceSymbols.blackking.rawValue
        case (PieceNames.queen, .black): return PieceSymbols.blackqueen.rawValue
        case (PieceNames.bishop, .black): return PieceSymbols.blackbishop.rawValue
        case (PieceNames.knight, .black): return PieceSymbols.blackknight.rawValue
        case (PieceNames.rook, .black): return PieceSymbols.blackrook.rawValue
        case (PieceNames.pawn, .black): return PieceSymbols.blackpawn.rawValue
        }
    }
    var position: Position? = nil
    var avalibleCells: [Cell]? = nil

    init(name: PieceNames, color: BlackOrWhite) {
        
        self.name = name
        self.color = color
        
    }
}

class Cell {
    
    let position: Position
    var color: BlackOrWhite {
        return (position.column.toIndex() + position.row.toIndex()) % 2 == 0 ? .black : .white
    }
    var symbol: String {
        return color == .black ? "◻︎" : "◼︎"
    }
    var piece: Piece? = nil
    
    init(column: ColumnNames, row: RowNames) {
        position = Position(column: column, row: row)
    }
}

class Chessgame {
    
    var turn: BlackOrWhite = .white
    var chessboard = [Cell]()
    var pieces = [Piece]()
    
    init() {
        createPiecesArray()
        createChessboard()
    }
    
    func createPiecesArray() {
        
        for color in BlackOrWhite.allCases {
            for name in PieceNames.allCases {
                
                var count: Int
                
                switch name {
                case .king, .queen: count = 1
                case .bishop, .knight, .rook: count = 2
                case .pawn: count = 8
                }
                for _ in 1...count {
                    pieces.append(Piece(name: name, color: color))
                }
            }
        }
    }
    
    func createChessboard() {
        for row in RowNames.allCases {
            for column in ColumnNames.allCases  {
                chessboard.append(Cell(column: column, row: row))
            }
        }
    }
    
    func putPiece(_ piece: Piece, on cell: Cell) {
        
        piece.position = cell.position
        cell.piece = piece
    }
    
    func takePiece(from cell: Cell) {
        
        if let piece = cell.piece {
            piece.position = nil
        }
        cell.piece = nil
    }
    
    func takePiecesFromChessboard() {
        
        for cell in chessboard {
            takePiece(from: cell)
        }
    }
    
    func putPiecesOnDefaultPositions() {
        
        takePiecesFromChessboard()
        
        for color in BlackOrWhite.allCases {
            
            for column in ColumnNames.allCases {
                
                let filtredPieces = pieces.filter { $0.color == color && $0.position == nil }
                
                if filtredPieces.count != 0 {
                
                    var piece: Piece? = filtredPieces.first { $0.name == .pawn }
                    var cell: Cell? = chessboard.first { $0.position == Position(column: column, row: color == .white ? .two : .seven) }
                    
                    if piece != nil && cell != nil {
                        putPiece(piece!, on: cell!)
                    }
                    
                    piece = nil
                    cell = chessboard.first { $0.position == Position(column: column, row: color == .white ? .one : .eight) }
                        
                    switch column {
                            
                    case .a, .h:
                        piece = filtredPieces.first { $0.name == .rook }

                    case .b, .g:
                        piece = filtredPieces.first { $0.name == .knight }
                        
                    case .c, .f:
                        piece = filtredPieces.first { $0.name == .bishop }
                        
                    case .d:
                        piece = filtredPieces.first { $0.name == .queen }
                        
                    case .e:
                        piece = filtredPieces.first { $0.name == .king }
                    }
                    
                    if piece != nil && cell != nil {
                        putPiece(piece!, on: cell!)
                    }
                }
            }
        }
        chessgame.printChessboard()
    }
    
    func printChessboard() {

        print("  ════════")
        
        for row in RowNames.allCases.reversed() {
            
            print("\(row.rawValue)║", separator: " ", terminator: "")
            
            for column in ColumnNames.allCases {
                
                if let cell = chessboard.first(where: { $0.position == Position(column: column, row: row) }) {
                    print(cell.piece == nil ? cell.symbol : cell.piece!.symbol, separator: "", terminator: "")
                }
            }
            print("║")
        }
        print("  ════════")
        print("  ", terminator: "")
        
        for column in ColumnNames.allCases {
            print("\(column.rawValue)", separator: "", terminator: "")
        }
        print("\n")
    }
    
    func checkMove(from posFrom: Position, to posTo: Position) -> Bool {
        
        calculateAvalibleCells()
        
        if let cell = chessboard.first(where: { $0.position == posFrom }) {
            if let piece = cell.piece {
                
                if piece.color != turn {
                    return false
                }
                
                if let newCell = piece.avalibleCells?.first(where: { $0.position == posTo }) {
                    
                    takePiece(from: cell)
                    takePiece(from: newCell)
                    putPiece(piece, on: newCell)
                    
                    if let checkedKing = isCheked() {
                        
                        if checkedKing.color == turn {
                            
                            takePiece(from: cell)
                            takePiece(from: newCell)
                            putPiece(piece, on: cell)
                            
                            return false
                        }
                    }
                    
                    takePiece(from: cell)
                    takePiece(from: newCell)
                    putPiece(piece, on: cell)
                    
                    return true
                    
                }
            }
        }
        return false
    }
    
    func makeMove(from posFrom: String, to posTo: String) {
        
        print("Move: \(posFrom) -> \(posTo)")
        
        let posFromColumn = (posFrom.first)?.toColumnNames()
        let posFromRow = (posFrom.last)?.toRowNames()
        let posToColumn = (posTo.first)?.toColumnNames()
        let posToRow = (posTo.last)?.toRowNames()
        
        if posFromColumn == nil || posFromRow == nil {
            print("Wrong posFrom")
            return
        }
        if posToColumn == nil || posToRow == nil {
            print("Wrong posTo")
            return
        }
        let posFrom = Position(column: posFromColumn!, row: posFromRow!)
        let posTo = Position(column: posToColumn!, row: posToRow!)
        
        calculateAvalibleCells()
        
        if let cell = chessboard.first(where: { $0.position == posFrom }) {
            if let piece = cell.piece {
                
                if piece.color != turn {
                    print("\(piece.symbol) it's not your tern")
                    return
                }
                
                
                if let newCell = piece.avalibleCells?.first(where: { $0.position == posTo }) {
                    
                    takePiece(from: cell)
                    takePiece(from: newCell)
                    putPiece(piece, on: newCell)
                    
                    if let checkedKing = isCheked() {
                        
                        if checkedKing.color == turn {
                            
                            print("Your \(checkedKing.symbol) is attacked! You can't go \(posFrom.column.rawValue)\(posFrom.row.rawValue) -> \(posTo.column.rawValue)\(posTo.row.rawValue)")
                            
                            takePiece(from: cell)
                            takePiece(from: newCell)
                            putPiece(piece, on: cell)
                            
                            return
                        } else {
                            if isCheckMated(checkedKing) {
                                print("Chekmate for \(checkedKing.symbol) !")
                                turn = .white
                                printChessboard()
                                putPiecesOnDefaultPositions()
                                return
                                
                            } else {
                                print("Chek for \(checkedKing.symbol) !")
                            }
                        }
                    }
                    
                    turn.toggle()
                    printChessboard()
                    
                    return
                    
                } else {
                    print("\(piece.symbol) can't go \(posFrom.column.rawValue)\(posFrom.row.rawValue) -> \(posTo.column.rawValue)\(posTo.row.rawValue)")
                }
            } else {
                print("\(posFrom.column.rawValue)\(posFrom.row.rawValue) has no piece on it")
            }
        }
        return
    }
    
    func calculateAvalibleCellsOn(directions: [Directions], for piece: Piece, maxDistance: Int = 7) {
        
        for direction in directions {
            
            var columnStep = 0
            var rowStep = 0
            
            switch direction {
            
            case .up:
                columnStep = 0
                rowStep = 1
                
            case .down:
                columnStep = 0
                rowStep = -1
                
            case .left:
                columnStep = -1
                rowStep = 0
                
            case .right:
                columnStep = 1
                rowStep = 0
                
            case .upRight:
                columnStep = 1
                rowStep = 1
                
            case .downRight:
                columnStep = 1
                rowStep = -1
                
            case .upLeft:
                columnStep = -1
                rowStep = 1
                
            case .downLeft:
                columnStep = -1
                rowStep = -1
                
            case .up2Right1:
                columnStep = 1
                rowStep = 2
                
            case .down2Right1:
                columnStep = 1
                rowStep = -2
                
            case .up2Left1:
                columnStep = -1
                rowStep = 2
                
            case .down2Left1:
                columnStep = -1
                rowStep = -2
                
            case .up1Right2:
                columnStep = 2
                rowStep = 1
                
            case .down1Right2:
                columnStep = 2
                rowStep = -1
                
            case .up1Left2:
                columnStep = -2
                rowStep = 1
                
            case .down1Left2:
                columnStep = -2
                rowStep = -1
            }
            
            for _ in 1...maxDistance {
                
                if let cell = chessboard.first(where: { $0.position.column.toIndex() == piece.position!.column.toIndex() + columnStep && $0.position.row.toIndex() == piece.position!.row.toIndex() + rowStep }) {
                    
                    if let pieceOnTheWay = cell.piece {
                        
                        if piece.name == .pawn && direction == .up || direction == .down  {
                            break
                        }
                        
                        if pieceOnTheWay.color != piece.color {
                            
                            piece.avalibleCells?.append(cell)
                            
                        }
                        break
                    } else {

                        if piece.name == .pawn && direction != .up && direction != .down {
                            break
                        }
                        piece.avalibleCells?.append(cell)
                    }
                } else {
                    break
                }
                
                nextStep(&columnStep)
                nextStep(&rowStep)
            }
        }
    }
    
    func nextStep(_ step: inout Int) {
        if step > 0 {
            step += 1
        } else if step < 0 {
            step -= 1
        }
    }
    
    func horizontal() -> [Directions] {
        return [.left, .right]
    }
    
    func vertical() -> [Directions] {
        return [.up, .down]
    }
    
    func allLs() -> [Directions] {
        return [.up1Left2, .up1Right2, .up2Left1, .up2Right1, .down1Left2, .down1Right2, .down2Left1, .down2Right1]
    }
    
    func allDiagonals() -> [Directions] {
        return [.downLeft, .downRight, .upLeft, .upRight]
    }
    
    func isCheked() -> Piece? {
        
        calculateAvalibleCells()
        
        return attackedKing()
    }
    
    func attackedKing() -> Piece? {
        
        for king in pieces.filter({ $0.name == .king }) {
            if let _ = howAttackedPiece(king) {
                return king
            }
        }
        return nil
    }
    
    func howAttackedPiece(_ piece: Piece) -> Piece? {
        
        for pieceOtherColor in pieces.filter({ $0.color != piece.color }) {
            
            if let pieceOtherColorAvalibleCells = pieceOtherColor.avalibleCells {
                if pieceOtherColorAvalibleCells.contains(where: { $0.position == piece.position && pieceOtherColor.name != .pawn || pieceOtherColor.name == .pawn && $0.position == piece.position && pieceOtherColor.position?.column != piece.position?.column}) {
                    
                    return pieceOtherColor
                }
            }
        }

        return nil
    }
    
    func isCheckMated(_ king: Piece) -> Bool {

        for piece in pieces.filter({ $0.color == king.color && $0.avalibleCells != nil }) {
            for avalibleCell in piece.avalibleCells! {
                if checkMove(from: piece.position!, to: avalibleCell.position) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func calculateAvalibleCells() {

        for piece in pieces.sorted(by: { return $0.name == .king && $1.name != .king ? false : true }) {
            
            if piece.position == nil {
                piece.avalibleCells = nil
                continue
            }
            
            piece.avalibleCells = []
            
            switch piece.name {
            case .king:
                calculateAvalibleCellsOn(directions: vertical() + horizontal() + allDiagonals(), for: piece, maxDistance: 1)
  
            case .queen:
                calculateAvalibleCellsOn(directions: vertical() + horizontal() + allDiagonals(), for: piece)
                
            case .bishop:
                calculateAvalibleCellsOn(directions: allDiagonals(), for: piece)
                
            case .knight:
                calculateAvalibleCellsOn(directions: allLs(), for: piece, maxDistance: 1)
                
            case .rook:
                calculateAvalibleCellsOn(directions: vertical() + horizontal(), for: piece)
                
            case .pawn:
                
                if piece.color == .white {
                    calculateAvalibleCellsOn(directions: [.upLeft, .upRight] , for: piece, maxDistance: 1)
                    if piece.position?.row == .two {
                        calculateAvalibleCellsOn(directions: [.up] , for: piece, maxDistance: 2)
                    } else {
                        calculateAvalibleCellsOn(directions: [.up] , for: piece, maxDistance: 1)
                    }
                } else {
                    calculateAvalibleCellsOn(directions: [.downLeft, .downRight] , for: piece, maxDistance: 1)
                    if piece.position?.row == .seven {
                        calculateAvalibleCellsOn(directions: [.down] , for: piece, maxDistance: 2)
                    } else {
                        calculateAvalibleCellsOn(directions: [.down] , for: piece, maxDistance: 1)
                    }
                }
            }
        }
    }
    
    func makeMoves(_ moves: [(from: String, to: String)]) {
        for move in moves {
            makeMove(from: move.from, to: move.to)
        }
    }
}

let chessgame = Chessgame()

chessgame.putPiecesOnDefaultPositions()

let childMate = [(from: "e2", to: "e4"), (from: "e7", to: "e5"), (from: "f1", to: "c4"), (from: "b8", to: "c6"), (from: "d1", to: "h5"), (from: "g8", to: "f6"), (from: "h5", to: "f7")]

chessgame.makeMoves(childMate)

//chessgame.makeMove(from: "d2", to: "d4")
//chessgame.makeMove(from: "g8", to: "f6")
//chessgame.makeMove(from: "d1", to: "f3")
//chessgame.putPiecesOnDefaultPositions()
