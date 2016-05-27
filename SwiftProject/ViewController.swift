//
//  ViewController.swift
//  SwiftProject
//
//  Created by MacBook on 25/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import UIKit
import Haneke

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var loaderView: UIVisualEffectView!    //Blur Loader view
    var gistObjectsArray:[RequestManager.GistObject] = [] //A array of gists objects, used for render collections
    var pageCounter = 0 //Current Page of request
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Layout ajustment
        self.renderLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide Navigationbar
        self.navigationController?.navigationBarHidden = true
    }
    
    func renderLayout() {
        
        //Configure cellsize to form square
        let cellSize: CGFloat = (self.view.frame.size.width / 2) - 3;
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2
        
        //Request to get gist and display on complete
        RequestManager.getDataFromGist(pageCounter, completion: { (result) in
            
            //Success Handle
            let resultArray:[RequestManager.GistObject] = result!
            self.gistObjectsArray = resultArray
            self.loaderView.alpha = 0;
            self.mainCollectionView.reloadData()
            
        }) { (error) in

            //Load offline contents if internet is offline
            self.loaderView.alpha = 0;
            self.loadOfflineContent()
        };
        
        //render collectionView
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.setCollectionViewLayout(layout, animated: false)
        mainCollectionView!.registerNib(UINib(nibName: "NSCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        mainCollectionView.showsVerticalScrollIndicator = false;
    }
    
    func loadOfflineContent() {
        
        //reset Array
        gistObjectsArray = []
        
        //Get gists from coredata
        CoreDataManager.getJsonFromCore({ (result) in
            
            for gistResult in result {
                
                let jsonFile  = gistResult.valueForKey("jsonFile")
                var jsonOnwer = gistResult.valueForKey("jsonOwner");
                let jsonID    = gistResult.valueForKey("jsonID");
                
                if jsonOnwer == nil {
                    jsonOnwer = NSNull()
                }
                
                //Create a new raw Gist object
                var gistObject = RequestManager.GistObject (data: ["": ""])
                gistObject.files = jsonFile! as AnyObject as? NSDictionary
                gistObject.owner = jsonOnwer! as AnyObject as? NSDictionary
                gistObject.id    = jsonID! as AnyObject as? String
                
                self.gistObjectsArray.append(gistObject)
            }

            self.mainCollectionView.reloadData()
            
        }) { (error) in
            //Error Handle - Error from Coredata
            let alert = UIAlertController(title: "Error", message:error.description, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }
    }
    
    // MARK: UICollectionView DataSources
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gistObjectsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: NSCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! NSCell

        cell.layoutIfNeeded() //Layout ajustments
        
        //Start render information to layout
        let gistObject = self.gistObjectsArray[indexPath.row]
        let ownerObject = gistObject.owner
        let fileObject  = gistObject.files
        
        //Description of Gist
        for keyString in (fileObject?.allKeys)! {
            
            let file = fileObject?[keyString as! String]
            let typeString = file!["type"] is NSNull ? "Unknown" :(file!["type"] as? String)!
            let langageString = file!["language"] is NSNull ? "Unknown" :(file!["language"] as? String)!

            cell.typeLabel.text = String(format: "%@ - %@", typeString, langageString)

        }
        
        //User Name
        cell.userNameLabel.text = ownerObject == nil ? "Unknown" : ownerObject!["login"] as? String
        
        //User Image
        let userImageString = ownerObject == nil ? "Unknown" : ownerObject!["avatar_url"] as? String
        let userImageUrl = NSURL(string: userImageString!)
        cell.userImageView.image = UIImage(named: "Perfil")
        cell.userImageView.hnk_setImageFromURL(userImageUrl!) //Image Cache setting
        
        //Infinite Scroll
        if indexPath.row == self.gistObjectsArray.count - 1{
            
            UIView.animateWithDuration(0.4, animations: {
                self.loaderView.alpha = 1;
            })
            
            pageCounter = pageCounter + 1
            RequestManager.getDataFromGist(pageCounter, completion: { (result) in
                
                //Success Handle
                let resultArray:[RequestManager.GistObject] = result!
                self.gistObjectsArray += resultArray
                self.mainCollectionView.reloadData()
                self.loaderView.alpha = 0;
                
            }) { (error) in
                
                //Error Handle
                let alert = UIAlertController(title: "Alert", message: "Connect to the internet", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
                self.loaderView.alpha = 0;
            };
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController
        
        detailViewController?.gistObject = self.gistObjectsArray[indexPath.row]
        self.navigationController?.pushViewController(detailViewController!, animated: true)
    }
    
    // MARK: Main Class Methods
    
    //Hidden Status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}