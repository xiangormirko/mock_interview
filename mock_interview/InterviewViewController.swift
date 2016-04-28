//
//  InterviewViewController.swift
//  mock_interview
//
//  Created by MIRKO on 4/28/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation
import UIKit
import Kanna
import HTMLReader
import Alamofire
import CoreData


class InterviewViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var company : Company!
    
    let URLStringList = ["https://www.glassdoor.com/Interview/Apple-Interview-Questions-E1138.htm",
                     "https://www.glassdoor.com/Interview/Airbnb-Interview-Questions-E391850.htm",
                     "https://www.glassdoor.com/Interview/Google-Interview-Questions-E9079.htm",
                     "https://www.glassdoor.com/Interview/Cisco-Systems-Interview-Questions-E1425.htm",
                     "https://www.glassdoor.com/Interview/Expedia-Interview-Questions-E9876.htm",
                     ]

    
    var html = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchData{_ in 
//            print("hello")
//        }
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
        print(company)
        
        // Step 2: Perform the fetch
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects!.count > 0 {
                print("count: \(fetchedResultsController.fetchedObjects!.count)")
                for obj in fetchedResultsController.fetchedObjects! {
                    let object = obj as! Question
                    sharedContext.deleteObject(object)
                    print(object.text)
                    saveContext()
                    
                }
            } else {
                print("time to fetch")
                fetchData{_ in
                    print("successfully retrieved qustions")
                }
            }
            
        } catch {
            print("Unresolved error \(error)")
            abort()
        }

        
        
        
//        let results = fetch()
//        if results.count > 0 {
//            print(results)
//        } else {
////            fetchData{_ in
////                print("successfully retrieved qustions")
////            }
//            print("time to fetch")
//        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func fetchData(completionHandler: (NSError?) -> Void) {
        Alamofire.request(.GET, URLStringList[1])
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    completionHandler(error)
                    return
                }

                let doc = HTMLDocument(string: htmlAsString)
                
                

                let spans = doc.nodesMatchingSelector("span.interviewQuestion")
                let entityDescription = NSEntityDescription.entityForName("Question", inManagedObjectContext: self.sharedContext)
                var questions: [String] = []
                for span in spans {
                    let rawText = span.innerHTML
                    let interviewText = rawText.substringToIndex(rawText.endIndex.advancedBy(-7))
                    questions.append(interviewText)
                    
                    
//                    let question = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: self.sharedContext)
//                    question.setValue(rawText, forKey: "text")
//                    question.setValue(self.company, forKey: "company")
                    
                }
                
                for question in questions {
                    let newQuestion = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: self.sharedContext)
                    newQuestion.setValue(question, forKey: "text")
                    newQuestion.setValue(self.company, forKey: "company")
                }
                
                self.saveContext()
                completionHandler(nil)
        }
    }
    
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Question")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "company == %@", self.company);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
    
    
    func fetch() -> [AnyObject] {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Question", inManagedObjectContext: sharedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try sharedContext.executeFetchRequest(fetchRequest)
            return result
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return []
        }
        

        
        
//        let url = NSURL(string: "https://www.glassdoor.com/Interview/Apple-Interview-Questions-E1138.htm")
//        
//        if url != nil {
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//    
//                if error == nil {
//                    
//                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as NSString!
//                    
//                    self.html = String(urlContent)
//                    print(self.html)
//                    
//                    if let doc = Kanna.HTML(html: self.html, encoding: NSUTF8StringEncoding) {
//                        
//                        for link in doc.css("span"){
//                            print(link.text)
//                        }
//                        
//                    }
//                }
//            })
//            task.resume()
//        }
    }
    
}