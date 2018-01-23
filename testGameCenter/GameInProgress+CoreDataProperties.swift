//
//  GameInProgress+CoreDataProperties.swift
//  testGameCenter
//
//  Created by David Boydston on 1/22/18.
//  Copyright © 2018 Boydston. All rights reserved.
//
//

import Foundation
import CoreData


extension GameInProgress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameInProgress> {
        return NSFetchRequest<GameInProgress>(entityName: "GameInProgress")
    }

    @NSManaged public var gameLog: String
    @NSManaged public var gameID: String
    @NSManaged public var playerArray: String

}
