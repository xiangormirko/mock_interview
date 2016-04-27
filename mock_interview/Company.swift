//
//  Company.swift
//  mock_interview
//
//  Created by MIRKO on 4/26/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class Company : NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Website = "website"
        static let Glassdoorid = "id"
        static let Industry = "industry"
        static let Rating = "overallRating"
        static let Sector = "sector"
        static let Logo = "squareLogo"

    }
    
    @NSManaged var name: String
    @NSManaged var glassdoorId: NSNumber
    @NSManaged var website: String?
    @NSManaged var sector: String?
    @NSManaged var industry: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var logo: String?
    @NSManaged var questions: [Question]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Company", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        name = dictionary[Keys.Name] as! String
        glassdoorId = dictionary[Keys.Glassdoorid] as! Int
        website = dictionary[Keys.Website] as? String
        sector = dictionary[Keys.Sector] as? String
        industry = dictionary[Keys.Industry] as? String
        rating = dictionary[Keys.Rating] as? Double
        logo = dictionary[Keys.Logo] as? String

    }
    
    // delete elements in documents dir at deletion
    override func prepareForDeletion() {
        companyLogo = nil
    }
    
    // UIImage storage
    var companyLogo: UIImage? {
        
        get {
            return Glassdoor.Caches.imageCache.imageWithIdentifier("\(glassdoorId).png")
        }
        
        set {
            Glassdoor.Caches.imageCache.storeImage(newValue, withIdentifier: "\(glassdoorId).png")
        }
    }
    
    
    
    
//    var posterImage: UIImage? {
//        
//        get {
//            return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
//        }
//        
//        set {
//            TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
//        }
//    }
}