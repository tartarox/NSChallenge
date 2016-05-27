//
//  DetailViewController.swift
//  SwiftProject
//
//  Created by Fabio Yudi Takahara on 26/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DetailViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    
    var gistObject: RequestManager.GistObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Navigationbar
        self.navigationController?.navigationBarHidden = false
        
        //Ajust Layout
        self.renderLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Render userImage
        self.userImageView.layoutIfNeeded()
        self.userImageView.clipsToBounds = true;
        self.userImageView.layer.cornerRadius = self.userImageView.bounds.width / 2
    }
    
    func renderLayout() {
        
        //Start render information to layout
        let ownerObject = gistObject.owner
        let fileObject  = gistObject.files
        let idString  = gistObject.id
        
        //Description of Gist
        for keyString in (fileObject?.allKeys)! {
            
            let file = fileObject?[keyString as! String]
            let typeString = file!["type"] is NSNull ? "Unknown" :(file!["type"] as? String)!
            let langageString = file!["language"] is NSNull ? "Unknown" :(file!["language"] as? String)!
            
            descriptionLabel.text = String(format: "%@ - %@", typeString, langageString)
            
            //Get Complete Gist Raw
            let gistUrl = file!["raw_url"] as! String
            
            let url = NSURL(string: gistUrl)
            let request = NSURLRequest(URL: url!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.activityIndicatorView.hidden = true
                    
                    if (data != nil) {
                        
                        //Handle Success
                        
                        self.textField.text = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                        self.activityIndicatorView.stopAnimating()
                        
                        //Save string to coredata ---------------------------------------------
                        CoreDataManager.saveContentToCore(idString!, content: self.textField.text, completion: { (result) in
                            //Content did saved
                        })
                        
                    } else {
                        
                        //Handle Error - Offline
                        //Get content from Coredata ---------------------------------------------
                        CoreDataManager.getContentFromCore(idString!, completion: { (result) in
                            
                            for content in result {
                                self.textField.text = content.valueForKey("gistContent") as! String;
                            }
                            
                            self.activityIndicatorView.stopAnimating()
                            
                            //Failed to get information from Coredata
                            }, failed: { (error) in
                                
                                let alert = UIAlertController(title: "Error", message:error.description, preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                                self.presentViewController(alert, animated: true){}
                        })
                    }
                })
            }
            task.resume()
        }
        
        //User Name
        nameLabel.text = ownerObject == nil ? "Unknown" : ownerObject!["login"] as? String
        
        //User Image
        let userImageString = ownerObject == nil ? "Unknown" : ownerObject!["avatar_url"] as? String
        let userImageUrl = NSURL(string: userImageString!)
        userImageView.hnk_setImageFromURL(userImageUrl!) //Image Cache setting
    }
}