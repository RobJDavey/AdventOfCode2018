import Foundation

let squareSize = 300
public let defaultWidth = squareSize
public let defaultHeight = squareSize

func calculatePowerLevel(x: Int, y: Int, serial: Int) -> Int {
    let rackID = x + 10
    var powerLevel = rackID * y
    powerLevel += serial
    powerLevel *= rackID
    let hundredsDigit = (powerLevel / 100) % 10
    return hundredsDigit - 5
}

public func generateGrid(serialNumber: Int, width: Int = defaultWidth, height: Int = defaultHeight) -> [[Int]] {
    var grid = Array(repeating: Array(repeating: 0, count: width + 1), count: height + 1)
    
    for y in 1...height {
        for x in 1...width {
            grid[y][x] = calculatePowerLevel(x: x, y: y, serial: serialNumber)
        }
    }
    
    return grid
}

public func generateSummedAreaTable(grid: [[Int]], width: Int = defaultWidth, height: Int = defaultHeight) -> [[Int]] {
    var summedAreaTable = Array(repeating: Array(repeating: 0, count: width + 1), count: height + 1)
    
    for y in 1...height {
        for x in 1...width {
            let a = grid[y][x]
            let b = summedAreaTable[y - 1][x]
            let c = summedAreaTable[y][x - 1]
            let d = summedAreaTable[y - 1][x - 1]
            summedAreaTable[y][x] = a + b + c - d
        }
    }
    
    return summedAreaTable
}

func calculateBestScore(summedAreaTable: [[Int]], size: Int = 3, width: Int = defaultWidth, height: Int = defaultHeight) -> (x: Int, y: Int, size: Int, score: Int) {
    var best: (x: Int, y: Int, size: Int, score: Int) = (0, 0, Int.min, Int.min)
    
    for y in 1...height - size + 1 {
        for x in 1...width - size + 1 {
            let x0 = x + size - 1
            let y0 = y + size - 1
            let x1 = x - 1
            let y1 = y - 1
            let a = summedAreaTable[y0][x0]
            let b = summedAreaTable[y1][x0]
            let c = summedAreaTable[y0][x1]
            let d = summedAreaTable[y1][x1]
            let i = d + a - b - c
            
            if i > best.score {
                best = (x, y, size, i)
            }
        }
    }
    
    return best
}

public func part1(summedAreaTable: [[Int]], width: Int = defaultWidth, height: Int = defaultHeight) -> (x: Int, y: Int, size: Int, score: Int) {
    return calculateBestScore(summedAreaTable: summedAreaTable, size: 3, width: width, height: height)
}

public func part2(summedAreaTable: [[Int]], width: Int = defaultWidth, height: Int = defaultHeight) -> (x: Int, y: Int, size: Int, score: Int) {
    var best: (x: Int, y: Int, size: Int, score: Int) = (0, 0, Int.min, Int.min)
    
    for size in 1...squareSize {
        let scoreForSize = calculateBestScore(summedAreaTable: summedAreaTable, size: size, width: width, height: height)
        if scoreForSize.score > best.score {
            best = scoreForSize
        }
    }
    
    return best
}
