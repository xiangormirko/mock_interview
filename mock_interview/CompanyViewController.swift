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
    let prefs = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if prefs.boolForKey("notFirstTime") {
            print("false")
        } else {
            print("true")
            let entity = NSEntityDescription.entityForName("Company", inManagedObjectContext: sharedContext)
            
            let Mok = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: sharedContext)
            Mok.setValue("Mok", forKey: "name")
            Mok.setValue(0000, forKey: "glassdoorId")
            Mok.setValue(UIImage(named: "Icon-Small"), forKey: "companyLogo")
            Mok.setValue("Custom Interview, edit as you wish", forKey: "website")
            
            saveContext()
            
            for text in Glassdoor.topQuestions {
                let question = Question(string: text, context: self.sharedContext)
                question.company = Mok as? Company
            }
            
            saveContext()
            
            prefs.setBool(true, forKey: "notFirstTime")
            
        }
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
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
            _ = Company(dictionary: dictionary, context: sharedContext)

            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    
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
        let controller = storyboard!.instantiateViewControllerWithIdentifier("InterviewViewController") as! InterviewViewController
        let company = fetchedResultsController.objectAtIndexPath(indexPath) as! Company
        controller.company = company
        self.navigationController!.pushViewController(controller, animated: true)
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
        } else if company.logo == nil || company.logo == "" {
            cell.companyLogoView.image = UIImage(named: "default")
        }

        else {
            // Set the placeholder
            cell.companyLogoView.image = UIImage(named: "default")
            
            

            let task = Glassdoor.sharedInstance().taskForImage(company.logo!) { (imageData, error) -> Void in
                
                // Handle the error case
                if let error = error {
                    // Initialize Alert Controller
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "Request error", message: "Something went wrong with the network", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "OK, happens...", style: .Default) { (action) -> Void in
                            print("The user is okay.")
                        }
                        alertController.addAction(action)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error searching for logo: \(error.localizedDescription)")
                    return
                }
                
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

