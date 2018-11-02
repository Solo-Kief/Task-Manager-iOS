//  SettingsViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var changePassword: UIButton!
    @IBOutlet var resetData: UIButton!
    @IBOutlet var shownTasksSelector: UISegmentedControl!
    @IBOutlet var sortMethodSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !StorageEnclave.Access.isPasswordSet() {
            changePassword.setTitle("Set Password", for: .normal)
        }
        
        shownTasksSelector.layer.cornerRadius = 15.0
        shownTasksSelector.layer.borderColor = resetData.tintColor.cgColor
        shownTasksSelector.layer.borderWidth = 1.0
        shownTasksSelector.layer.masksToBounds = true
        sortMethodSelector.layer.cornerRadius = 15.0
        sortMethodSelector.layer.borderColor = resetData.tintColor.cgColor
        sortMethodSelector.layer.borderWidth = 1.0
        sortMethodSelector.layer.masksToBounds = true
        
        if StorageEnclave.Access.getSelectedStatus() != nil {
            shownTasksSelector.selectedSegmentIndex = StorageEnclave.Access.getSelectedStatus()!.rawValue + 1
        }
        if let method = StorageEnclave.Access.getSortMethod() {
            if method == .Low {
                sortMethodSelector.selectedSegmentIndex = 1
            } else {
                sortMethodSelector.selectedSegmentIndex = 2
            }
        }
    }
    
    //MARK:- Button Options
    
    @IBAction func setPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Change Password", message: "You are about to change your password. Are you sure you want to do this?", preferredStyle: .alert)
        if !StorageEnclave.Access.isPasswordSet() {
            alert.title = "Set Password"
            alert.message = "You are about to set an app password. If you set a password, you will need it each time you start the app. Are you sure you want to do this?"
        }
        
        alert.addTextField { TextField in
            if StorageEnclave.Access.isPasswordSet() {
                TextField.placeholder = "Current Password"
            } else {
                TextField.placeholder = "New Password"
            }
            
            TextField.isSecureTextEntry = true
            TextField.textAlignment = .center
        }
        
        alert.addTextField { TextField in
            if StorageEnclave.Access.isPasswordSet() {
                TextField.placeholder = "New Password"
            } else {
                TextField.placeholder = "Verify New Password"
            }
            
            TextField.isSecureTextEntry = true
            TextField.textAlignment = .center
        }
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let removePasswordAction = UIAlertAction(title: "Remove Password", style: .default) { _ in
            if !StorageEnclave.Access.unsetPassword(alert.textFields![0].text!) {
                let failure = UIAlertController(title: "Passoword Incorrect", message: "The password given was incorrect and the change was not made.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                failure.addAction(action)
                self.present(failure, animated: true, completion: nil)
            } else {
                self.changePassword.setTitle("Set Password", for: .normal)
            }
        }
        let changePasswordAction = UIAlertAction(title: "Change Password", style: .default) { _ in
            if StorageEnclave.Access.isPasswordSet() {
                if !StorageEnclave.Access.setPassword(from: alert.textFields![0].text, to: alert.textFields![1].text!) {
                    let failure = UIAlertController(title: "Passoword Incorrect", message: "The password given was incorrect and the change was not made.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    failure.addAction(action)
                }
            }
        }
        let setPasswordAction = UIAlertAction(title: "Set Password", style: .default) { _ in
            if alert.textFields![0].text! == alert.textFields![1].text! {
                StorageEnclave.Access.setPassword(from: nil, to: alert.textFields![1].text!)
                self.changePassword.setTitle("Change Password", for: .normal)
            } else {
                let failure = UIAlertController(title: "Passowords Don't Match", message: "The passwords given did not match, so the password was not set.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                failure.addAction(action)
                self.present(failure, animated: true, completion: nil)
            }
        }
        
        alert.addAction(cancelAction)
        if StorageEnclave.Access.isPasswordSet() {
            alert.addAction(removePasswordAction)
            alert.addAction(changePasswordAction)
        } else {
            alert.addAction(setPasswordAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetData(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All Data", message: "You are about to delete all stored data including all tasks and app settings. Are you sure you want to do this?", preferredStyle: .alert)
        if StorageEnclave.Access.isPasswordSet() {
            alert.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let argument: String?
            
            if StorageEnclave.Access.isPasswordSet() {
                argument = alert.textFields![0].text
            } else {
                argument = nil
            }
            
            if !StorageEnclave.Access.resetAllData(currentPassword: argument) {
                let failure = UIAlertController(title: "Passoword Was Incorrect", message: "The password given was incorrect, so the data was not reset.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                failure.addAction(action)
                self.present(failure, animated: true, completion: nil)
            } else {
                let success = UIAlertController(title: "Success", message: "All app data has been reset.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                success.addAction(action)
                self.present(success, animated: true, completion: nil)
                self.changePassword.setTitle("Set Password", for: .normal)
                self.shownTasksSelector.selectedSegmentIndex = 0
                self.sortMethodSelector.selectedSegmentIndex = 0
            }
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Other Options
    
    @IBAction func changeShownTasks(_ sender: UISegmentedControl) {
        switch shownTasksSelector.selectedSegmentIndex {
        case 1:
            StorageEnclave.Access.setSelectedStatus(to: .Incomplete)
        case 2:
            StorageEnclave.Access.setSelectedStatus(to: .Complete)
        default:
            StorageEnclave.Access.setSelectedStatus(to: nil)
        }
    }
    
    @IBAction func setSortMethod(_ sender: UISegmentedControl) {
        switch sortMethodSelector.selectedSegmentIndex {
        case 1:
            StorageEnclave.Access.setSortMethod(to: .Low)
        case 2:
            StorageEnclave.Access.setSortMethod(to: .High)
        default:
            StorageEnclave.Access.setSortMethod(to: nil)
        }
    }
    
    //MARK:- Return Button
    
    @IBAction func returnToTaskView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
