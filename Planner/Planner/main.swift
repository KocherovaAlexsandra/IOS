import Foundation

struct Task: Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let creationDate: Date
    var completionDate: Date?
    var priority: Priority
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 1
        case medium = 2
        case high = 3
        
        var symbol: String {
            switch self {
            case .low: return "⬇️"
            case .medium: return "➡️"
            case .high: return "⬆️"
            }
        }
    }
}

class TaskManager {
    private var tasks: [Task] = []
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tasks.json")
    
    init() {
        loadTasks()
    }
    
    // MARK: - Основные функции
    
    func addTask(title: String, priority: Task.Priority) {
        let newTask = Task(
            id: UUID(),
            title: title,
            isCompleted: false,
            creationDate: Date(),
            completionDate: nil,
            priority: priority
        )
        tasks.append(newTask)
        saveTasks()
        print("✅ Задача добавлена: \(title)")
    }
    
    func completeTask(at index: Int) {
        guard index >= 0, index < tasks.count else {
            print("❌ Неверный индекс задачи")
            return
        }
        
        tasks[index].isCompleted = true
        tasks[index].completionDate = Date()
        saveTasks()
        print("🎉 Задача выполнена: \(tasks[index].title)")
    }
    
    func deleteTask(at index: Int) {
        guard index >= 0, index < tasks.count else {
            print("❌ Неверный индекс задачи")
            return
        }
        
        let title = tasks[index].title
        tasks.remove(at: index)
        saveTasks()
        print("🗑️ Задача удалена: \(title)")
    }
    
    func showAllTasks() {
        print("\n📋 Ваш список задач:")
        print("====================")
        
        if tasks.isEmpty {
            print("Список задач пуст. Добавьте первую задачу!")
            return
        }
        
        for (index, task) in tasks.enumerated() {
            let status = task.isCompleted ? "✅" : "⌛"
            let dateString = dateFormatter.string(from: task.creationDate)
            print("\(index + 1). [\(task.priority.symbol)] \(status) \(task.title) (создано: \(dateString))")
        }
    }
    
    // MARK: - Аналитика
    
    func showProductivityAnalytics() {
        let completedTasks = tasks.filter { $0.isCompleted }
        let pendingTasks = tasks.filter { !$0.isCompleted }
        
        print("\n📊 Аналитика продуктивности:")
        print("=========================")
        print("Всего задач: \(tasks.count)")
        print("Выполнено: \(completedTasks.count) (\(percentage(completedTasks.count, of: tasks.count))%)")
        print("Осталось: \(pendingTasks.count) (\(percentage(pendingTasks.count, of: tasks.count))%)")
        
        if !completedTasks.isEmpty {
            let avgCompletionTime = averageCompletionTime()
            print("\n⏱️ Среднее время выполнения: \(String(format: "%.1f", avgCompletionTime)) часов")
            
            let priorityStats = priorityStatistics()
            print("\n🏆 Выполнено по приоритетам:")
            for (priority, count) in priorityStats {
                print("\(priority.symbol): \(count) задач (\(percentage(count, of: completedTasks.count))%)")
            }
        }
    }
    
    private func averageCompletionTime() -> Double {
        let completedTasks = tasks.filter { $0.isCompleted && $0.completionDate != nil }
        let totalHours = completedTasks.reduce(0.0) { result, task in
            let hours = task.completionDate!.timeIntervalSince(task.creationDate) / 3600
            return result + hours
        }
        return totalHours / Double(completedTasks.count)
    }
    
    private func priorityStatistics() -> [(priority: Task.Priority, count: Int)] {
        let completedTasks = tasks.filter { $0.isCompleted }
        var stats = [Task.Priority: Int]()
        
        for priority in Task.Priority.allCases {
            stats[priority] = completedTasks.filter { $0.priority == priority }.count
        }
        
        return stats.map { (priority: $0.key, count: $0.value) }
                   .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    private func percentage(_ part: Int, of total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(part) / Double(total)) * 100
    }
    
    // MARK: - Работа с файлами
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("❌ Ошибка сохранения задач: \(error.localizedDescription)")
        }
    }
    
    private func loadTasks() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("❌ Ошибка загрузки задач: \(error.localizedDescription)")
        }
    }
}

// MARK: - Взаимодействие с пользователем

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

func runTaskManager() {
    let taskManager = TaskManager()
    print("""
    🚀 Добро пожаловать в Умный Список Дел!
    --------------------------------------
    """)
    
    while true {
        print("""
        \nВыберите действие:
        1. 📝 Показать все задачи
        2. ➕ Добавить новую задачу
        3. ✅ Отметить задачу как выполненную
        4. 🗑️ Удалить задачу
        5. 📊 Показать аналитику
        6. 🚪 Выйти
        """)
        
        guard let choice = readLine(), let action = Int(choice) else {
            print("❌ Пожалуйста, введите число от 1 до 6")
            continue
        }
        
        switch action {
        case 1:
            taskManager.showAllTasks()
            
        case 2:
            print("Введите название задачи:")
            guard let title = readLine(), !title.isEmpty else {
                print("❌ Название задачи не может быть пустым")
                continue
            }
            
            print("Выберите приоритет (1 - низкий, 2 - средний, 3 - высокий):")
            guard let priorityInput = readLine(),
                  let priorityValue = Int(priorityInput),
                  let priority = Task.Priority(rawValue: priorityValue) else {
                print("❌ Неверный приоритет. Установлен средний приоритет.")
                taskManager.addTask(title: title, priority: .medium)
                continue
            }
            
            taskManager.addTask(title: title, priority: priority)
            
        case 3:
            taskManager.showAllTasks()
            print("Введите номер задачи для отметки как выполненной:")
            guard let indexInput = readLine(), let index = Int(indexInput) else {
                print("❌ Неверный номер задачи")
                continue
            }
            taskManager.completeTask(at: index - 1)
            
        case 4:
            taskManager.showAllTasks()
            print("Введите номер задачи для удаления:")
            guard let indexInput = readLine(), let index = Int(indexInput) else {
                print("❌ Неверный номер задачи")
                continue
            }
            taskManager.deleteTask(at: index - 1)
            
        case 5:
            taskManager.showProductivityAnalytics()
            
        case 6:
            print("До свидания! 👋")
            return
            
        default:
            print("❌ Неверный выбор. Пожалуйста, введите число от 1 до 6")
        }
    }
}

// Запуск программы
runTaskManager()
