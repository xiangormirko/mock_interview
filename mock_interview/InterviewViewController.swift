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
import AVFoundation


class InterviewViewController: UIViewController, NSFetchedResultsControllerDelegate, AVAudioRecorderDelegate {
    
    // Outlets
    @IBOutlet weak var textToSpeechSwitch: UISwitch!
    @IBOutlet weak var editAddButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var interviewButton: UIButton!
    @IBOutlet weak var interviewText: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var interviewerView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var nextQButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Core Data holder variables
    var company : Company!
    var questionList = [Question]()
    
    // Audio session variable
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio : NSURL!
    var recording: AVAudioPlayer!
    
    // Audio session variable
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    
    // Timer variable
    var timer = NSTimer()
    var counter = 0
    
    var html = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timerLabel.text = timeString(counter)
        
        
        
        // Step 2: Perform the fetch
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects!.count > 1 {
                print("count: \(fetchedResultsController.fetchedObjects!.count)")
                for obj in fetchedResultsController.fetchedObjects! {
                    let object = obj as! Question
                    questionList.append(object)
                    
                }
            } else if company.name != "Mok" {
                print("time to fetch")
                fetchData{_ in
                    print("successfully retrieved qustions")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                    }
                    do {
                        try self.fetchedResultsController.performFetch()
                        if self.fetchedResultsController.fetchedObjects!.count > 1 {
                            print("count: \(self.fetchedResultsController.fetchedObjects!.count)")
                            dispatch_async(dispatch_get_main_queue()) {
                                self.questionLabel.text = "Questions: "+String(self.fetchedResultsController.fetchedObjects!.count)
                            }
                            for obj in self.fetchedResultsController.fetchedObjects! {
                                let object = obj as! Question
                                self.questionList.append(object)
                                
                                
                            }
                        } else {
                            print("less than 1 question")
                        }
                        
                    } catch {
                        print("Unresolved error \(error)")
                        abort()
                    }
                }
            }
            
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        fetchedResultsController.delegate = self
        recordingSession = AVAudioSession.sharedInstance()
        
        // UI settings
        recordButton.alpha = 0.0
        recordButton.layer.cornerRadius = 5
        editAddButton.layer.cornerRadius = 5
        interviewButton.layer.cornerRadius = 5
        nextQButton.layer.cornerRadius = 5
        nextQButton.alpha = 0.0

        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        print("good boy")
                    } else {
                        print("bad boy")
                    }
                }
            }
        } catch {
            print("failed to record")
        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let randomInt = Int(arc4random_uniform(UInt32(4)))
        let imageName = "int"+String(randomInt)
        interviewerView.contentMode = UIViewContentMode.ScaleAspectFit
        interviewerView.image = UIImage(named: imageName)
        questionLabel.text = "Questions: "+String(fetchedResultsController.fetchedObjects!.count)
        
        
    }
    
    func fetchData(completionHandler: (NSError?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
        }
        let companyString = (company.name as NSString).stringByReplacingOccurrencesOfString(" ", withString: "-")
        let urlString = Glassdoor.Constants.BaseSite + companyString + Glassdoor.Constants.Component + String(company.glassdoorId) + Glassdoor.Constants.EndPath

            Alamofire.request(.GET, urlString)
                .responseString { responseString in
                    guard responseString.result.error == nil else {
                        // Initialize Alert Controller
                        dispatch_async(dispatch_get_main_queue()) {
                            let alertController = UIAlertController(title: "Request error", message: "Something went wrong with the network", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK, happens...", style: .Default) { (action) -> Void in
                                print("The user is okay.")
                            }
                            alertController.addAction(action)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                        
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
                    var questions: [String] = []
                    for span in spans {
                        let rawText = span.innerHTML
                        let interviewText = rawText.substringToIndex(rawText.endIndex.advancedBy(-7))
                        questions.append(interviewText)
                        let question = Question(string: interviewText, context: self.sharedContext)
                        question.company = self.company
                        
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
        

    }
    
    
    @IBAction func editQuestionAction(sender: AnyObject) {
        
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionTableViewController
        
        controller.questions = fetchedResultsController.fetchedObjects as! [Question]
        controller.company = company
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func interviewButton(sender: AnyObject) {
        recordTapped()
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            interviewButton.setTitle("Start Interview", forState: .Normal)
        } else {
            interviewButton.setTitle("Tap to stop", forState: .Normal)
            // recording failed :(
        }
    }
    
    func startRecording() {
        // start recording
        let audioURL = NSURL(fileURLWithPath:getDocumentsDirectory()).URLByAppendingPathComponent("recording.m4a")
        //            let audioURL = NSURL(fileURLWithPath: audioFilename)
        recordedAudio = audioURL
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            interviewButton.setTitle("Tap to stop", forState: .Normal)
            interviewButton.backgroundColor = UIColor(red: 1, green: 0.451, blue: 0.3765, alpha: 1.0)
            recordButton.setTitle("Recording", forState: .Normal)
            recordButton.backgroundColor = UIColor(red: 1, green: 0.451, blue: 0.3765, alpha: 1.0)
            
        } catch {
            finishRecording(success: false)
            print("error recording")
        }

    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
            recordButton.hidden = false
            UIView.animateWithDuration(1.0, animations: {
                self.recordButton.alpha = 1.0
            }, completion: nil)
            UIView.animateWithDuration(1.0, animations: {
                self.nextQButton.alpha = 1.0
                }, completion: nil)
            
            recordButton.enabled = false
            nextQ()
            if textToSpeechSwitch.on {
                textToSpeech()
            }
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(InterviewViewController.updateCounter), userInfo: nil, repeats: true)
        } else {
            finishRecording(success: true)
            recordButton.setTitle("Play recording", forState: .Normal)
            recordButton.enabled = true
            recordButton.backgroundColor = UIColor(red: 0.3059, green: 0.8078, blue: 0.4314, alpha: 1.0)
            
            timer.invalidate()
            counter = 0
            timerLabel.text = String(timeString(counter))
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            print("error recording")
        }
    }
    
    
    
    @IBAction func playRecording(sender: AnyObject) {
        
        if recordButton.titleLabel?.text == "Play recording" {
            do {
                let sound = try AVAudioPlayer(contentsOfURL: recordedAudio)
                recording = sound
                print("playing sound")
                sound.play()
            } catch {
                // couldn't load file :(
            }
            
            recordButton.setTitle("Stop", forState: UIControlState.Normal)
            recordButton.backgroundColor = UIColor(red: 1, green: 0.451, blue: 0.3765, alpha: 1.0)
        } else {
            if recording != nil {
                recording.stop()
                recording = nil
            }
            recordButton.setTitle("Play recording", forState: UIControlState.Normal)
            recordButton.backgroundColor = UIColor(red: 0.3059, green: 0.8078, blue: 0.4314, alpha: 1.0)
        }
        

        
    }
    
    
    func timeString(time:Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func updateCounter() {
        counter += 1
        timerLabel.text = timeString(counter)
    }
    
    @IBAction func nextQuestion(sender: AnyObject) {
        nextQ()
        if textToSpeechSwitch.on {
           textToSpeech()
        }
        
    }
    
    func nextQ() {
        if questionList.count == 0 {
            interviewText.text = "Congrats! You made it throught all the questions!, restart or add more questions "
        } else {
            let randomInt = Int(arc4random_uniform(UInt32(questionList.count)))
            let randomCompany = questionList[randomInt]
            questionList.removeAtIndex(randomInt)
            interviewText.text = randomCompany.text
        }
        
    }
    
    func textToSpeech() {
        myUtterance = AVSpeechUtterance(string: interviewText.text)
        myUtterance.rate = 0.5
        synth.speakUtterance(myUtterance)
    }
    
}