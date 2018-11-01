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
    let imagePicker = UIImagePickerController()
    var mainview: EditTaskViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainview = self
        imagePicker.delegate = self
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
            if self.taskImage.image != #imageLiteral(resourceName: "kisspng-question-mark-icon-question-mark-5a7214f2980a92.2259030715174259066228") {
                StorageEnclave.Access.changeImageOfTask(at: self.selectedTask!, to: (self.taskImage.image?.jpegData(compressionQuality: 0.25))!)
            }
            
            let done = UIAlertController(title: "Task Updated", message: "The task was updated successfully", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .default, handler: { _ in self.mainview!.goBack(self)})
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

extension EditTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "Error", message: "The camera cannot be accessed at this time.", preferredStyle: .actionSheet)
            let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertWarning.addAction(closeAction)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image
        taskImage.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        let cameraAlertController = UIAlertController(title: "Add Image", message: "Add a picture to your task.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ _ in
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        
        cameraAlertController.addAction(galleryAction)
        cameraAlertController.addAction(cameraAction)
        cameraAlertController.addAction(cancelAction)
        
        self.present(cameraAlertController, animated: true, completion: nil)
    }
}
