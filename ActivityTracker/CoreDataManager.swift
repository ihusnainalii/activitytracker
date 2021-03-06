//
//  CoreDataManager.swift
//  ActivityTracker
//
//  Created by macintosh on 12/21/18.
//  Copyright © 2018 macintosh. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class CoreDataManager {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static var sharedInstance = CoreDataManager()
    
    private init() {
        
    }
    
    func saveActivities(id:Int64, imageUrl:NSData, title:String, description:String, date:String,  timeHH:Int16, timeMM:Int16, timeSS:Int16, totalTime:Int64, isRunning:Bool) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let mediaEntity = NSEntityDescription.entity(forEntityName: "Activity", in: context)
        let newActivity = NSManagedObject(entity: mediaEntity!, insertInto: context)
        newActivity.setValue(imageUrl, forKey: "image")
        newActivity.setValue(id, forKey: "id")
        newActivity.setValue(title, forKey: "title")
        newActivity.setValue(description, forKey: "descriptions")
        newActivity.setValue(date, forKey: "dueDate")
        newActivity.setValue(timeHH, forKey: "timeHH")
        newActivity.setValue(timeMM, forKey: "timeMM")
        newActivity.setValue(timeSS, forKey: "timeSS")
        newActivity.setValue(totalTime, forKey: "totalTime")
        newActivity.setValue(isRunning, forKey: "isRunning")
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
            return false
        }
        return true
    }
    func saveCheckList(id:String, task:String, parentActivityID:Int64, isDone:Bool) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let Entity = NSEntityDescription.entity(forEntityName: "CheckList", in: context)
        let newCheckList = NSManagedObject(entity: Entity!, insertInto: context)
        
        newCheckList.setValue(task, forKey: "task")
        newCheckList.setValue(id, forKey: "id")
        newCheckList.setValue(parentActivityID, forKey: "parentActivityId")
        newCheckList.setValue(isDone, forKey: "isDone")
        
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
            return false
        }
        return true
    }
    
    func fetchActivities() -> [Activities]{
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.returnsObjectsAsFaults = false
        var activity:[Activities] = []
        
        do {
            let result = try context.fetch(request)
            activity = []
            for data in result as! [NSManagedObject] {
                let id:Int64 = data.value(forKey: "id") as! Int64
                let stringURL:NSData = data.value(forKey: "image") as! NSData
                let titleString:String = data.value(forKey: "title") as! String
                let typeString:String = data.value(forKey: "descriptions") as! String
                let date:String = data.value(forKey: "dueDate") as! String
                let timeHH:Int16 = data.value(forKey: "timeHH") as! Int16
                let timeMM:Int16 = data.value(forKey: "timeMM") as! Int16
                let timeSS:Int16 = data.value(forKey: "timeSS") as! Int16
                let totalTime:Int64 = data.value(forKey: "totalTime") as! Int64
                let isRunning:Bool = data.value(forKey: "isRunning") as! Bool
                let newActivity:Activities = Activities(id: id, title: titleString, url: stringURL, description: typeString, date:date, timeHH:timeHH, timeMM: timeMM, timeSS: timeSS, totalTime: totalTime, isRunning: isRunning )
                activity.append(newActivity)
                
            }
        } catch {
            print("Failed")
            
            return []
        }
        return activity
    }
    
    
    func fetchCheckListForActivity(activityId:Int64) -> [CheckListModel]{
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckList")
        request.predicate = NSPredicate(format: "parentActivityId == %@", NSNumber(value: activityId))
        request.returnsObjectsAsFaults = false
        var taskList:[CheckListModel] = []
        
        do {
            let result = try context.fetch(request)
            taskList = []
            for data in result as! [NSManagedObject] {
                let task:String = data.value(forKey: "task") as! String
                let id:String = data.value(forKey: "id") as! String
                let parentActivityId:Int64 = data.value(forKey: "parentActivityId") as! Int64
                let isDone:Bool = data.value(forKey: "isDone") as! Bool
                
                let newtask:CheckListModel = CheckListModel(id: id, task: task, parentActivityId: parentActivityId, isDone: isDone)
                taskList.append(newtask)
            }
        } catch {
            print("Failed")
            
            return []
        }
        return taskList
    }
    
    
    func fetchCountOfCheckListForActivity(activityId:Int64) -> (Int, Int){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckList")
        request.predicate = NSPredicate(format: "parentActivityId == %@", NSNumber(value: activityId))
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            let totalCount:Int = result.count
            var doneCount:Int = 0
            for data in result as! [NSManagedObject] {
                let done:Bool = data.value(forKey: "isDone") as! Bool
                if done {
                    doneCount = doneCount+1
                }
            }
            return (doneCount, totalCount)
        } catch {
            print("Failed")
           return(0,0)
        }
    }
    
    
    func updateDoneStatusCheckList(checkid:String, status:Bool) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckList")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %@", checkid)
        
        do {
            let results = try context.fetch(request) as? [NSManagedObject]
            if results?.count != 0 {
                //let totalTime:Bool = results?[0].value(forKey: "isDone") as! Bool
                results?[0].setValue(status, forKey: "isDone")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    
    
    

func getRunningActivity() -> [Activities] {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "isRunning == %@", NSNumber(value: true))
    var activity:[Activities] = []
    
    do {
        let result = try context.fetch(request)
        activity = []
        for data in result as! [NSManagedObject] {
            let id:Int64 = data.value(forKey: "id") as! Int64
            let stringURL:NSData = data.value(forKey: "image") as! NSData
            let titleString:String = data.value(forKey: "title") as! String
            let typeString:String = data.value(forKey: "descriptions") as! String
            let date:String = data.value(forKey: "dueDate") as! String
            let timeHH:Int16 = data.value(forKey: "timeHH") as! Int16
            let timeMM:Int16 = data.value(forKey: "timeMM") as! Int16
            let timeSS:Int16 = data.value(forKey: "timeSS") as! Int16
            let totalTime:Int64 = data.value(forKey: "totalTime") as! Int64
            let isRunning:Bool = data.value(forKey: "isRunning") as! Bool
            let newActivity:Activities = Activities(id: id, title: titleString, url: stringURL, description: typeString, date:date, timeHH:timeHH, timeMM: timeMM, timeSS: timeSS, totalTime: totalTime, isRunning: isRunning )
            activity.append(newActivity)
        }
    } catch {
        print("Failed")
        
        return []
    }
    return activity
    
    
}


func updateTimerCurrentRunningActivity(id:Int64) {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
    
    do {
        let results = try context.fetch(request) as? [NSManagedObject]
        if results?.count != 0 {
            let totalTime:Int64 = results?[0].value(forKey: "totalTime") as! Int64
            results?[0].setValue(totalTime+1, forKey: "totalTime")
        }
    } catch {
        print("Fetch Failed: \(error)")
    }
    
    do {
        try context.save()
    }
    catch {
        print("Saving Core Data Failed: \(error)")
    }
}


func updateActivityRunningStatus(id:Int64) {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
    
    do {
        let results = try context.fetch(request) as? [NSManagedObject]
        if results?.count != 0 {
            let isRun:Bool = results?[0].value(forKey: "isRunning") as! Bool
            results?[0].setValue(!isRun, forKey: "isRunning")
        }
    } catch {
        print("Fetch Failed: \(error)")
    }
    
    do {
        try context.save()
    }
    catch {
        print("Saving Core Data Failed: \(error)")
    }
}

}
