//
//  SearchTextField.swift
//  Edumate
//
//  Created by Rodrigo Mantica on 8/30/16.
//  Copyright © 2016 Rodrigo Mantica. All rights reserved.
//

import UIKit

@objc protocol SearchTextFieldDelegate {
    func dataForPopoverInTextField(_ textfield: SearchTextField) -> [NSDictionary]
    
    @objc optional func textFieldDidEndEditing(_ textField: SearchTextField, withSelection data: NSDictionary)
    @objc optional func textFieldShouldSelect(_ textField: SearchTextField) -> Bool
}

    private var tableViewController : UITableViewController?
    private var data = [NSDictionary]()
    private var filteredData = [NSDictionary]()


@IBDesignable class SearchTextField: UITextField, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    // Set this to override the default corner radius of the textfield
    @IBInspectable var cornerRadius : Int = 0 {
        didSet {
            self.layer.cornerRadius = CGFloat(self.cornerRadius)
        }
    }
    
    //Set this to override the default color of suggestions popover. The default color is [UIColor colorWithWhite:0.99 alpha:0.99]
    @IBInspectable var popoverBackgroundColor : UIColor = UIColor(white: 1, alpha: 0.97)
    
    //Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
    @IBInspectable var popoverSize : CGRect?
    
    //Set this to override the default seperator color for tableView in search results. The default color is light gray.
    @IBInspectable var seperatorColor : UIColor = UIColor(white: 0.50, alpha: 0.25)
    
    var searchDelegate : SearchTextFieldDelegate?
    var index = Int()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let str : String = self.text!
        if (str.characters.count > 0) && (self.isFirstResponder) {
            if (self.searchDelegate != nil) {
                data = self.searchDelegate!.dataForPopoverInTextField(self)
                self.provideSuggestions()
            } else {
                print("<SearchTextField> WARNING: You have not implemented the required methods of the SearchTextField protocol.")
            }
        } else {
            if let table = tableViewController {
                if table.tableView.superview != nil{
                    table.tableView.removeFromSuperview()
                    tableViewController = nil
                }
            }
        }
    }
    
    override func resignFirstResponder() -> Bool {
        if tableViewController != nil {
            UIView.animate(withDuration: 0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 0.0
                                       }),
                                       completion:{
                                        (finished : Bool) in
                                        if tableViewController != nil {
                                            tableViewController!.tableView.removeFromSuperview()
                                            tableViewController = nil
                                        }
            })
            self.handleExit()
        }
        
        return super.resignFirstResponder()
    }
    
    func provideSuggestions() {
        self.applyFilterWithSearchQuery(self.text!)
        if let _ = tableViewController {
            tableViewController!.tableView.reloadData()
        } else if filteredData.count > 0 {
            //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.cancelsTouchesInView = false
            tapRecognizer.delegate = self
            self.superview!.addGestureRecognizer(tapRecognizer)
            
            tableViewController = UITableViewController()
            tableViewController!.tableView.delegate = self
            tableViewController!.tableView.dataSource = self
            tableViewController!.tableView.backgroundColor = self.popoverBackgroundColor
            tableViewController!.tableView.separatorColor = self.seperatorColor
            
            if let frameSize = self.popoverSize {
                tableViewController!.tableView.frame = frameSize
            } else {
                //PopoverSize frame has not been set. Use default parameters instead.
                var frameForPresentation = self.frame
                frameForPresentation.origin.y += self.frame.size.height
                frameForPresentation.size.height = 200
                tableViewController!.tableView.frame = frameForPresentation
            }
            
            // Show table view on top of other subviews
            let aView = tableViewController!.tableView
            var frame = aView?.frame
            
            frame?.origin = self.superview!.convert((frame?.origin)!, to: nil)
            aView?.frame = frame!
            
            self.window!.addSubview(aView!)
            
            // Animate table view appearance
            tableViewController!.tableView.alpha = 0.0
            UIView.animate(withDuration: 0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 1.0
                                       }),
                                       completion:{
                                        (finished : Bool) in
                                        
            })
        }
        
    }
    
    func tapped (_ sender : UIGestureRecognizer!) {
        if let table = tableViewController {
            if !table.tableView.frame.contains(sender.location(in: self.superview)) && self.isFirstResponder {
                self.resignFirstResponder()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredData.count
        if count == 0 {
            UIView.animate(withDuration: 0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 0.0
                                       }),
                                       completion: {
                                        (finished : Bool) in
                                        if let table = tableViewController {
                                            table.tableView.removeFromSuperview()
                                            tableViewController = nil
                                        }
            })
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "resultsCell")
        }
        // Customize separator width
        tableView.separatorInset = UIEdgeInsets.zero
        cell?.separatorInset = UIEdgeInsets.zero
        cell?.layoutMargins = UIEdgeInsets.zero
        cell?.preservesSuperviewLayoutMargins = false
        // Customize cells
        cell?.backgroundColor = UIColor.clear
        let dataForRowAtIndexPath = filteredData[indexPath.row]
        let displayText = dataForRowAtIndexPath["Text"]
        cell?.textLabel!.text = displayText as? String
        cell?.textLabel!.font = cell!.textLabel?.font.withSize(15)
        cell?.textLabel?.textColor = UIColor.darkText
        if let displaySubText = dataForRowAtIndexPath["detailText"] {
            cell?.detailTextLabel!.text = displaySubText as? String
            cell?.detailTextLabel?.textColor = UIColor.gray
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        self.resignFirstResponder()
    }
    
    
    // Mark: Filter Method
    
    func applyFilterWithSearchQuery(_ filter : String) -> Void {
        let matchingData = data.filter( {
            if let match = $0["Text"] {
                return (match as! NSString).lowercased.hasPrefix((filter as NSString).lowercased)
            } else {
                return false
            }
        })
        
        filteredData = matchingData
    }
    
    func handleExit() {
        if let table = tableViewController {
            table.tableView.removeFromSuperview()
        }
        if ((searchDelegate?.textFieldShouldSelect?(self)) != nil) {
            if filteredData.count > 0 {
                let selectedData = filteredData[self.index]
                let displayText = selectedData["Text"]
                self.text = displayText as? String
                searchDelegate?.textFieldDidEndEditing?(self, withSelection: selectedData)
            } else {
                searchDelegate?.textFieldDidEndEditing?(self, withSelection: ["Text":self.text!])
            }
        }
        
    }
    
}
