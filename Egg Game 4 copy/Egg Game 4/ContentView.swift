//
//  ContentView.swift
//  Egg Game 4
//
//  Created by Elliot Williams on 2025-07-02.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var game = EggGame()
    
    var body: some View {
        ZStack {
            // Background with animated gradient
            AnimatedGradientView()
                .ignoresSafeArea()
            
            // Game content based on current state
            switch game.gameState {
            case .start:
                StartView(game: game)
            case .playing:
                GameView(game: game)
            case .gameOver:
                GameOverView(game: game)
            }
        }
        .onAppear {
            game.setupAudio()
        }
    }
}

// MARK: - Game States

struct StartView: View {
    @ObservedObject var game: EggGame
    
    var body: some View {
        VStack {
            Text("Egg Game")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
                .padding(.bottom, 20)
            
            Text("Move the basket to catch the falling eggs!\nDon't let them fall or you'll lose lives.\nCatch as many eggs as you can to get the highest score!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            
            Button(action: {
                game.startGame()
            }) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .blue, .green]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GameView: View {
    @ObservedObject var game: EggGame
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sun
                SunView()
                    .position(x: geometry.size.width - 50, y: 50)
                
                // Clouds
                ForEach(0..<5) { i in
                    CloudView()
                        .position(
                            x: CGFloat(i) * (geometry.size.width / 4),
                            y: CGFloat(i) * 50 + 50
                        )
                }
                
                // Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Score: \(game.score)")
                    Text("Lives: \(game.lives)")
                    Text("Misses: \(game.misses)")
                    Text("Level: \(game.level)")
                    Text("Highest Level: \(game.highestLevel)")
                    Text("Eggs Stolen: \(game.stolenEggs)")
                    Text("Most Stolen: \(game.highestStolenEggs)")
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
                .padding(10)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                // Level up indicator
                if game.showLevelUp {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Eggs
                ForEach(game.eggs) { egg in
                    EggView(egg: egg)
                        .position(egg.position)
                }
                
                // Bunnies
                ForEach(game.bunnies) { bunny in
                    BunnyView(bunny: bunny)
                        .position(bunny.position)
                }
                
                // Basket
                BasketView()
                    .position(x: game.basketPosition, y: geometry.size.height - 50)
                
                // Sound toggle
                Button(action: {
                    game.toggleSound()
                }) {
                    Image(systemName: game.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
                .position(x: geometry.size.width - 40, y: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        game.basketPosition = value.location.x
                    }
            )
            .onAppear {
                game.screenSize = geometry.size
            }
        }
    }
}

struct GameOverView: View {
    @ObservedObject var game: EggGame
    
    var body: some View {
        VStack {
            Text("GAME OVER")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.red)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
                .padding(.bottom, 40)
            
            Text("Final Score: \(game.score)")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Button(action: {
                game.playAgain()
            }) {
                Text("Play Again")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .blue, .green]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Game Elements

struct EggView: View {
    let egg: EggGame.Egg
    
    var body: some View {
        Group {
            switch egg.pattern {
            case .solid:
                Ellipse()
                    .fill(egg.color)
                    .overlay(
                        Ellipse()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            case .striped:
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [egg.color, egg.stripeColor]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Ellipse()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            case .spotted:
                ZStack {
                    Ellipse()
                        .fill(egg.color)
                        .overlay(
                            Ellipse()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    
                    // Spots
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(egg.spotColor)
                            .frame(width: egg.size * 0.2, height: egg.size * 0.2)
                            .position(
                                x: CGFloat(i) * egg.size * 0.3 - egg.size * 0.3,
                                y: CGFloat(i) * egg.size * 0.2 - egg.size * 0.2
                            )
                    }
                }
            }
        }
        .frame(width: egg.size, height: egg.size * 1.3)
    }
}

struct BunnyView: View {
    let bunny: EggGame.Bunny
    
    var body: some View {
        Image(systemName: "hare.fill")
            .font(.system(size: 50))
            .foregroundColor(.white)
            .rotationEffect(.degrees(bunny.direction > 0 ? 0 : 180))
            .scaleEffect(bunny.size)
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

struct BasketView: View {
    var body: some View {
        ZStack {
            // Basket body
            Path { path in
                path.move(to: CGPoint(x: 10, y: 10))
                path.addLine(to: CGPoint(x: 90, y: 10))
                path.addLine(to: CGPoint(x: 100, y: 60))
                path.addLine(to: CGPoint(x: 0, y: 60))
                path.closeSubpath()
            }
            .fill(Color.pink)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Basket handle
            Path { path in
                path.move(to: CGPoint(x: 25, y: 10))
                path.addQuadCurve(
                    to: CGPoint(x: 75, y: 10),
                    control: CGPoint(x: 50, y: -20)
                )
            }
            .stroke(Color.pink, lineWidth: 8)
        }
        .frame(width: 100, height: 60)
    }
}

struct SunView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [.yellow, .orange]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 35
                ))
                .frame(width: 70, height: 70)
                .shadow(color: .yellow.opacity(0.8), radius: 20)
            
            // Sun rays
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 25)
                    .offset(y: -45)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}

struct CloudView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 60, height: 60)
                .offset(x: -20, y: 0)
            
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 70, height: 70)
                .offset(x: 0, y: -10)
            
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 60, height: 60)
                .offset(x: 20, y: 0)
        }
        .frame(width: 120, height: 60)
    }
}

