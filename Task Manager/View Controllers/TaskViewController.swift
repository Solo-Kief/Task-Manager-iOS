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
            inclusions = nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inclusions != nil {
            return inclusions!.count
        } else {
            return StorageEnclave.Access.taskCount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskCell
        let task: Task
        if inclusions != nil {
            task = StorageEnclave.Access.task(at: inclusions![indexPath.row])!
        } else {
            task = StorageEnclave.Access.task(at: indexPath.row)!
        }
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
        selectedTask = indexPath.row
        performSegue(withIdentifier: "editTaskSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action: UITableViewRowAction
        var altPath = indexPath
        
        if inclusions != nil {
            altPath.row = inclusions![indexPath.row]
        } //Overrides the normal set action with the inclusion setup.
        
        if StorageEnclave.Access.task(at: indexPath.row)?.status == .Incomplete {
            action = UITableViewRowAction(style: .normal, title: "Mark Complete") { (_, _) in
                StorageEnclave.Access.changeStatusOfTask(at: altPath.row)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } else {
            action = UITableViewRowAction(style: .normal, title: "Mark Incomplete") { (_, _) in
                StorageEnclave.Access.changeStatusOfTask(at: altPath.row)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            StorageEnclave.Access.deleteTask(at: altPath.row)
            self.inclusions?.remove(at: indexPath.row) //Needed to correct NSInternalInconsistencyException
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
