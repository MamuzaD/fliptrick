//
//  ViewController.swift
//  FlipTrick
//
//  Created by Daniel Mamuza on 4/22/25.
//

import UIKit
import CoreMotion

struct Move {
    var move: String
    var points: Int
    var multiplier: Double
}

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: - View Controller
    
    let motionManager = CMMotionManager()
    var score = 0
    
    var multiplier: Double = 1.0
    
    var lastTrickTime: Date = Date.distantPast
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentMultiplierLabel: UILabel!
    @IBOutlet weak var movesTable: UITableView!
    @IBOutlet weak var decayLabel: UILabel!
    
    // Each move: (move name, points, multiplier)
    var moveHistory: [Move] = []
    
    func updateMultiplierLabel() {
        currentMultiplierLabel.text = "x\(String(format: "%.1f", multiplier))"
        if multiplier > 3 {
            currentMultiplierLabel.textColor = .systemRed
        } else if multiplier > 2 {
            currentMultiplierLabel.textColor = .systemOrange
        } else if multiplier > 1 {
            currentMultiplierLabel.textColor = .systemYellow
        } else {
            currentMultiplierLabel.textColor = .label
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "0"
        movesTable.dataSource = self
        movesTable.delegate = self
        movesTable.isScrollEnabled = false
        movesTable.layer.cornerRadius = 10.0
        movesTable.clipsToBounds = true
        
        updateMultiplierLabel()
        startGame()
    }
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        decayTimer?.invalidate()
        countdownTimer?.invalidate()
        let alert = UIAlertController(
            title: "Paused",
            message: "Want to save your game and restart?",
            preferredStyle: .actionSheet
        )
        // save || restart
        alert.addAction(UIAlertAction(title: "Save & Restart", style: .default, handler: { _ in
            GameManager.shared.saveGame(score: self.score
            )
            self.startGame()
        }))
        // more info
        alert.addAction(UIAlertAction(title: "More Info", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let infoAlert = UIAlertController(
                title: "About FlipTrick",
                message:
                    """
                    
                    - Earn points by flipping, spinning, or rotating your phone in different ways.
                    
                    - Chain unique tricks together to build combos and boost your multiplier.
                    
                    - Stay active—if you pause for too long, your score will start to decay!
                    
                    How high can you score before time and gravity catch up?
                    """,
                preferredStyle: .alert
            )
            infoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(infoAlert, animated: true, completion: nil)
        }))
        // cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func startGame() {
        // state updates
        score = 0
        multiplier = 1.0
        cumulativePitchRate = 0
        cumulativeRollRate = 0
        cumulativeYawRate = 0
        
        // ui
        moveHistory.removeAll()
        scoreLabel.text = "0"
        movesTable.reloadData()
        updateMultiplierLabel()
        decayLabel.text = ""
        
        // gyro
        startGyroUpdates()
        
        // decay
        decayTimer?.invalidate()
        decayStartTime = nil
        countdownTimer?.invalidate()
    }
    
    
    func startGyroUpdates() {
        print("startGyroUpdates called")
        
        if motionManager.isDeviceMotionAvailable {
            print("Device motion is available")
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion else { return }
                self?.processMotion(motion)
            }
        }
        else {
            print("Device motion is NOT available")
        }
    }
    
    // MARK: Core Logic for Motion
    var cumulativePitchRate: Double = 0
    var cumulativeRollRate: Double = 0
    var cumulativeYawRate: Double = 0
    
    
    func processMotion(_ motion: CMDeviceMotion) {
        let dt = motionManager.deviceMotionUpdateInterval // 0.02 seconds
        
        // Integrate rotation rate (radians/sec) over time to get total rotation (radians)
        cumulativePitchRate += motion.rotationRate.x * dt
        cumulativeRollRate  += motion.rotationRate.y * dt
        cumulativeYawRate   += motion.rotationRate.z * dt
        
        // Spin 360 (Yaw)
        if abs(cumulativeYawRate) > 2 * .pi {
            if cumulativeYawRate > 0 {
                registerMove("Rotate L→R 360°", points: 200)
            } else {
                registerMove("Rotate R→L 360°", points: 200)
            }
            cumulativeYawRate = 0
        }
        // Side Flip 360 (Roll)
        else if abs(cumulativeRollRate) > 2 * .pi {
            if cumulativeRollRate > 0 {
                registerMove("Side Flip L→R 360°", points: 200)
            } else {
                registerMove("Side Flip R→L 360°", points: 200)
            }
            cumulativeRollRate = 0
        }
        // Front/Back Flip 360 (Pitch)
        else if abs(cumulativePitchRate) > 2 * .pi {
            if cumulativePitchRate > 0 {
                registerMove("Front Flip T→B 360°", points: 200)
            } else {
                registerMove("Back Flip B→T 360°", points: 200)
            }
            cumulativePitchRate = 0
        }
    }
    
    
    // MARK: Register Moves
    
    // combo variables
    var lastMove: String?
    var repeatStreak: Int = 0
    var comboTimer: Timer?
    let comboTimeout: TimeInterval = 3.0
    
    func registerMove(_ move: String, points: Int) {
        print("Move detected: \(move)")
        let earned = Int(Double(points) * multiplier)
        score += earned
        moveHistory.insert(Move(move: move, points: earned, multiplier: multiplier), at: 0)
        
        // @TODO: refactor combo/multiplier logic
        if move == lastMove {
            repeatStreak += 1
        } else {
            repeatStreak = 1
        }
        lastMove = move
        if repeatStreak > 3 {
            multiplier = 1.0
        } else {
            multiplier += 1.0
        }
        
        scoreLabel.text = "\(score)"
        // animation-begin
        movesTable.beginUpdates()
        movesTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        movesTable.endUpdates()
        // animation-end
        
        // necessary for gradience
        if let visibleRows = movesTable.indexPathsForVisibleRows {
            let rowsToReload = visibleRows.filter { $0.row != 0 }
            movesTable.reloadRows(at: rowsToReload, with: .none)
        }
        
        updateMultiplierLabel()
        
        // reset combo after timeout
        comboTimer?.invalidate()
        comboTimer = Timer.scheduledTimer(withTimeInterval: comboTimeout, repeats: false) { [weak self] _ in
            self?.multiplier = 1.0
            self?.updateMultiplierLabel()
        }
        
        resetDecayTimer()
    }
    
    // MARK: - Decay logic
    
    var decayTimer: Timer?
    var decayStartTime: Date?
    let decayDelay: TimeInterval = 5.0
    let decayInterval: TimeInterval = 0.3
    
    var countdownTimer: Timer?
    let countdownStartDelay: TimeInterval = 2.0
    let countdownSeconds: Int = 3
    var countdownRemaining: Int = 0
    
    func resetDecayTimer() {
        decayTimer?.invalidate()
        countdownTimer?.invalidate()
        decayStartTime = nil
        decayLabel.text = ""
        
        decayTimer = Timer.scheduledTimer(withTimeInterval: countdownStartDelay, repeats: false) { [weak self] _ in
            self?.startCountdown()
        }
    }
    
    func startCountdown() {
        countdownRemaining = countdownSeconds
        decayLabel.text = "\(countdownRemaining)"
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.countdownRemaining -= 1
            if self.countdownRemaining > 0 {
                self.decayLabel.text = "\(self.countdownRemaining)"
            } else {
                timer.invalidate()
                self.decayLabel.text = "decaying..."
                self.startDecay()
            }
        }
    }
    
    func startDecay() {
        decayStartTime = Date()
        decayTimer?.invalidate()
        decayTimer = Timer.scheduledTimer(withTimeInterval: decayInterval, repeats: true) { [weak self] _ in
            self?.applyDecay()
        }
    }
    
    func applyDecay() {
        guard let start = decayStartTime else { return }
        let t = Date().timeIntervalSince(start)
        let decay = Int(3 * log(t + 1))
        if score > 0 {
            score = max(0, score - decay)
            scoreLabel.text = "\(score)"
        } else {
            decayTimer?.invalidate()
            decayLabel.text = ""
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moveHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveCell", for: indexPath) as! MoveCell
        let move = moveHistory[indexPath.row]
        cell.moveLabel.text = move.move
        cell.pointsLabel.text = "+\(move.points)"
        cell.multiplierLabel.text = "x\(String(format: "%.1f", move.multiplier))"
        
        // diff colors based on multiplier
        if move.multiplier > 3 {
            cell.multiplierLabel.textColor = .systemRed
        } else if move.multiplier > 2 {
            cell.multiplierLabel.textColor = .systemOrange
        } else if move.multiplier > 1 {
            cell.multiplierLabel.textColor = .systemYellow
        } else {
            cell.multiplierLabel.textColor = .label
        }
        
        // gradient
        let total = max(moveHistory.count - 1, 1)
        let fraction = CGFloat(indexPath.row) / CGFloat(total)
        let startColor = UIColor.systemBlue
        let endColor = UIColor.systemBackground
        cell.backgroundColor = startColor.interpolate(to: endColor, fraction: fraction)
        
        
        return cell
    }
}


extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
    func interpolate(to color: UIColor, fraction: CGFloat) -> UIColor {
        let f = min(max(0, fraction), 1)
        let c1 = self.rgba
        let c2 = color.rgba
        return UIColor(
            red: c1.red + (c2.red - c1.red) * f,
            green: c1.green + (c2.green - c1.green) * f,
            blue: c1.blue + (c2.blue - c1.blue) * f,
            alpha: c1.alpha + (c2.alpha - c1.alpha) * f
        )
    }
}
