import Foundation
import Darwin // Для sleep()

class VirtualPet {
    enum Mood: String, CaseIterable {
        case happy = "😊"
        case hungry = "🍕"
        case sleepy = "😴"
        case bored = "🥱"
        case angry = "😠"
    }
    
    var name: String
    var health: Int = 100
    var hunger: Int = 0
    var energy: Int = 100
    var mood: Mood = .happy
    var age: Int = 0 // в "циклах"
    
    init(name: String) {
        self.name = name
        startAgingProcess()
    }
    
    private func startAgingProcess() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.age += 1
            self.updateStatus()
        }
    }
    
    private func updateStatus() {
        hunger = min(100, hunger + 5)
        energy = max(0, energy - 3)
        
        if hunger > 70 {
            mood = .hungry
        } else if energy < 20 {
            mood = .sleepy
        } else if age % 5 == 0 {
            mood = Mood.allCases.randomElement() ?? .happy
        }
        
        if hunger > 90 {
            health -= 5
        }
        
        health = min(100, max(0, health))
    }
    
    func feed() {
        hunger = max(0, hunger - 30)
        mood = .happy
        animateAction("\(name) кушает... ням-ням!")
    }
    
    func play() {
        guard energy > 10 else {
            print("\(name) слишком устал для игр 😴")
            return
        }
        
        energy -= 15
        hunger = min(100, hunger + 10)
        mood = [.happy, .happy, .bored].randomElement()!
        
        let games = ["играет с мячом", "бегает по кругу", "прячется"]
        animateAction("\(name) \(games.randomElement()!) 🎾")
    }
    
    func sleep() {
        energy = 100
        hunger = min(100, hunger + 20)
        mood = .happy
        
        animateAction("💤 \(name) сладко спит... Zzz")
        unistd.sleep(3)
        print("\(name) проснулся полный сил! ⚡")
    }
    
    func talk() {
        let responses = [
            "\(name) смотрит на вас с любопытством",
            "\(name) издает радостный звук",
            "\(name) поворачивает голову",
            "\(mood.rawValue) \(name): \(randomPetSound())"
        ]
        
        print(responses.randomElement()!)
    }
    
    private func randomPetSound() -> String {
        let sounds = ["Мяу!", "Гав!", "Пип!", "Бур-бур!", "Шшш!", "Уиии!"]
        return sounds.randomElement()!
    }
    
    private func animateAction(_ action: String) {
        print("\n", terminator: "")
        for _ in 0..<3 {
            print("▶️", terminator: "")
            fflush(stdout)
            usleep(300000)
        }
        print(" \(action)")
    }
    
    func status() {
        print("""
        \nСтатус \(name):
        Здоровье: \(health)% \(healthIndicator(health))
        Сытость: \(100 - hunger)% \(hungerIndicator(hunger))
        Энергия: \(energy)% \(energyIndicator(energy))
        Настроение: \(mood.rawValue)
        Возраст: \(age)
        """)
    }
    
    private func healthIndicator(_ value: Int) -> String {
        let filled = Int(Double(value) / 10.0)
        return String(repeating: "❤️", count: filled) + String(repeating: "🖤", count: 10 - filled)
    }
    
    private func hungerIndicator(_ value: Int) -> String {
        let filled = Int(Double(100 - value) / 10.0)
        return String(repeating: "🍗", count: filled) + String(repeating: "🍽️", count: 10 - filled)
    }
    
    private func energyIndicator(_ value: Int) -> String {
        let filled = Int(Double(value) / 10.0)
        return String(repeating: "⚡", count: filled) + String(repeating: "🔋", count: 10 - filled)
    }
}

func runVirtualPet() {
    print("""
    🐾 Добро пожаловать в Виртуального Питомца! 🐾
    ------------------------------------------
    """)
    
    print("Дайте имя вашему питомцу:")
    guard let name = readLine(), !name.isEmpty else {
        print("Без имени никак! Давайте назовем его... Шарик!")
        sleep(1)
        return runVirtualPet()
    }
    
    let pet = VirtualPet(name: name)
    
    print("\nОтлично! \(name) рад встрече с вами! \(pet.mood.rawValue)")
    
    while true {
        print("""
        \nВыберите действие:
        1. 🍎 Покормить
        2. 🎾 Поиграть
        3. 💤 Уложить спать
        4. 🗣️ Поговорить
        5. 📊 Статус
        6. 🚪 Выйти
        """)
        
        guard let choice = readLine(), let action = Int(choice) else {
            print("Пожалуйста, введите число от 1 до 6")
            continue
        }
        
        switch action {
        case 1:
            pet.feed()
        case 2:
            pet.play()
        case 3:
            pet.sleep()
        case 4:
            pet.talk()
        case 5:
            pet.status()
        case 6:
            print("До свидания! \(pet.name) будет скучать! 😢")
            return
        default:
            print("Неверный выбор. Пожалуйста, введите число от 1 до 6")
        }
        
        // Случайное событие
        if Int.random(in: 1...10) == 1 {
            randomEvent(for: pet)
        }
    }
}

func randomEvent(for pet: VirtualPet) {
    let events = [
        { print("🌟 \(pet.name) нашел что-то интересное!") },
        { print("💨 \(pet.name) увидел что-то страшное и испугался!") },
        { print("🎉 \(pet.name) очень рад вас видеть!") },
        {
            pet.mood = .angry
            print("😠 \(pet.name) разозлился без причины!")
        }
    ]
    
    events.randomElement()?()
}

// Запуск программы
runVirtualPet()
