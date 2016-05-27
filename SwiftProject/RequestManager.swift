//
//  RequestManager.swift
//  SwiftProject
//
//  Created by Fabio Yudi Takahara on 26/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import Foundation
import Alamofire
import JSONHelper

let httpUrl: String = "https://api.github.com/gists/public"

class RequestManager
{
    struct GistObject: Deserializable {
        
        var files: NSDictionary?
        var id : String?
        var owner: NSDictionary?
        
        init(data: [String: AnyObject]) {
            
            files <-- data["files"]
            id <-- data["id"]
            owner <-- data["owner"]
        }
    }
    
    class func getDataFromGist(page: NSInteger, completion: (result: [GistObject]?) -> Void, failed: (error: NSError) -> Void)
    {
        Alamofire.request(.GET, httpUrl, parameters: ["page": page])
            .responseJSON { response in switch response.result {
            case .Success(let JSON):

                //Success Handle
                var gistObjects: [GistObject]?
                gistObjects <-- JSON
                completion(result: gistObjects)
                
                //Save to Coredata for offline
                let gistObjectsArray:[RequestManager.GistObject] = gistObjects!
                for saveGistObject in gistObjectsArray {
                    
                    let gistID = saveGistObject.id
                    
                    //Check if current object is saved on Coredata already
                    CoreDataManager.getSingleJsonFromCore(gistID!, completion: { (result) in
                        
                        //Dont exist this item on Coredata
                        if result.count == 0 {
                            
                            //Save current object on Coredata
                            CoreDataManager.saveJsonToCore(saveGistObject, completion: { (result) in
                                
                            })
                        }
                    }, failed: { (error) in
                        //Handle error - error to save Gist to Coredata
                })
            }
                
            case .Failure(let error):
                
                //Error Handle
                failed(error: error)
                }
        }
    }
}