//
//  LocalService.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 24.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import CoreData

struct GameStat {
    let previous: Double
    let current: Double
    let best: Double
}

final class LocalService {
    private let defaults = UserDefaults.standard
    private let tableSizeKey = "tableSize"
    private let stack = CoreDataStack.shared
    
    func clearAllData() {
        let entityName = "GameResult"
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try stack.managedContext.persistentStoreCoordinator?.execute(deleteRequest, with: stack.managedContext)
            stack.saveContext()
        } catch let error as NSError {
            print("Deleting results error: \(error), \(error.userInfo)")
        }
    }
}

extension LocalService {
    func handleEndGame(gameType: GameType, table size: TableSize, timeInfo: (Int, Int)) -> GameStat {
        let currentTime: Double = Double(timeInfo.0) + Double(timeInfo.1) / 100
        let fetchRequest: NSFetchRequest<GameResult> = GameResult.fetchRequest()
        
        do {
            var gameResults = try stack.managedContext.fetch(fetchRequest)
            gameResults = gameResults.filter({ gameResult in
                if gameResult.gameType == gameType.rawValue && gameResult.tableSize == size.rawValue {
                    return true
                }
                return false
            })
            let previousTime: Double = gameResults.last?.time ?? 0
            
            var bestTime: Double = 0
            for result in gameResults {
                if result.time < bestTime || bestTime == 0 {
                    bestTime = result.time
                }
            }
            
            let currentResult = GameResult(context: stack.managedContext)
            currentResult.time = currentTime
            currentResult.gameType = Int16(gameType.rawValue)
            currentResult.tableSize = Int16(size.rawValue)
            currentResult.date = Date()
            
            gameResults.append(currentResult)
            // Saving changed data in store
            stack.saveContext()
            
            return GameStat(previous: previousTime, current: currentTime, best: bestTime)
        } catch let error as NSError {
            print("Fetch error \(error), \(error.userInfo)")
        }
        return (0.0, currentTime, 0.0)
    }
}

// MARK: - TableSize
extension LocalService {
    var defaultTableSize: Int? {
        get {
            let value = defaults.integer(forKey: tableSizeKey)
            return value != 0 ? value : nil
        }
        set(value) {
            if let value = value {
                defaults.set(value, forKey: tableSizeKey)
            }
        }
    }
}
