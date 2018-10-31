//  Task.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import Foundation

class Task: NSObject, NSCoding {
    internal var name: String
    internal var Tdescription: String
    internal var status: Status
    internal var finishDate: Date
    internal var priority: Priority
    internal var image: Data?
    
    internal enum Status: Int, Codable {
        case Incomplete = 0
        case Complete = 1
    }
    
    internal enum Priority: Int, Codable {
        case Low = 0
        case Normal = 1
        case High = 2
    }
    
    func encode(with aCoder: NSCoder) { //Used to encode a Task object to be saved.
        aCoder.encode(self.name , forKey: "name")
        aCoder.encode(self.Tdescription, forKey: "description")
        aCoder.encode(self.status.rawValue, forKey: "status")
        aCoder.encode(self.finishDate, forKey: "finishDate")
        aCoder.encode(self.priority.rawValue, forKey: "priority")
        aCoder.encode(self.image, forKey: "image")
    }
    
    init(Name: String, Description: String, finishBy timeToComplete: Date, priority: Priority, image: Data?) { //Normal Initializer
        self.name = Name
        self.Tdescription = Description
        self.status = .Incomplete
        self.finishDate = timeToComplete
        self.priority = priority
        self.image = image
    }
    
    private init(name: String, description: String, priorityRawValue: Int, finishDate: Date?, statusRawValue: Int, image: Data?) { //Initializer used for loading a saved task.
        self.name = name
        self.Tdescription = description
        self.status = Status(rawValue: statusRawValue)!
        self.priority = Priority(rawValue: priorityRawValue)!
        self.finishDate = finishDate!
        self.image = image
    }
    
    convenience required init?(coder aDecoder: NSCoder) { //Used to decode and initialize a saved task.
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let description = aDecoder.decodeObject(forKey: "description") as! String
        let status = aDecoder.decodeInteger(forKey: "status")
        let finishDate = aDecoder.decodeObject(forKey: "finishDate") as! Date?
        let priority = aDecoder.decodeInteger(forKey: "priority")
        let image = aDecoder.decodeObject(forKey: "iamge") as! Data?
        self.init(name: name, description: description, priorityRawValue: priority, finishDate: finishDate, statusRawValue: status, image: image)
    }
    
    
//    static func save(tasks: [Task]) {
//        let storedTasks = NSKeyedArchiver.archivedData(withRootObject: tasks)
//        UserDefaults.standard.set(storedTasks, forKey: "storedTasks")
//    }
//
//    static func load() -> [Task] {
//        let storedTasks = UserDefaults.standard.value(forKey: "storedTasks")
//        let taskArray = NSKeyedUnarchiver.unarchiveObject(with: storedTasks as! Data)
//        return taskArray as! [Task]
//    }
}

