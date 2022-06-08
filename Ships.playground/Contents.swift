import Darwin
enum ShipStatus {
    case dead
    case alive
}
enum CellStatus {
    case hitted
    case nonhitted
}
enum Orientation: CaseIterable {
    case horizontal
    case vertical
}

struct Position: Equatable {
    var column: Character
    var row: Int
    
    init(column: Character, row: Int) {
        self.column = column
        self.row = row
    }
    
    init(position posStr: String) {
        var str = posStr
        column = str.removeFirst()
        row = Int(str) ?? -1
    }
    
    func columnFromCurrentBy(_ number: Int) -> Character {
        return Character(UnicodeScalar(Int(column.unicodeScalars.first!.value) + number)!)
    }
    
    func toString() -> String {
        return String(self.column) + String(self.row)
    }
    
    func neighborPositions() -> [Position] {
        
        var neighborPositions = [Position]()
        
        for columnStep in -1...1 {
            for rowStep in -1...1 {
                
                if columnStep != 0 || rowStep != 0 {
                    let pos = Position(column: self.columnFromCurrentBy(columnStep), row: self.row + rowStep)

                    neighborPositions.append(pos)
                }
            }
        }
        return neighborPositions
    }
}

class Deck {
    var position: Position
    var status: ShipStatus
    var neighborPositions: [Position] {
        position.neighborPositions()
    }
    
    init(position pos: Position) {
        self.position = pos
        status = .alive
    }
}

class Ship {
    var decks = [Deck]()
    var size: Int {
        decks.count
    }
    var status: ShipStatus {
        decks.contains(where: { $0.status == .alive }) ? .alive : .dead
    }
    var neighborPositions: [Position] {
        var neighborPositions = [Position]()
        for deck in decks {
            for neighborPosition in deck.neighborPositions {
                if !neighborPositions.contains(neighborPosition) {
                    neighborPositions.append(neighborPosition)
                }
            }
        }
        for deck in decks {
            neighborPositions.removeAll(where: { $0 == deck.position })
        }
        return neighborPositions
    }
    
    init(size shipSize: Int, startPosition startPos: Position, orientation: Orientation) {
        createDecks(amount: shipSize, startPosition: startPos, orientation: orientation)
    }
    
    func createDecks(amount: Int, startPosition startPos: Position, orientation: Orientation) {

        decks = []
        
        for i in 0..<amount {

            let nextPos: Position
            if orientation == .horizontal {
                nextPos = Position(column: startPos.columnFromCurrentBy(i), row: startPos.row)
            } else {
                nextPos = Position(column: startPos.column, row: startPos.row + i)
            }

            decks.append(Deck(position: nextPos))
        }
    }
    
    subscript(pos: String) -> Deck? {
        decks.first { $0.position == Position(position: pos) }
    }
}

class Cell {
    var position: Position
    var status: CellStatus
    
    init(position pos: Position) {
        self.position = pos
        status = .nonhitted
    }
}
struct BattleField {
    
    static let maxSize = 32
    static let minSize = 10
    static let firstColumn: Character = "А"
    static var firstColumnInt: Int {
        Int(firstColumn.unicodeScalars.first!.value) // \u{0410} 1040
    }
    static let firstRow = 1
    var lastColumnInt: Int {
        BattleField.firstColumnInt + size - 1
    }
    var lastColumn: Character {
         Character(Unicode.Scalar(lastColumnInt)!)
    }
    var size: Int {
        didSet {
            if !(BattleField.minSize...BattleField.maxSize ~= size) {
                size = 10
            }
        }
    }
    
    var cells = [Cell]()
    
    init(battleFieldSize size: Int) {
        self.size = size
        createBattleField()
    }
    
    mutating func createBattleField() {
        
        for row in BattleField.firstRow...size {
            for column in BattleField.firstColumnInt...lastColumnInt {
                
                if let scalar = Unicode.Scalar(column) {
                    
                    let cell = Cell(position: Position(column: Character(scalar), row: row))
                    cells.append(cell)
                }
            }
        }
    }
    
    subscript(pos: String) -> Cell? {
        cells.first { $0.position == Position(position: pos) }
    }
}

struct Fleet {
    var ships = [Ship]()
    
    mutating func addShip(_ ship: Ship) {
        ships.append(ship)
    }
    
    subscript(pos: String) -> Ship? {
        ships.first { $0[pos] != nil }
    }
}

struct BattleShipsPlayer {

    var battleField: BattleField
    var fleet: Fleet
    
    var fleetIsPlaced: Bool {
        fleet.ships.count == battleField.size ? true : false
    }
    var fleetIsDead: Bool {
        fleet.ships.filter({ $0.status == .dead }).count == battleField.size ? true : false
    }
    lazy var fleetStartCollection = [4 : battleField.size / 10, 3 : battleField.size / 5, 2 : Int(Double(battleField.size) / 3.3), 1 : Int(Double(battleField.size) / 2.5)]
    
    init(battleFieldSize size: Int) {
        self.battleField = BattleField(battleFieldSize: size)
        self.fleet = Fleet()
    }

    mutating func putShipsRandom() {
        
        while !fleetIsPlaced {

            let size = fleetStartCollection.filter({ $0.value > 0 }).keys.randomElement() ?? 0
            let startPosition = battleField.cells.randomElement()!.position.toString()
            let orientation = Orientation.allCases.randomElement() ?? .vertical
            
            putShip(size: size, startPosition: startPosition, orientation: orientation)
        }
    }
        
