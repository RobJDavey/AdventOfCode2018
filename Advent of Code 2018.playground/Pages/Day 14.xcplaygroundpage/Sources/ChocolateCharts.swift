import Foundation

func createRecipes<T : BinaryInteger>(scores: inout [T], firstElf: inout Array<T>.Index, secondElf: inout Array<T>.Index) -> [T] {
    let firstValue = scores[firstElf]
    let secondValue = scores[secondElf]
    let sum = firstValue + secondValue
    let newRecipeScores: [T] = recipeScores(sum)
    scores.append(contentsOf: newRecipeScores)
    firstElf = (firstElf + 1 + Array<T>.Index(firstValue)) % scores.count
    secondElf = (secondElf + 1 + Array<T>.Index(secondValue)) % scores.count
    return newRecipeScores
}

public func recipeScores<T : BinaryInteger, U : BinaryInteger>(_ number: T) -> [U] {
    var result: [U] = []
    var number = number
    
    repeat {
        result.insert(U(number % 10), at: 0)
        number = number / 10
    } while number > 0
    
    return result
}

public func part1<T : BinaryInteger>(_ initialState: [T], skip: Int, take: Int = 10) -> ArraySlice<T> {
    var scores = initialState
    var firstElf = scores.startIndex
    var secondElf = scores.index(after: firstElf)
    let upperBound = skip + take
    
    while scores.count < upperBound {
        _ = createRecipes(scores: &scores, firstElf: &firstElf, secondElf: &secondElf)
    }
    
    return scores[skip..<upperBound]
}

public func part2<T : BinaryInteger>(_ initialState: [T], target: ArraySlice<T>) -> Int {
    var scores = initialState
    var firstElf = scores.startIndex
    var secondElf = scores.index(after: firstElf)
    let targetLength = target.count
    
    while true {
        let newRecipes = createRecipes(scores: &scores, firstElf: &firstElf, secondElf: &secondElf)
        
        if scores.suffix(targetLength) == target {
            return scores.endIndex - targetLength
        }
        
        if newRecipes.count == 2 && scores.dropLast().suffix(targetLength) == target {
            return scores.endIndex - targetLength - 1
        }
    }
    
    fatalError()
}
