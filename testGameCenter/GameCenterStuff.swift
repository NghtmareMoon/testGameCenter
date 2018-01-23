//
//  GameCenterStuff.swift
//  testGameCenter
//
//  Created by David Boydston on 1/14/18.
//  Copyright © 2018 Boydston. All rights reserved.
//

import Foundation
import GameKit
import UIKit

class GameCenterStuff
{

    /*
     THIS CLASS WILL HANDLE ALL THE GAMECENTER STUFF INCLUDING AUTHENTIFICATION, WHICH SHOULD BE CALLED EVERYTIME THE APP RETURNS TO FOREFRONT. (VIA OBSERVERS). IF PLAYER FAILS TO AUTHENTICATE SEND TO HOME SCREEN.
     
     SO FAR THIS CLASS IS USELESS!
 */
    
    var gameCenterEnabled: Bool = false
    
    
    
    
    class func enableGameCenter() -> Bool
    {
        return true
    }
    
    init() {
        gameCenterEnabled = GameCenterStuff.enableGameCenter()
        
    }
}
