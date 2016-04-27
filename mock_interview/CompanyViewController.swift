//
//  CompanyViewController.swift
//  mock_interview
//
//  Created by MIRKO on 4/22/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import UIKit
import CoreData

class ComanyViewController: UITableViewController, CompanyPickerViewControllerDelegate, NSFetchedResultsControllerDelegate {
    
    var searchTask: NSURLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(ComanyViewController.addCompany))
        

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        // Step 9: set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Company")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
    
    func addCompany() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CompanyPickerViewController") as! CompanyPickerViewController
        controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func companyPicker(companyPicker: CompanyPickerViewController, didPickCompany company: Company?) {
        
        
        if let newCompany = company {
            
            // Debugging output
            print("picked company with name: \(newCompany.name),  id: \(newCompany.glassdoorId)")
            
            let dictionary: [String : AnyObject] = [
                Company.Keys.Glassdoorid : newCompany.glassdoorId,
                Company.Keys.Name : newCompany.name,
                Company.Keys.Website : newCompany.website ?? "",
                Company.Keys.Industry : newCompany.industry ?? "",
                Company.Keys.Rating : newCompany.rating ?? 0.0,
                Company.Keys.Sector : newCompany.sector ?? "",
                Company.Keys.Logo : newCompany.logo ?? "",
            ]

            // Now we create a new Company, using the shared Context
            let comapany = Company(dictionary: dictionary, context: sharedContext)
            
            print(company!.logo)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    

//    func scrape() {
//        let url = NSURL(string: "https://www.glassdoor.com/Interview/Boston-Consulting-Group-Interview-Questions-E3879.htm")
//        
//        if url != nil {
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//                print(data)
//                
//                if error == nil {
//                    
//                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as NSString!
//                    
//                    print(urlContent)
//                }
//            })
//            task.resume()
//        }
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return (sectionInfo ).numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Here is how to replace the actors array using objectAtIndexPath
        let company = fetchedResultsController.objectAtIndexPath(indexPath) as! Company
        let CellIdentifier = "CompanyCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! CompanyTableViewCell
        
        // This is new.
        configureCell(cell, withCompany: company)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let controller = storyboard!.instantiateViewControllerWithIdentifier("MovieListViewController") as! MovieListViewController
//        let actor = fetchedResultsController.objectAtIndexPath(indexPath) as! Person
//        
//        controller.actor = actor
//        
//        self.navigationController!.pushViewController(controller, animated: true)
        print("clicked")
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let company = fetchedResultsController.objectAtIndexPath(indexPath) as! Company
            sharedContext.deleteObject(company)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! CompanyTableViewCell
            let company = controller.objectAtIndexPath(indexPath!) as! Company
            self.configureCell(cell, withCompany: company)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    
    func configureCell(cell: CompanyTableViewCell, withCompany company: Company) {
        cell.nameLabel!.text = company.name
        cell.websiteLabel!.text = company.website
//        cell.companyLogoView.image = UIImage(named: "personFrame")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        

        if let localImage = company.companyLogo {
            cell.companyLogoView.image = localImage
            print("image case 1")
        } else if company.logo == nil || company.logo == "" {
            print("image case 2")
            cell.companyLogoView.image = UIImage(named: "default")
        }
        
            // If the above cases don't work, then we should download the image
            
        else {
            print("image case 3")
            // Set the placeholder
            cell.companyLogoView.image = UIImage(named: "default")
            
            

            let task = Glassdoor.sharedInstance().taskForImage(company.logo!) { (imageData, error) -> Void in
                
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        company.companyLogo = image
                        cell.companyLogoView.image = image
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }

    }
    
    
    func search() {
        
        // Cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        let parameters = ["q" : "Apple"]
        
        searchTask = Glassdoor.sharedInstance().taskForResource(parameters) {jsonResult, error in
            
            // Handle the error case
            if let error = error {
                print("Error searching for actors: \(error.localizedDescription)")
                return
            }
            
            let employerContainer = jsonResult.valueForKey("response")

            // Get a Swift dictionary from the JSON data
            if let companyDictionaries = employerContainer!.valueForKey("employers") as? [[String : AnyObject]] {
                self.searchTask = nil
                // Create an array of Companies instances from the JSON dictionaries
                for company in companyDictionaries {
                    print(company["name"])
                    if let ceo = company["ceo"]?["name"]{
                        print(ceo)
                    }
                    
                }
                
                // Reload the table on the main thread
                dispatch_async(dispatch_get_main_queue()) {
//                    self.tableView!.reloadData()
                    print("dispatch")
                }
            }
        }
    }

}

