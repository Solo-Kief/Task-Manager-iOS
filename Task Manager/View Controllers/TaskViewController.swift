//  TaskViewController.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 10/30/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import UIKit

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var selectedTask: Int?
    var inclusions: [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        inclusionUpdater()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inclusionUpdater()
        tableView.reloadData()
    }
    
    func inclusionUpdater() { //Keeps a list of all tasks that meet this condition
        switch StorageEnclave.Access.getSelectedStatus() {
        case .Complete?:
            inclusions = StorageEnclave.Access.returnAllComplete()
        case .Incomplete?:
            inclusions = StorageEnclave.Access.returnAllIncomplete()
        default:
            inclusions = StorageEnclave.Access.returnAll()
        }
        
        switch StorageEnclave.Access.getSortMethod() {
        case .High?:
            inclusions!.sort { (value1, value2) -> Bool in
                return StorageEnclave.Access.task(at: value1)!.priority.rawValue > StorageEnclave.Access.task(at: value2)!.priority.rawValue
            }
        case .Low?:
            inclusions!.sort { (value1, value2) -> Bool in
                return StorageEnclave.Access.task(at: value1)!.priority.rawValue < StorageEnclave.Access.task(at: value2)!.priority.rawValue
            }
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inclusions!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskCell
        let task = StorageEnclave.Access.task(at: inclusions![indexPath.row])!
        
        let format = DateFormatter()
        format.dateStyle = .short
        
        cell.taskName.text = task.name
        
        cell.taskStatus.text = "Finish by: \(format.string(from: task.finishDate))\n"
        switch task.priority {
        case .Low:
            cell.taskStatus.text = "\(cell.taskStatus.text!)Priority: Low"
        case .Normal:
            cell.taskStatus.text = "\(cell.taskStatus.text!)Priority: Normal"
        case.High:
            cell.taskStatus.text = "\(cell.taskStatus.text!)Priority: High"
        }
        
        switch task.status {
        case .Complete:
            cell.taskCondition.text = "✓"
            cell.taskCondition.backgroundColor = UIColor.green
        case .Incomplete:
            cell.taskCondition.text = "X"
            cell.taskCondition.backgroundColor = UIColor.red
        }
        
        if task.image != nil {
            cell.taskImage.image = UIImage(data: task.image!)
        }
        
        cell.taskName.layer.borderWidth = 1
        cell.taskStatus.layer.borderWidth = 1
        cell.taskCondition.layer.borderWidth = 1
        cell.taskImage.layer.borderWidth = 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = inclusions![indexPath.row]
        performSegue(withIdentifier: "editTaskSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action: UITableViewRowAction
        var altPath = indexPath
        
        altPath.row = inclusions![indexPath.row]
        
        if StorageEnclave.Access.task(at: indexPath.row)?.status == .Incomplete {
            action = UITableViewRowAction(style: .normal, title: "Mark Complete") { (_, _) in
                StorageEnclave.Access.changeStatusOfTask(at: altPath.row)
                if StorageEnclave.Access.getSelectedStatus() == .Incomplete {
                    self.inclusionUpdater()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        } else {
            action = UITableViewRowAction(style: .normal, title: "Mark Incomplete") { (_, _) in
                StorageEnclave.Access.changeStatusOfTask(at: altPath.row)
                if StorageEnclave.Access.getSelectedStatus() == .Complete {
                    self.inclusionUpdater()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            StorageEnclave.Access.deleteTask(at: altPath.row)
            self.inclusionUpdater() //Needed to correct NSInternalInconsistencyException
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [delete, action]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditTaskViewController {
            destination.selectedTask = selectedTask
        }
    }
}

class TaskCell: UITableViewCell {
    @IBOutlet var taskImage: UIImageView!
    @IBOutlet var taskName: UILabel!
    @IBOutlet var taskStatus: UILabel!
    @IBOutlet var taskCondition: UILabel!
}
