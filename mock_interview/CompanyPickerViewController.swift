//
//  CompanyPickerViewController.swift
//  mock_interview
//
//  Created by MIRKO on 4/27/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation

import UIKit
import CoreData

protocol CompanyPickerViewControllerDelegate {
    func companyPicker(actorPicker: CompanyPickerViewController, didPickCompany company: Company?)
}

class CompanyPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var companies = [Company]()

    var delegate: CompanyPickerViewControllerDelegate?
    var searchTask: NSURLSessionDataTask?
    var temporaryContext: NSManagedObjectContext!

    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(CompanyPickerViewController.cancel))
        searchBar.delegate = self;
        tableView.delegate = self;
        let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // If the text is empty we are done
        if searchText == "" {
            companies = [Company]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        // Start a new one download
        let parameters = ["q" : searchText]
        
        
        
        searchTask = Glassdoor.sharedInstance().taskForResource(parameters) {jsonResult, error in
            
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
                print("Error searching for actors: \(error.localizedDescription)")
                return
            }
            
            let employerContainer = jsonResult.valueForKey("response")
            
            // Get a Swift dictionary from the JSON data
            if let companyDictionaries = employerContainer?.valueForKey("employers") as? [[String : AnyObject]] {
                self.searchTask = nil
//                print(companyDictionaries)
                
                // Create an array of Person instances from the JSON dictionaries
                self.companies = companyDictionaries.map() {
                    Company(dictionary: $0, context: self.temporaryContext)
                }
                
                // Reload the table on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func cancel() {
        self.delegate?.companyPicker(self, didPickCompany: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellReuseId = "CompanySearchCell"
        let company = companies[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId)!
        
        configureCell(cell, company: company)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let company = companies[indexPath.row]
        
        // Alert the delegate
        delegate?.companyPicker(self, didPickCompany: company)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configureCell(cell: UITableViewCell, company: Company) {
        cell.textLabel!.text = company.name
    }
    
}