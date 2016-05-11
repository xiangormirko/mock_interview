//
//  Question.swift
//  mock_interview
//
//  Created by MIRKO on 4/26/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation
import CoreData

class Question : NSManagedObject {
    @NSManaged var text : String
    @NSManaged var company : Company?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(string: String, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("Question", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        text = string
    }
}