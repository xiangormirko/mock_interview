//
//  QuestionTableViewController.swift
//  mock_interview
//
//  Created by MIRKO on 5/2/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class QuestionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var questions = [Question]()
    var company : Company?
    
    override func viewDidLoad() {
        questionTextView.delegate = self
        tableView.delegate = self;
        tableView.dataSource = self;
        questionTextView.textColor = UIColor.lightGrayColor()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        confirmButton.layer.cornerRadius = 5

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func addQuestionAction(sender: AnyObject) {
        let questionText = questionTextView.text
        let question = Question(string: questionText, context: self.sharedContext)
        question.company = self.company
        CoreDataStackManager.sharedInstance().saveContext()
        questions.insert(question, atIndex: 0)
        tableView.reloadData()
        questionTextView.text = ""
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellReuseId = "QuestionCell"
        let question = questions[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId)!
        
        configureCell(cell, question: question)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let question = questions[indexPath.row]
        print(question)

    }
    
    func configureCell(cell: UITableViewCell, question: Question) {
        cell.textLabel!.text = question.text
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let question = questions[indexPath.row]
            questions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            sharedContext.deleteObject(question)
            CoreDataStackManager.sharedInstance().saveContext()
            print("deleted question")
        default:
            break
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Insert question text"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}