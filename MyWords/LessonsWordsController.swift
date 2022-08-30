import UIKit
import CoreData

final class LessonsWordsController: UIViewController {
    
    let coreDataStack = CoreDataStack()
    
    private let label = UILabel()
    private let addButton = UIButton()
    private let arrowView = UIImageView()
    private let blackLine = UIView()
    private let tableView = UITableView()
    private let item: Lesson
    
    private let mainColor = UIColor("61FFD2")
    
    lazy var fetchRsultsController: NSFetchedResultsController<Lesson> = {
        let fetchRquest = Lesson.fetchRequest()

        let sort = NSSortDescriptor(key: #keyPath(Lesson.created), ascending: true)
        fetchRquest.sortDescriptors = [sort]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRquest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchResultsController
    }()
    
    // MARK: - Initialization
    
    init(item: Lesson) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAddButton()
        setUpLabel()
        setUpArrowView()
        setUpBlackLine()
        setUpTableView()
        configureTableView()
        fetchRsultsController.delegate = self
     
        view.backgroundColor = .white
    }
    
    func getItems() {
        do {
            try fetchRsultsController.performFetch()
        } catch {
            print("I can fetch items")
        }
    }
    
    func save(with lesson: String) {
        
        item.wordArray.append(lesson)

        coreDataStack.save()
    }
    
    // MARK: - Private Methods
    
    private func setUpLabel() {
        view.addSubview(label)
        label.text = item.lesson
        label.font = label.font.withSize(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
        ])
    }
    
    private func setUpArrowView() {
        view.addSubview(arrowView)
        addingGesture()
        arrowView.image = Images.ImageNames.arrowImage.image
        arrowView.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            arrowView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            arrowView.topAnchor.constraint(equalTo: label.topAnchor),
            arrowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            arrowView.heightAnchor.constraint(equalToConstant: 40),
            arrowView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addingGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goBack(_:)))
        arrowView.addGestureRecognizer(tapGesture)
        arrowView.isUserInteractionEnabled = true
    }
    
    @objc func goBack(_ sender: UITapGestureRecognizer? = nil) {
        let vc = LessonsController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    private func setUpBlackLine() {
        view.addSubview(blackLine)
        blackLine.backgroundColor = .black
        blackLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blackLine.widthAnchor.constraint(equalTo: view.widthAnchor),
            blackLine.heightAnchor.constraint(equalToConstant: 1),
            blackLine.topAnchor.constraint(equalTo: arrowView.bottomAnchor, constant: 20),
            blackLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackLine.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: blackLine.bottomAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor)
        ])
    }

    private func setUpAddButton() {
        view.addSubview(addButton)
        addButton.backgroundColor = mainColor
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.layer.cornerRadius = 15
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addNewWord), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    @objc func addNewWord() {
        showAddAlert()
    }
    
    private func showAddAlert() {
        let alert = UIAlertController(title: "Add new word", message: nil, preferredStyle: .alert)
        
        alert.addTextField { firstTextField in
            firstTextField.placeholder = "EN"
        }
        
        alert.addTextField { secondTextField in
            secondTextField.placeholder = "RU"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let firstTextField = alert.textFields?.first,
                  let firstText = firstTextField.text, !firstText.isEmpty else { return }
            
            guard let secondTextField = alert.textFields?.last,
                  let secondText = secondTextField.text, !secondText.isEmpty else { return }
            
            var text = firstText + " - " + secondText
            
            self.save(with: text)

            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
        
    }
}


extension LessonsWordsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchRsultsController.sections?.first?.numberOfObjects ?? 0
        item.wordArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
               
//        let item = fetchRsultsController.object(at: indexPath)
        
        cell.textLabel?.text = item.wordArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            item.wordArray.remove(at: indexPath.row)
            tableView.reloadData()
            coreDataStack.save()
        }
    }

    func deleteItem(at indexPath: IndexPath) {
        let item = fetchRsultsController.object(at: indexPath)
        let context = coreDataStack.managedContext

        context.delete(item)

        do {
            try context.save()
        } catch {
            print("I can't save")
        }
    }
}

extension LessonsWordsController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}


