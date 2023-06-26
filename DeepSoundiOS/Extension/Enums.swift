//
//  Enums.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 25/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import Foundation

enum DashboardActionType: Int , CaseIterable {
    case suggested
    case topsongs
    case latestsongs
    case recentlyplayed
    case topalbums
    case popular
    case artists
    //case folders
    
    var type : String{
        switch self {
        case .suggested: return "Suggestion"
        case .topsongs: return "Top Songs"
        case .latestsongs: return "Latest Songs"
        case .recentlyplayed: return "Recently Played"
        case .topalbums: return "Top Albums"
        case .popular: return "Popular"
        case .artists: return "Artists"
        //case .folders: return "folders"
        }
    }
    
}
enum SuggestedSections : Int, CaseIterable {
   
    case topSongs
    case genres
    case latestsongs
    case resentlyplayed
    case popular
    case artist
    
    var cells: Int {
        switch self {
        case .genres:
            return 1
        default:
            return 1
        }
    }
}


enum SectionsforNotLogin : Int, CaseIterable {
   
    case login
    case topSongs
    case genres
    case latestsongs
    case resentlyplayed
    case popular
    case artist
    
    var cells: Int {
        switch self {
        case .genres:
            return 1
        default:
            return 1
        }
    }
}

enum ArtistInfoSections : Int, CaseIterable {
   
    case header
    case latestsongs
    case topsongs
    case playlist
    case store
    case event
    
    var cells: Int {
        switch self {
        case .header:
            return 1
        default:
            return 1
        }
    }
}
enum FilterData: Int,CaseIterable{
    
    case ascending = 0
    case descending
    case dateAdded
   
    
    var type : String{
        switch self {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        case .dateAdded:
            return "Date Added"
        }
    }
}
