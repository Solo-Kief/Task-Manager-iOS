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
        let password = aDecoder.decodeObject(forKey: "password") as? String
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
    
    func setPassword(from currentPassword: String?, to newPassword: String) -> Bool {
        if !passwordIsSet {
            passwordIsSet = true
            password = newPassword
            StorageEnclave.save()
            return true
        }
        
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
    
    func deleteTask(at index: Int) {
        taskList.remove(at: index)
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
    
    //MARK:- Master Reset
    
    func resetAllData(currentPassword: String?) -> Bool {
        guard currentPassword == password else {return false}
        
        password = nil
        passwordIsSet = false
        taskList = []
        StorageEnclave.save()
        
        return true
    }
}
