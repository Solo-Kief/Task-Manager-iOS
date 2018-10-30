//  Storage Enclave.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import Foundation

class StorageEnclave: NSObject, NSCoding {
    //MARK:- Initial Values
    
    static let Access = StorageEnclave() //Singleton for app wide data.
    private var password: String?
    private var passwordIsSet = false
    private var taskList: [Task] = []
    
    //MARK:- Setup
    
    private override init() {
        if let storedData = UserDefaults.standard.value(forKey: "StorageEnclave") {
            let enclave = NSKeyedUnarchiver.unarchiveObject(with: storedData as! Data) as! StorageEnclave
            
            password = enclave.password
            passwordIsSet = enclave.passwordIsSet
            taskList = enclave.taskList
        }
    } //Initializer performs the functions usually performed by as load() function to automatically load saved data.
    
    private init(password: String?, passwordIsSet: Bool, taskList: [Task]) {
        self.password = password
        self.passwordIsSet = passwordIsSet
        self.taskList = taskList
    } //Generates a temporary storage enclave to be passed to the main init()
    
    internal required convenience init?(coder aDecoder: NSCoder) {
        let password = aDecoder.decodeObject(forKey: "name") as? String
        let passwordIsSet = aDecoder.decodeBool(forKey: "passwordIsSet")
        let taskList = aDecoder.decodeObject(forKey: "taskList") as! [Task]
        
        self.init(password: password, passwordIsSet: passwordIsSet, taskList: taskList)
    } //Called by the unarchiver to decode stored data, then generate a temporary storage enclave to populate the singleton.
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.password , forKey: "password")
        aCoder.encode(self.passwordIsSet , forKey: "passwordIsSet")
        aCoder.encode(self.taskList , forKey: "taskList")
    } //Provides a method for encoding stored data.
    
    static func save() {
        let storedData = NSKeyedArchiver.archivedData(withRootObject: Access)
        UserDefaults.standard.set(storedData, forKey: "StorageEnclave")
    } //Encodes and archives existing data to be recalled later.

    //MARK:- Password Utility Functions
    
    func setPassword(from currentPassword: String, to newPassword: String) -> Bool {
        guard currentPassword == password else {return false}
        password = newPassword
        passwordIsSet = true
        StorageEnclave.save()
        return true
    }
    
    func verifyPassword(_ password: String) -> Bool {
        return password == self.password
    }
    
    func unsetPassword(_ currentPassword: String) -> Bool {
        guard currentPassword == password else {return false}
        password = nil
        passwordIsSet = false
        StorageEnclave.save()
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
        StorageEnclave.save()
    }
    
    func changeNameOfTask(at index: Int, to name: String) {
        taskList[index].name = name
        StorageEnclave.save()
    }
    
    func changeDescriptionOfTask(at index: Int, to newDescription: String) {
        taskList[index].Tdescription = newDescription
        StorageEnclave.save()
    }
    
    func changeStatusOfTask(at index: Int) {
        if taskList[index].status == .Incomplete {
            taskList[index].status = .Complete
        } else {
            taskList[index].status = .Incomplete
        }
        StorageEnclave.save()
    }
    
    func changePriorityOfTask(at index: Int, to priority: Task.Priority) {
        taskList[index].priority = priority
        StorageEnclave.save()
    }
    
    func changeFinishDateOfTask(at index: Int, to finishDate: Date) {
        taskList[index].finishDate = finishDate
        StorageEnclave.save()
    }
    
    func printTask(at index: Int) {
        let format = DateFormatter(); format.dateFormat = "MM/dd/yyyy"
        
        Swift.print("Task Name: \(taskList[index].name)\nStatus: \(taskList[index].status)\nPriority: \(taskList[index].priority)\nFinish By: \(format.string(from: taskList[index].finishDate))\nDescription: \(taskList[index].Tdescription)")
    } //Custom format print statement from the original task class. Probably won't be used in this program.
}
