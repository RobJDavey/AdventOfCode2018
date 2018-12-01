import Foundation

public func getInput() -> String {
    guard let url = Bundle.main.url(forResource: "input", withExtension: "txt") else {
        fatalError("Could not load the url for the input file")
    }
    
    guard let data = try? Data(contentsOf: url) else {
        fatalError("Could not load the contents of \(url)")
    }
    
    guard let input = String(data: data, encoding: .utf8) else {
        fatalError("Could not read the input data as UTF-8")
    }
    
    return input.trimmingCharacters(in: .newlines)
}
