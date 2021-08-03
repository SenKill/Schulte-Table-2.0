//
//  Result+CoreDataProperties.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/28/21.
//  Copyright © 2021 SenKill. All rights reserved.
//
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result")
    }

    @NSManaged public var bestResult: Double
    @NSManaged public var previousResult: Double

}
