//
//  ViewController.swift
//  Golden Hedgehog - Arcade
//
//  Created by Alexey Zelentsov on 06/08/2019.
//  Copyright © 2019 Alexey Zelentsov. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var timer = Timer()
    var hedgehogView : UIView!
    var animator = UIDynamicAnimator()
    var pushBehavior = UIPushBehavior()
    var holes = [UIView]()
    var leaves = [UIView]()
    var collisionBehaviour = UICollisionBehavior()
    let sizeOfHedgehog = CGSize(width: 50, height: 50)
    var sizeOfHole = CGSize(width: 50, height: 50)
    let sizeOfLeaf = CGSize(width: 20, height: 20)
    var currentScore = 0
    var level : Int = 1
    var record : Int = 0
    var howManyLeaves = 3
    
    var timerFired = false
    
    
    @IBOutlet weak var lblCurrent: UILabel!
    @IBOutlet weak var lblRecord: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let record = UserDefaults.standard.value(forKey: "UserRecord") as? Int {
            self.lblRecord.text = "Record: \(record)"
            self.record = record
        } else {
            UserDefaults.standard.set(0, forKey: "UserRecord")
        }
        
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vc = self
        if (vc.level > 5) && (vc.level <= 10) {
            //let offset = CGFloat(vc.level - 5) * 2.5
            //vc.sizeOfHole = CGSize(width: vc.sizeOfHole.width + offset, height: vc.sizeOfHole.height + offset)
            vc.howManyLeaves = 4
        } else if (vc.level > 10) {
            vc.howManyLeaves = 5
        }
        
        print(self.level)
        self.lblCurrent.text = "\(self.currentScore)"
        self.lblRecord.text = "Record: \(self.record)"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.checkRecord()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? SecondViewController {
            vc.currentScore =  self.currentScore
            vc.level = self.level + 1
            vc.record = self.record
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        let segue = GoingUpSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
        
    }
    
    func startGame() {
        self.btnPlay.isHidden = true
        
        self.lblRecord.isHidden = true
        
        self.createTimer()
        
        self.createAnimator()
        
        self.createCollisionBehavior()
        
        self.createPushBehavior()
        
        self.createTapGesture()
        
        self.createHolesAndLeaves(countOfHoles: 3, countOfLeaves: self.howManyLeaves)
        
        self.createAHedgehog()
        
        self.createFields()
        
        self.timerFired = false
    }
    
    
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(psevdoDelegate), userInfo: nil, repeats: true)
    }
    
    func createAnimator() {
        animator = UIDynamicAnimator(referenceView: self.view)
    }
    
    func createCollisionBehavior() {
        collisionBehaviour = UICollisionBehavior(items: [])
        collisionBehaviour.collisionDelegate = self
        collisionBehaviour.addBoundary(withIdentifier: "verticalMax" as NSCopying, for: UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)))
        collisionBehaviour.addBoundary(withIdentifier: "verticalMin" as NSCopying, for: UIBezierPath(rect: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 1)))
        collisionBehaviour.addBoundary(withIdentifier: "right" as NSCopying, for: UIBezierPath(rect: CGRect(x: self.view.frame.width, y: 0, width: 1, height: self.view.frame.height)))
        collisionBehaviour.addBoundary(withIdentifier: "left" as NSCopying, for: UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: self.view.frame.height)))
        collisionBehaviour.collisionMode = .boundaries
        animator.addBehavior(collisionBehaviour)
    }
    
    func createPushBehavior() {
        pushBehavior = UIPushBehavior(items: [], mode: .instantaneous)
        animator.addBehavior(pushBehavior)
    }
    
    func createTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(tap:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func createHolesAndLeaves(countOfHoles holes : Int, countOfLeaves leaves: Int) {
        var positions = [CGPoint]()
        let offset = sizeOfHedgehog.height >= sizeOfHole.height
            ? sizeOfHedgehog.height : sizeOfHole.height
        let count = holes + leaves
        while positions.count != count {
            let position = CGPoint(x: CGFloat.random(min: offset, max: self.view.frame.width - offset), y: CGFloat.random(min: offset, max: self.view.frame.height - offset))
            var append = true
            for i in 0..<positions.count {
                if CGPoint.distance(Between: position, and: positions[i]) <= 2*offset {
                    append = false
                }
            }
            if position.y > self.view.frame.height - 3*offset {
                append = false
            }
            if position.y < 3*offset {
                append = false
            }
            if append {
                positions.append(position)
            }
        }
        for i in 0..<holes {
            let hole = UIView(frame: CGRect(origin: positions[i], size: self.sizeOfHole))
            hole.backgroundColor = UIColor.black
            hole.layer.cornerRadius = self.sizeOfHole.width/2
            self.holes.append(hole)
            self.view.addSubview(hole)
        }
        for i in holes..<count {
            let leaf = UIView(frame: CGRect(origin: positions[i], size: self.sizeOfLeaf))
            leaf.backgroundColor = UIColor.green
            leaf.layer.cornerRadius = self.sizeOfLeaf.width/2
            self.leaves.append(leaf)
            self.view.addSubview(leaf)
        }
    }
    
    func createAHedgehog() {
        hedgehogView = UIView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2 - 25, y: self.view.frame.height - 55), size: sizeOfHedgehog))
        hedgehogView.backgroundColor = UIColor.blue
        hedgehogView.layer.cornerRadius = self.sizeOfHedgehog.width/2
        self.view.addSubview(hedgehogView)
        collisionBehaviour.addItem(hedgehogView)
        pushBehavior.addItem(hedgehogView)
    }
    
    func createFields() {
        for hole in holes {
            let field = UIFieldBehavior.radialGravityField(position: hole.center)
            field.region = UIRegion(radius: self.sizeOfHole.width)
            field.strength = 400/CGPoint.distance(Between: hole.center, and: self.hedgehogView.center )
            field.falloff = 5
            field.minimumRadius = self.sizeOfHole.width
            field.addItem(self.hedgehogView)
            self.animator.addBehavior(field)
        }
    }
    
    @objc func stopGame() {
        //self.timer.invalidate()
        self.timer = Timer()
        self.hedgehogView.removeFromSuperview()
        for hole in self.holes {
            hole.removeFromSuperview()
        }
        for leaf in self.leaves {
            leaf.removeFromSuperview()
        }
        self.holes = []
        self.leaves = []
        animator.removeAllBehaviors()
        self.view.gestureRecognizers = []
    }
    
    func checkRecord() {
        if self.currentScore > self.record {
            self.record = self.currentScore
            UserDefaults.standard.set(self.record, forKey: "UserRecord")
            self.lblRecord.text = "Record: \(self.record)"
        }
    }
    
    func checkRecordAndShowButton() {
        self.checkRecord()
        self.currentScore = 0
        self.lblCurrent.text = "0"
        
        self.btnPlay.isHidden = false
        
        self.lblRecord.isHidden = false
    }
    
    @objc func nextScreen() {
       // self.timer.invalidate()
        self.performSegue(withIdentifier: "segue", sender: self)
        self.perform(#selector(stopGame), with: nil, afterDelay: 1.5)
    }
    
    
    @objc func endGame() {
        
        self.timer.invalidate()
        self.stopGame()
        
        self.checkRecordAndShowButton()
        
    }

    
    @objc func psevdoDelegate() {
        for i in 0..<holes.count {
            if (CGPoint.distance(Between: holes[i].center, and: self.hedgehogView.center) <= self.sizeOfHole.width/2) {
                let snap =  UISnapBehavior(item: hedgehogView, snapTo: CGPoint(x: holes[i].center.x, y: holes[i].center.y))
                self.animator.addBehavior(snap)
                UIView.animate(withDuration: 1.5, animations: {
                    self.hedgehogView.alpha = 0
                    self.hedgehogView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    
                }) { (finish) in
                    if (finish) && (!self.timerFired) {
                        self.timerFired = true
                        self.perform(#selector(self.endGame), with: nil, afterDelay: 1.0)
                    }
                }
            }
        }
        if (leaves.count == 0) && (!self.timerFired){
            self.timerFired = true
            self.timer.invalidate()
            let snap = UISnapBehavior(item: self.hedgehogView, snapTo: self.hedgehogView.center)
            self.animator.addBehavior(snap)
            self.nextScreen()
        }
        for i in 0..<leaves.count {
            if CGPoint.distance(Between: leaves[i].center, and: self.hedgehogView.center) <= self.sizeOfHedgehog.width/2 {
                leaves[i].removeFromSuperview()
                leaves.remove(at: i)
                self.currentScore += 1
                self.lblCurrent.text = "\(currentScore)"
                break
            }
        }
    }


    @objc func tapped(tap : UITapGestureRecognizer) {
        let location = tap.location(in: self.view)
        let hedgehogCenter = hedgehogView.center
        let deltaX = location.x - hedgehogCenter.x
        let deltaY = location.y - hedgehogCenter.y
        pushBehavior.pushDirection = CGVector(dx: deltaX, dy: deltaY)
        
        pushBehavior.magnitude = 1
        pushBehavior.active = true
        self.perform(#selector(reverse), with: nil, afterDelay: 1)
       
    }
    
    @objc func reverse() {
        self.pushBehavior.magnitude = -2*self.pushBehavior.magnitude
        self.pushBehavior.active = true
    }
    
    
    @IBAction func btnPlayTapped(_ sender: UIButton) {
        self.startGame()
    }
    
    
    @IBAction func win(_ sender: UIButton) {
        self.currentScore += 3
        self.timerFired = true
        self.timer.invalidate()
        let snap = UISnapBehavior(item: self.hedgehogView, snapTo: self.hedgehogView.center)
        self.animator.addBehavior(snap)
        self.nextScreen()
    }
}
    
extension ViewController : UICollisionBehaviorDelegate {
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        let id = identifier as? String
        let it = item as? UIView
        let bounceMagnitude : CGFloat = 1
        if it == hedgehogView {
            if (id == "verticalMax") {
                pushBehavior.pushDirection = CGVector(dx: 0, dy: 1)
                pushBehavior.magnitude = bounceMagnitude
                pushBehavior.active = true
            } else if (id == "verticalMin") {
                pushBehavior.pushDirection = CGVector(dx: 0, dy: -1)
                pushBehavior.magnitude = bounceMagnitude
                pushBehavior.active = true
            } else if (id == "right") {
                pushBehavior.pushDirection = CGVector(dx: -1, dy: 0)
                pushBehavior.magnitude = bounceMagnitude
                pushBehavior.active = true
            } else if (id == "left") {
                pushBehavior.pushDirection = CGVector(dx: 1, dy: 0)
                pushBehavior.magnitude = bounceMagnitude
                pushBehavior.active = true
            }
        }
    }
}




