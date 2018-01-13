//
//  ViewController.swift
//  testGameCenter
//
//  Created by David Boydston on 1/12/18.
//  Copyright © 2018 Boydston. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    
    
    /*
     TESTING GAMECENTER: THIS GAME WILL CONNECT UP TO 4 PLAYERS. TURN BASED GAME
     EACH TURN ONE PLAYER CAN CLICK BUTTON A OR B AND THEN END HIS TURN
     LOG WILL BE DISPLAYED: PLAYER X CLICKED A 10 TIMES AND B 20 TIMES AND TOOK X SECONDS FOR HIS TURN
     GAME WILL END AFTER EACH PLAYER HAS HAD 2 TURNS
     TEST CONNECTIVITY AND HOW TURN BASED GAMES WORK.
     
     MAIN THINGS TO TEST:
     - GAMEKIT AUTHENTICATION
     - GAMEKIT NETWORK INTERFACE (TURN-BASED GAMES)
     - UPDATING GAMES, ARE THEY SAVED IN GAMEKIT CLOUD OR DO THEY NEED TO BE STORED IN PHONE?
     
 */
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var gameLog: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    var aTaps: Int?
    var bTaps: Int?
    var logString: String = ""
    
    @IBAction func aTapped(_ sender: Any) {
        aTaps! += 1
    }
    
    @IBAction func bTapped(_ sender: Any) {
        bTaps! += 1
    }
    
    @IBAction func endTapped(_ sender: Any) {
        logString += "Player LOCALPLAYER tapped A \(aTaps!) times and B \(bTaps!) times \n"
        gameLog.text = logString
    }
    
    
    func startTurn()
    {
        aTaps = 0
        bTaps = 0
        logString += "** Player LOCALPLAYER begun his turn **\n"
        gameLog.text = logString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startTurn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

