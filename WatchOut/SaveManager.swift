//
//  SaveManager.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

//************************************
// MARK: - Saved movies
//************************************

class SavedMovies: NSObject {
    
    static func save(movie:WOMovie) {
        
        var sMovies = movies
        if !sMovies.contains(movie) {
            sMovies.append(movie)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sMovies), forKey: "savedMovies")
        
    }
    
    static func unsave(movie:WOMovie) {
        
        var sMovies = movies
        
        if sMovies.contains(movie) {
            sMovies.remove(movie)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sMovies), forKey: "savedMovies")
        
    }
    
    static var movies:[WOMovie] {
        
        if let savedMovie = UserDefaults.standard.data(forKey: "savedMovies") {
            
            if let movies = NSKeyedUnarchiver.unarchiveObject(with: savedMovie) as? [WOMovie] {
                
                return movies
            }
            else {
                print("no saved movies")
            }
            
        }
        return []
    }
  
}

//************************************
// MARK: - Saved Persons
//************************************

class SavedPersons: NSObject {
    
    
    static let identifier = "savedPersons"
    
    static func save(_ person:WOPerson) {
        
        var sPersons = persons
        if !sPersons.contains(person) {
            sPersons.append(person)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sPersons), forKey: identifier)
        
    }
    
    static func unsave(_ person:WOPerson) {
        
        var sPersons = persons
        
        if sPersons.contains(person) {
            sPersons.remove(person)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sPersons), forKey: identifier)
        
    }
    
    
    
    static var persons:[WOPerson] {
        
        if let savedPersons = UserDefaults.standard.data(forKey: identifier) {
            
            if let persons = NSKeyedUnarchiver.unarchiveObject(with: savedPersons) as? [WOPerson] {
                
                return persons
            }
            else {
                print("no saved persons")
            }
            
        }
        return []
    }
    
}

//************************************
// MARK: - Member Cards
//************************************

class SavedMemberCards: NSObject {
    
    //************************************
    // MARK: - Member Cards Data Base
    //************************************
    
    static func saveBaseMemberCard(_ card:WOMemberCard) {
        
        var sCards = savedBaseMemberCard
        if !sCards.contains(card) {
            sCards.append(card)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sCards), forKey: "savedBaseMemberCards")
        
    }
    
    static var savedBaseMemberCard:[WOMemberCard] {
        
        if let savedCards = UserDefaults.standard.data(forKey: "savedBaseMemberCards") {
            
            if let cards = NSKeyedUnarchiver.unarchiveObject(with: savedCards) as? [WOMemberCard] {
                
                return cards
            }
            else {
                print("no saved savedBaseMemberCards")
            }
            
        }
        return []
    }
    
    //************************************
    // MARK: - User member Cards Data Base
    //************************************
    
    static func saveUserMemberCard(_ card:WOMemberCard) {
        
        var sCards = userMemberCard
        if !sCards.contains(card) {
            sCards.append(card)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sCards), forKey: "userMemberCards")
        
    }
    
    static func unsaveUserMemberCard(_ card:WOMemberCard) {
        
        var sCards = userMemberCard
        
        if sCards.contains(card) {
            sCards.remove(card)
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sCards), forKey: "userMemberCards")
        
    }
    
    static var userMemberCard:[WOMemberCard] {
        
        if let savedCards = UserDefaults.standard.data(forKey: "userMemberCards") {
            
            if let cards = NSKeyedUnarchiver.unarchiveObject(with: savedCards) as? [WOMemberCard] {
                
                return cards
            }
            else {
                print("no saved userMemberCards")
            }
            
        }
        return []
    }
    
    
}
