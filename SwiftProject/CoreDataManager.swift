//
//  CoreDataManager.swift
//  SwiftProject
//
//  Created by Fabio Yudi Takahara on 27/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager
{
    //MARK: Save to Coredata -----------------------------------------------------------------------
    //Save Json content
    class func saveJsonToCore(gistObject: RequestManager.GistObject, completion: (result: Bool) -> Void)
    {
        let ownerObject = gistObject.owner
        let fileObject  = gistObject.files
        let gistId      = gistObject.id
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Json", inManagedObjectContext:managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        person.setValue(gistId, forKey: "jsonID")
        person.setValue(ownerObject, forKey: "jsonOwner")
        person.setValue(fileObject, forKey: "jsonFile")
        
        do {
            try managedContext.save()
            completion(result: true)
            
        } catch let error as NSError  {
            print(error)
            completion(result: false)
        }
    }
    
    //Save complete Gist
    class func saveContentToCore(id: String, content: String, completion: (result: Bool) -> Void)
    {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Content", inManagedObjectContext:managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        person.setValue(id, forKey: "gistID")
        person.setValue(content, forKey: "gistContent")
        
        do {
            try managedContext.save()
            completion(result: true)
            
        } catch let error as NSError  {
            print(error)
            completion(result: false)
        }
    }
    
    //MARK: Get from Coredata -----------------------------------------------------------------------
    //Get Json Content
    class func getJsonFromCore(completion: (result: NSArray) -> Void, failed: (error: NSError) -> Void)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Json")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let jsonArrayResult = results as! [NSManagedObject]
            completion(result: jsonArrayResult)
            
        } catch let error as NSError {
            failed(error:error)
        }
    }
    
    //Get single Json Content
    class func getSingleJsonFromCore(id: String, completion: (result: NSArray) -> Void, failed: (error: NSError) -> Void)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Json")
        let idPredicate = NSPredicate(format: "jsonID = %@", id)
        fetchRequest.predicate = idPredicate
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let jsonArrayResult = results as! [NSManagedObject]
            completion(result: jsonArrayResult)
            
        } catch let error as NSError {
            failed(error:error)
        }
    }
    
    //Get Complete Gist
    class func getContentFromCore(id: String, completion: (result: NSArray) -> Void, failed: (error: NSError) -> Void)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Content")
        
        let idPredicate = NSPredicate(format: "gistID = %@", id)
        fetchRequest.predicate = idPredicate
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let jsonArrayResult = results as! [NSManagedObject]
            completion(result: jsonArrayResult)
            
        } catch let error as NSError {
            failed(error:error)
        }
    }
}