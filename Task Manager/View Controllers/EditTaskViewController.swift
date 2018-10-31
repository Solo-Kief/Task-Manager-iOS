//  EditTaskViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/31/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class EditTaskViewController: UIViewController {
    @IBOutlet var taskImage: UIImageView!
    @IBOutlet var taskImageButton: UIButton!
    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskPriority: UISegmentedControl!
    @IBOutlet var taskDescription: UITextView!
    @IBOutlet var taskDate: UIDatePicker!
    @IBOutlet var editTask: UIButton!
    
    var selectedTask: Int?
    var taskInQuesiton: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        taskPriority.layer.cornerRadius = 15.0
        taskPriority.layer.borderColor = editTask.tintColor.cgColor
        taskPriority.layer.borderWidth = 1.0
        taskPriority.layer.masksToBounds = true
        
        taskInQuesiton = StorageEnclave.Access.task(at: selectedTask!)
        
        taskName.text = taskInQuesiton!.name
        taskPriority.selectedSegmentIndex = taskInQuesiton!.priority.rawValue
        taskDescription.text = taskInQuesiton!.Tdescription
        taskDate.date = taskInQuesiton!.finishDate
        taskDate.minimumDate = Date()
        if taskInQuesiton!.image != nil {
            taskImage.image = UIImage(data: taskInQuesiton!.image!)
        }
    }
    
    @IBAction func updateTask(_ sender: Any) {
        let alert = UIAlertController(title: "Update Task", message: "You are about to modify your existing task. Are you sure you want to do this?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.taskName.text = self.taskInQuesiton!.name
            self.taskPriority.selectedSegmentIndex = self.taskInQuesiton!.priority.rawValue
            self.taskDescription.text = self.taskInQuesiton!.Tdescription
            self.taskDate.date = self.taskInQuesiton!.finishDate
            if self.taskInQuesiton!.image != nil {
                self.taskImage.image = UIImage(data: self.taskInQuesiton!.image!)
            }
        }
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            StorageEnclave.Access.changeNameOfTask(at: self.selectedTask!, to: self.taskName.text!)
            StorageEnclave.Access.changePriorityOfTask(at: self.selectedTask!, to: Task.Priority(rawValue: self.taskPriority.selectedSegmentIndex)!)
            StorageEnclave.Access.changeDescriptionOfTask(at: self.selectedTask!, to: self.taskDescription.text!)
            StorageEnclave.Access.changeFinishDateOfTask(at: self.selectedTask!, to: self.taskDate.date)
            
            let done = UIAlertController(title: "Task Updated", message: "The task was updated successfully", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .default, handler: nil)
            done.addAction(cancel)
            self.present(done, animated: true, completion: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(updateAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