struct AnimatedGradientView: View {
    @State private var gradientIndex = 0
    private let gradients = [
        Gradient(colors: [Color(red: 0.51, green: 0.64, blue: 0.83), Color(red: 0.71, green: 0.98, blue: 1.0)]),
        Gradient(colors: [Color(red: 0.71, green: 0.98, blue: 1.0), Color(red: 1.0, green: 0.82, blue: 1.0)]),
        Gradient(colors: [Color(red: 1.0, green: 0.82, blue: 1.0), Color(red: 1.0, green: 0.87, blue: 0.87)]),
        Gradient(colors: [Color(red: 1.0, green: 0.87, blue: 0.87), Color(red: 0.51, green: 0.64, blue: 0.83)]),
    ]
    
    var body: some View {
        LinearGradient(
            gradient: gradients[gradientIndex],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 8).repeatForever()) {
                gradientIndex = (gradientIndex + 1) % gradients.count
            }
        }
    }
}

// MARK: - Game Logic

class EggGame: ObservableObject {
    enum GameState {
        case start, playing, gameOver
    }
    
    struct Egg: Identifiable {
        let id = UUID()
        var position: CGPoint
        let size: CGFloat
        let color: Color
        let pattern: EggPattern
        let stripeColor: Color
        let spotColor: Color
        let speed: CGFloat
    }
    
    struct Bunny: Identifiable {
        let id = UUID()
        var position: CGPoint
        let direction: CGFloat // 1 for right, -1 for left
        let size: CGFloat
        let speed: CGFloat
    }
    
    enum EggPattern {
        case solid, striped, spotted
    }
    
    // Game state
    @Published var gameState: GameState = .start
    @Published var showLevelUp = false
    
    // Game stats
    @Published var score = 0
    @Published var lives = 3
    @Published var misses = 0
    @Published var level = 1
    @Published var highestLevel = 1
    @Published var stolenEggs = 0
    @Published var highestStolenEggs = 0
    
    // Game elements
    @Published var eggs: [Egg] = []
    @Published var bunnies: [Bunny] = []
    @Published var basketPosition: CGFloat = UIScreen.main.bounds.width / 2
    
    // Game settings
    var eggSpeed: CGFloat = 3
    var eggFrequency: TimeInterval = 2.0
    var bunnyFrequency: TimeInterval = 5.0
    var eggsNeededForNextLevel = 10
    
    // Screen size
    var screenSize: CGSize = UIScreen.main.bounds.size
    
    // Audio
    @Published var isMuted = false
    private var audioPlayer: AVAudioPlayer?
    private var backgroundPlayer: AVAudioPlayer?
    
    // Timers
    private var eggTimer: Timer?
    private var bunnyTimer: Timer?
    private var gameTimer: Timer?
    
    func startGame() {
        resetGame()
        gameState = .playing
        playSound("start")
        startBackgroundMusic()
        startTimers()
    }
    
    func playAgain() {
        startGame()
    }
    
    private func resetGame() {
        score = 0
        lives = 3
        misses = 0
        level = 1
        stolenEggs = 0
        eggs.removeAll()
        bunnies.removeAll()
        
        eggSpeed = 3
        eggFrequency = 2.0
        bunnyFrequency = 5.0
        eggsNeededForNextLevel = 10
        
        basketPosition = screenSize.width / 2
    }
    
