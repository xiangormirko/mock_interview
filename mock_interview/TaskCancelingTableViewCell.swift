//
//  TaskCancelingTableViewCell.swift
//  mock_interview
//
//  Created by MIRKO on 4/27/16.
//  Copyright © 2016 XZM. All rights reserved.
//

import Foundation
import UIKit

class TaskCancelingTableViewCell : UITableViewCell {
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var imageName: String = ""
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}

