//
//  HomeVC.swift
//  testGameCenter
//
//  Created by David Boydston on 1/13/18.
//  Copyright © 2018 Boydston. All rights reserved.
//

import UIKit
import GameKit

class HomeVC: UIViewController {
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var leaderBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var xtraBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func leaderTapped(_ sender: Any) {
        //connect to game center and check leaderboard
    }
    
    @IBAction func challengeTapped(_ sender: Any) {
        //challenge a specific player to a game
    }
    
    @IBAction func xtraTapped(_ sender: Any) {
    }
    
    
    @IBAction func staratTapped(_ sender: Any) {
        // connect to a random player and start game.
        performSegue(withIdentifier: "startGameSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // login the player to Game Center and authenticate
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

