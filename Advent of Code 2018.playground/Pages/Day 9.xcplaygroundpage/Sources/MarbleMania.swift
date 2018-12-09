import Foundation

final class Marble {
    let value: Int
    
    var next: Marble!
    weak var previous: Marble!
    
    init() {
        self.value = 0
        self.next = self
        self.previous = self
    }
    
    init(_ value: Int) {
        self.value = value
    }
    
    func clockwise(_ numberOfMoves: Int = 1) -> Marble {
        var marble = self
        
        for _ in 0..<numberOfMoves {
            marble = marble.next
        }
        
        return marble
    }
    
    func counterClockwise(_ numberOfMoves: Int) -> Marble {
        var marble = self
        
        for _ in 0..<numberOfMoves {
            marble = marble.previous
        }
        
        return marble
    }
    
    func insert (_ value: Int) -> Marble {
        let newMarble = Marble(value)
        let currentNext = next
        newMarble.next = currentNext
        currentNext?.previous = newMarble
        next = newMarble
        newMarble.previous = self
        return newMarble
    }
    
    func remove() -> Marble {
        let next = self.next!
        let previous = self.previous!
        next.previous = previous
        previous.next = next
        self.next = nil
        self.previous = nil
        return next
    }
}

public func calculateHighScore(_ playerCount: Int, _ lastMarble: Int) -> Int {
    var players = Array(repeating: 0, count: playerCount)
    var currentMarble = Marble()
    
    for marble in 1...lastMarble {
        let player = marble % playerCount
        
        if marble % 23 == 0 {
            currentMarble = currentMarble.counterClockwise(7)
            let value = currentMarble.value
            currentMarble = currentMarble.remove()
            players[player] += marble + value
        } else {
            currentMarble = currentMarble.clockwise().insert(marble)
        }
    }
    
    return players.max() ?? 0
}