    mutating func putShip(size: Int, startPosition startPos: String, orientation: Orientation) {
        
        print("\n Put on \(startPos)")
        
        if fleetIsPlaced {
            print("Can't put ship - all ships are placed")
            return
        }
        
        if let amounOfShips = fleetStartCollection[size] {
            if amounOfShips == 0 {
                print("Can't put ship - all ships of that type are already on battlefield")
                return
            }
        } else {
            print("Can't put ship - anknown size of ship")
            return
        }
        
        
        if startPos.count < 2 {
            print("Can't put ship there - wrong coordinates amount")
            return
        }
        
        let ship = Ship(size: size, startPosition: Position(position: startPos), orientation: orientation)
        
        for deck in ship.decks {
            let deckPos = deck.position.toString()
            
            if battleField[deckPos] == nil {
                print("Can't put ship there - out of battle field")
                return
            }
            if fleet[deckPos] != nil {
                print("Can't put ship there - there is ship on this position")
                return
            }
        }
        
        for neighborPosition in ship.neighborPositions {
            if fleet[neighborPosition.toString()] != nil {
                print("Can't put ship there - to close to another ship")
                return
            }
        }
        
        fleet.addShip(ship)
        fleetStartCollection[size]! -= 1
        
        printAll()
    }
    mutating func shootInRandom(battleField: [Cell]) -> Position {
        
        return battleField.randomElement()!.position
    }
    
    mutating func takeShoot(in pos: String) {
           
        if fleetIsPlaced != true {
            print("Can't shoot - didn't place all ships")
            return
        }
        if fleetIsDead == true {
            print("Can't shoot - all ships are dead")
            return
        }
        
        if let cell = battleField[pos] {
            
            if cell.status == .hitted {
                print("Can't shoot there - this cell is already hitted")
                return
            }
            cell.status = .hitted
            
            if let ship = fleet[pos] {
                ship[pos]?.status = .dead
                
                if ship.status == .dead {

                    for neighborPosition in ship.neighborPositions {
                        
                        if let cell = battleField[neighborPosition.toString()] {
                            cell.status = .hitted
                        }
                    }
                }
            }
            
            if fleetIsDead == true {
                print("All ships are dead! Game over")
                return
            }
        } else {
            print("Can't shoot there - out of battle field")
        }
    }
    
    func printAll() {

        print("\n  ", separator: "", terminator: "")
        for value in BattleField.firstColumnInt...battleField.lastColumnInt {
            print("\(Character(Unicode.Scalar(value)!))", separator: "", terminator: "")
        }
        print()
        
        for cell in battleField.cells {
            
            if cell.position.column == BattleField.firstColumn {
                if cell.position.row < 10 {
                    print(" \(cell.position.row)", separator: "", terminator: "")
                } else {
                    print(cell.position.row, separator: "", terminator: "")
                }
                
            }

            let cellPos = cell.position.toString()

            if let ship = fleet[cellPos] {

                switch ship[cellPos]!.status {
                case .alive: print("■", separator: "", terminator: "")
                case .dead: print("✕", separator: "", terminator: "")
                }
            } else {
                switch cell.status {
                case .hitted: print("•", separator: "", terminator: "")
                case .nonhitted: print(" ", separator: "", terminator: "")
                }
            }
            
            if cell.position.column == battleField.lastColumn {
                print()
            }
        }
    }
}
enum Turn: String{
    case One = "Player 1"
    case Two = "Player 2"
    
    mutating func toggle() {
        self = self == .One ? .Two : .One
    }
}
struct BattleShipsGame {

    var player1: BattleShipsPlayer
    var player2: BattleShipsPlayer
    var turn: Turn = .One
    var winer: Turn? {
        if player1.fleetIsDead {
            return .Two
        }
        if player2.fleetIsDead {
            return .One
        }
        return nil
    }
    
    init(battleFieldSize size: Int) {
        player1 = BattleShipsPlayer(battleFieldSize: size)
        player2 = BattleShipsPlayer(battleFieldSize: size)
    }
    
    mutating func newGame(battleFieldSize size: Int) {
        player1 = BattleShipsPlayer(battleFieldSize: size)
        player2 = BattleShipsPlayer(battleFieldSize: size)
        turn = .One
        printAllPlayers()
    }
    mutating func player1ShootingIn(_ pos: String) {
        if turn == .One {
            player2.takeShoot(in: pos)
            printAllPlayers()
        } else {
            print("Player1 you can't shoot - it's not your turn")
        }
    }
    mutating func player2ShootingIn(_ pos: String) {
        if turn == .Two {
            player1.takeShoot(in: pos)
            printAllPlayers()
        } else {
            print("Player2 you can't shoot - it's not your turn")
        }
    }
    mutating func shootRandom() {
        
        while winer == nil {
            
            var pos: String
            
            switch turn {
            case .One:
                let nonhittedOtherPlayerCells = player2.battleField.cells.filter({ $0.status == .nonhitted })
                pos = player1.shootInRandom(battleField: nonhittedOtherPlayerCells).toString()
                player2.takeShoot(in: pos)
            case .Two:
                let nonhittedOtherPlayerCells = player1.battleField.cells.filter({ $0.status == .nonhitted })
                pos = player2.shootInRandom(battleField: nonhittedOtherPlayerCells).toString()
                player1.takeShoot(in: pos)
            }
            
            print("\n " + turn.rawValue + " is shooting in " + pos)
            
            turn.toggle()
            
            printAllPlayers()
        }
        print(winer!.rawValue + " congratulations you won!")
    }
    
    func printAllPlayers() {
        print("------player1------")
        player1.printAll()
        print("------player2------")
        player2.printAll()
    }
}

var battleShipsGame = BattleShipsGame(battleFieldSize: 10)

battleShipsGame.player1.putShipsRandom()
battleShipsGame.player2.putShipsRandom()
battleShipsGame.printAllPlayers()
battleShipsGame.shootRandom()

