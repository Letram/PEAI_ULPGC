//
//  ViewController.swift
//  Proyect1
//
//  Created by Alumno on 13/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var p1ScoreLabel: UILabel!
    @IBOutlet weak var p2ScoreLabel: UILabel!
    @IBOutlet weak var accScoreLabel: UILabel!
    @IBOutlet weak var currentPlayerLabel: UILabel!
    @IBOutlet weak var collectBtn: UIButton!
    @IBOutlet weak var progressBar1: UIProgressView!
    @IBOutlet weak var progressBar2: UIProgressView!
    
    var currentPlayer = 1
    var accScore = 0
    var scores = [0,0]
    var rollsNumber = 0
    
    let goal = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        gameSetup()
    }

    @IBAction func onRollBtn(_ sender: UIButton) {
        let roll = arc4random_uniform(6) + 1
        accScore = accScore + Int(roll)
        if(!collectBtn.isEnabled){
            collectBtn.isEnabled = true
        }
        updateTexts()
    }
    
    @IBAction func onCollectBtn(_ sender: UIButton) {
        scores[currentPlayer-1] = accScore + scores[currentPlayer-1]
        currentPlayer = currentPlayer == 1 ? 2 : 1
        resetCounters()
        updateTexts()
    }
    
    func updateTexts(){
        currentPlayerLabel.text = "P" + currentPlayer.description
        accScoreLabel.text = accScore.description
        p1ScoreLabel.text = scores[0].description
        progressBar1.setProgress(Float((scores[0]/100)*100), animated: true)
        p2ScoreLabel.text = scores[1].description
        progressBar2.setProgress(Float((scores[1]/100)*100), animated: true)
        
    }
    func resetCounters(){
        accScore = 0
        collectBtn.isEnabled = false
    }
    func gameSetup(){
        //TODO disbling collectbtn is nil. 
        collectBtn.isEnabled = false
        progressBar1.setProgress(Float((scores[0]/100)*100), animated: false)
        progressBar2.setProgress(Float((scores[1]/100)*100), animated: false)
    }
}

