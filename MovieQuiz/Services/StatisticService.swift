import Foundation

class StatisticService: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum KeysToStore: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: KeysToStore.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: KeysToStore.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: KeysToStore.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: KeysToStore.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard
                let data = userDefaults.data(forKey: KeysToStore.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data)
            else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            print(data, KeysToStore.bestGame.rawValue)
            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: KeysToStore.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if (currentGame.isBetterThan(anotherGame: bestGame)) {
            bestGame = currentGame
        }
        totalAccuracy = Double(count) / Double(amount)
    }
}
