//  Storage Enclave.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import Foundation

class StorageEnclave: NSObject, NSCoding {
    //MARK:- Initial Values
    
    static let Access = StorageEnclave()
    private var password: String?
    private var passwordIsSet = false
    private var taskList: [Task] = []
    
    //MARK:- Setup
    
    private override init() {
        //
    }
    
    private init(password: String?, passwordIsSet: Bool, taskList: [Task]) {
        StorageEnclave.Access.password = password
        StorageEnclave.Access.passwordIsSet = passwordIsSet
        StorageEnclave.Access.taskList = taskList
    }
    
    internal required convenience init?(coder aDecoder: NSCoder) {
        let password = aDecoder.decodeObject(forKey: "name") as? String
        let passwordIsSet = aDecoder.decodeBool(forKey: "passwordIsSet")
        let taskList = aDecoder.decodeObject(forKey: "taskList") as! [Task]
        
        self.init(password: password, passwordIsSet: passwordIsSet, taskList: taskList)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.password , forKey: "password")
        aCoder.encode(self.passwordIsSet , forKey: "passwordIsSet")
        aCoder.encode(self.taskList , forKey: "taskList")
    }
    
    static func save() {
        let storedData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(storedData, forKey: "StorageEnclave")
    }

    static func load() -> StorageEnclave {
        let storedData = UserDefaults.standard.value(forKey: "StorageEnclave")
        let dataValues = NSKeyedUnarchiver.unarchiveObject(with: storedData as! Data)
        return dataValues as! StorageEnclave
    }

    //MARK:- Password Utility Functions
    
    func setPassword(from currentPassword: String, to newPassword: String) -> Bool {
        guard currentPassword == password else {return false}
        password = newPassword
        passwordIsSet = true
        return true
    }
    
    func verifyPassword(_ password: String) -> Bool {
        return password == self.password
    }
    
    func unsetPassword(_ currentPassword: String) -> Bool {
        guard currentPassword == password else {return false}
        password = nil
        passwordIsSet = false
        return true
    }
    
    func isPasswordSet() -> Bool {
        return passwordIsSet
    }
    
    //MARK:- Task Utility and Access Functions
    
    func task(at index: Int) -> Task? {
        guard (taskList.count) > 0 && index < (taskList.count) else {return nil}
        
        return taskList[index]
    }
    
    func taskCount() -> Int {
        return taskList.count
    }
    
    func addTask(_ task: Task) {
        taskList.append(task)
    }
    
    func changeNameOfTask(at index: Int, to name: String) {
        taskList[index].name = name
    }
    
    func changeDescriptionOfTask(at index: Int, to newDescription: String) {
        taskList[index].Tdescription = newDescription
    }
    
    func changeStatusOfTask(at index: Int) {
        if taskList[index].status == .Incomplete {
            taskList[index].status = .Complete
        } else {
            taskList[index].status = .Incomplete
        }
    }
    
    func changePriorityOfTask(at index: Int, to priority: Task.Priority) {
        taskList[index].priority = priority
    }
    
    func changeFinishDateOfTask(at index: Int, to finishDate: Date) {
        taskList[index].finishDate = finishDate
    }
    
    func printTask(at index: Int) {
        let format = DateFormatter(); format.dateFormat = "MM/dd/yyyy"
        
        Swift.print("Task Name: \(taskList[index].name)\nStatus: \(taskList[index].status)\nPriority: \(taskList[index].priority)\nFinish By: \(format.string(from: taskList[index].finishDate))\nDescription: \(taskList[index].Tdescription)")
    }
}