    private func startTimers() {
        // Egg timer
        eggTimer?.invalidate()
        eggTimer = Timer.scheduledTimer(withTimeInterval: eggFrequency, repeats: true) { [weak self] _ in
            self?.createEgg()
        }
        
        // Bunny timer
        bunnyTimer?.invalidate()
        bunnyTimer = Timer.scheduledTimer(withTimeInterval: bunnyFrequency, repeats: true) { [weak self] _ in
            self?.createBunny()
        }
        
        // Game timer
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func createEgg() {
        guard gameState == .playing else { return }
        
        let size = CGFloat.random(in: 20...50)
        let x = CGFloat.random(in: 0...(screenSize.width - size))
        let pattern: EggPattern = [.solid, .striped, .spotted].randomElement()!
        let colors: [Color] = [.pink, .blue, .green, .purple, .yellow, .orange, .mint, .teal]
        let speed = eggSpeed * CGFloat.random(in: 1...2)
        
        let egg = Egg(
            position: CGPoint(x: x, y: -size),
            size: size,
            color: colors.randomElement()!,
            pattern: pattern,
            stripeColor: colors.randomElement()!,
            spotColor: colors.randomElement()!,
            speed: speed
        )
        
        eggs.append(egg)
    }
    
    private func createBunny() {
        guard gameState == .playing else { return }
        
        let startFromLeft = Bool.random()
        let x = startFromLeft ? -50 : screenSize.width + 50
        let y = screenSize.height - 100
        let direction: CGFloat = startFromLeft ? 1 : -1
        let size = CGFloat.random(in: 0.8...1.2)
        let speed = CGFloat.random(in: 2...4)
        
        let bunny = Bunny(
            position: CGPoint(x: x, y: y),
            direction: direction,
            size: size,
            speed: speed
        )
        
        bunnies.append(bunny)
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Move eggs
        for index in eggs.indices {
            eggs[index].position.y += eggs[index].speed
            
            // Check if egg is caught
            let eggRect = CGRect(
                x: eggs[index].position.x - eggs[index].size/2,
                y: eggs[index].position.y - eggs[index].size/2,
                width: eggs[index].size,
                height: eggs[index].size * 1.3
            )
            
            let basketRect = CGRect(
                x: basketPosition - 50,
                y: screenSize.height - 100,
                width: 100,
                height: 60
            )
            
            if eggRect.intersects(basketRect) {
                eggs.remove(at: index)
                caughtEgg()
                return
            }
            
            // Check if egg is missed
            if eggs[index].position.y > screenSize.height + 100 {
                eggs.remove(at: index)
                missedEgg()
                return
            }
        }
        
        // Move bunnies
        for index in bunnies.indices {
            bunnies[index].position.x += bunnies[index].speed * bunnies[index].direction
            
            // Check if bunny stole an egg
            for eggIndex in eggs.indices {
                let bunnyRect = CGRect(
                    x: bunnies[index].position.x - 25,
                    y: bunnies[index].position.y - 25,
                    width: 50,
                    height: 50
                )
                
                let eggRect = CGRect(
                    x: eggs[eggIndex].position.x - eggs[eggIndex].size/2,
                    y: eggs[eggIndex].position.y - eggs[eggIndex].size/2,
                    width: eggs[eggIndex].size,
                    height: eggs[eggIndex].size * 1.3
                )
                
                if bunnyRect.intersects(eggRect) {
                    eggs.remove(at: eggIndex)
                    stolenEgg()
                    bunnies.remove(at: index)
                    return
                }
            }
            
            // Remove bunny if off screen
            if bunnies[index].position.x < -100 || bunnies[index].position.x > screenSize.width + 100 {
                bunnies.remove(at: index)
                return
            }
        }
    }
    
    private func caughtEgg() {
        playSound("catch")
        score += 10
        
        // Level up check
        if score >= level * eggsNeededForNextLevel * 10 {
            levelUp()
        }
        
        // Update high score
        if score > highestLevel * eggsNeededForNextLevel * 10 {
            highestLevel = level
        }
    }
    
    private func missedEgg() {
        playSound("miss")
        misses += 1
        lives -= 1
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func stolenEgg() {
        playSound("steal")
        stolenEggs += 1
        
        if stolenEggs > highestStolenEggs {
            highestStolenEggs = stolenEggs
        }
    }
    
    private func levelUp() {
        playSound("levelUp")
        level += 1
        showLevelUp = true
        
        // Increase difficulty
        eggSpeed = min(eggSpeed + 0.5, 8)
        eggFrequency = max(eggFrequency - 0.2, 0.8)
        
        // Restart timers with new frequency
        startTimers()
        
        // Hide level up after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showLevelUp = false
        }
    }
    
    private func gameOver() {
        playSound("gameOver")
        gameState = .gameOver
        stopTimers()
        stopBackgroundMusic()
    }
    
    private func stopTimers() {
        eggTimer?.invalidate()
        bunnyTimer?.invalidate()
        gameTimer?.invalidate()
    }
    
    // MARK: - Audio
    
    func setupAudio() {
        // Preload sounds if needed
    }
    
    func toggleSound() {
        isMuted.toggle()
        if isMuted {
            backgroundPlayer?.volume = 0
        } else {
            backgroundPlayer?.volume = 0.15
            playSound("background")
        }
    }
    
    private func startBackgroundMusic() {
        if isMuted { return }
        playSound("background", loop: false)
    }
    
    private func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    private func playSound(_ name: String, loop: Bool = false) {
        guard !isMuted || name == "background" else { return }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound file not found: \(name)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            
            if loop {
                backgroundPlayer = player
                backgroundPlayer?.numberOfLoops = -1
                backgroundPlayer?.volume = 0.15
                backgroundPlayer?.play()
            } else {
                audioPlayer = player
                audioPlayer?.play()
            }
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
