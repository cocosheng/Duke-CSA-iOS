//
//  AppTools.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/24/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation

struct AppTools {
    static func formatDateUserFriendly (date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        if calendar.isDateInToday(date) {
            return "Today " + formatter.stringFromDate(date)
        }
        
        if calendar.isDateInYesterday(date) {
            return "Yesterday " + formatter.stringFromDate(date)
        }
        
        if calendar.isDateInTomorrow(date) {
            return "Tomorrow " + formatter.stringFromDate(date)
        }
        if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: NSCalendarUnit.Year) {
            formatter.dateFormat = "MMM dd, h:mm a"
        }else {
            formatter.dateFormat = "MMM dd, h:mm a, yyyy"
        }
        //formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return formatter.stringFromDate(date)
    }
    static func formatDateBasic (date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return formatter.stringFromDate(date)
    }
    static func formatDateWithWeekDay (date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd, E, h:mm a"
        return formatter.stringFromDate(date)
    }
    static func capitalizeFirstLetter (s:String) -> String {
        var str = s
        str.replaceRange(str.startIndex...str.startIndex, with: String(str[str.startIndex]).capitalizedString)
        return str
    }
    
    static func getTrimmedString(text:String!) -> String {
        if text == nil {
            return ""
        }
        var trimmedStr = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        trimmedStr = trimmedStr.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        return trimmedStr
    }
    
    static func stringIsValid(text:String!) -> Bool{
        if text == nil{
            return false
        }
        var trimmedStr = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        trimmedStr = trimmedStr.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if trimmedStr == "" {
            return false
        }
        return true
    }
    
    static func netIDIsValid(text:String!) -> Bool{
        if text == nil{
            return false
        }
        var trimmedStr = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        trimmedStr = trimmedStr.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if trimmedStr == "" {
            return false
        }
        trimmedStr = trimmedStr.lowercaseString
        var prevC:Character = " "
        for c in trimmedStr.characters{
            if "a"<=c && c<="z" {
                if "0"<=prevC && prevC<="9" { // letter after number, invalid
                    return false
                }
                prevC = c
                continue
            }
            if "0"<=c && c<="9" {
                if prevC == " " { // start with number, invalid
                    return false
                }
                prevC = c
                continue
            }
            return false
        }
        return true
    }
    
    static func emailIsValid(text:String!) -> Bool{
        if text == nil {
            return false
        }
        var trimmedStr = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        trimmedStr = trimmedStr.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if trimmedStr.characters.count <= 0 {
            return false
        }
        let i = trimmedStr.rangeOfString("@", options: [], range: nil, locale: nil)
        let j = trimmedStr.rangeOfString(".", options: [], range: nil, locale: nil)
        let c1 = trimmedStr[trimmedStr.endIndex.predecessor()]
        let c2 = trimmedStr[trimmedStr.startIndex]
        if i != nil && j != nil && c1 != "@" && c1 != "." && c2 != "@" && c2 != "." {
            return true
        }else{
            return false
        }
    }
    
    static func compressImage(img:UIImage?) -> UIImage?{
        if let image = img {
            let newSize = CGSizeMake(120, 120)
            UIGraphicsBeginImageContext(newSize);
            image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return nil
        }
    }
    
    static func compareUserIsOrderedBefore(u1 u1:ExContact, u2:ExContact) -> Bool{
        let name1 = u1.displayName
        let name2 = u2.displayName
        
        // weird names fall behind
        if getLastName(name1) == "" {
            return false
        }else if getLastName(name2) == "" {
            return true
        }else {
            return getLastName(name1).compare(getLastName(name2)).rawValue < 0
        }
    }
    
    static func getLastName(name: String) -> String {
        let index = name.rangeOfString(" ", options: .BackwardsSearch)?.endIndex
        if let index = index {
            return name.substringWithRange(Range<String.Index>(index..<name.endIndex))
        }
        else {
            return ""
        }
    }
    
    static func getNamePivot(name: String) -> String {
        let lastName = getLastName(name)
        if lastName != "" {
            return lastName.substringWithRange(Range<String.Index>(lastName.startIndex..<lastName.startIndex.advancedBy(1)))
        }
        else {
            return "-"
        }
    }
    
    static func compareQAPostIsOrderedBefore(p1 p1: QAPost, p2: QAPost) -> Bool{
        let vote1 = p1.vote
        let vote2 = p2.vote
        let time1 = p1.postTime
        let time2 = p2.postTime
        
        if (AppStatus.QAStatus.order == .Vote) {
            if (vote1 > vote2) {
                return true
            }
            else if (vote1 < vote2) {
                return false
            }
        }
        let compare = time1.compare(time2).rawValue
        if (compare > 0) {
            return true
        }
        else {
            return false
        }
    }
    
    static func compareCourseIsSearchedBefore(c1: Course, c2: Course) -> Bool{
        let searchText = AppData.ClassData.searchText
        let lowerCase = searchText.lowercaseString
        let containsNumber1 = c1.number.lowercaseString.containsString(lowerCase)
        let containsName1 = c1.name.lowercaseString.containsString(lowerCase)
        let containsNumber2 = c2.number.lowercaseString.containsString(lowerCase)
        let containsName2 = c2.name.lowercaseString.containsString(lowerCase)
        if (containsNumber1 && !containsNumber2) {
            return true
        } else if (containsNumber2 && !containsNumber1) {
            return false
        } else if (containsNumber1 && containsNumber2) {
            return c1.number.lowercaseString < c2.number.lowercaseString
        } else if (containsName1 && !containsName2) {
            return true
        } else if (containsName2 && !containsName1) {
            return false
        }
        return true
    }
}
