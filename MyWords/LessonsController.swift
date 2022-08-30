import UIKit
import CoreData

final class LessonsController: UIViewController {
    
    let coreDataStack = CoreDataStack()
    
    private let segmentedControl = UISegmentedControl(items: ["Dictionary", "Lessons"])
    private let blackLine = UIView()
    private let bellView = UIImageView()
    private let gearshapeView = UIImageView()
    private let topBarContainer = UIView()
    private let addButton = UIButton()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    
    var mainColor = UIColor("61FFD2")
    
    lazy var fetchRsultsController: NSFetchedResultsController<Lesson> = {
        let fetchRquest = Lesson.fetchRequest()

        let sort = NSSortDescriptor(key: #keyPath(Lesson.created), ascending: true)
        fetchRquest.sortDescriptors = [sort]


        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRquest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchResultsController
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getItems()
        setUpSegmentedConrol()
        setUpBlackLine()
        setUpToolsButtons()
        addingGesture()
        setUpTopBarContainer()
        setUpSearchBarLayout()
        setUpAddButton()
        setUpTableViewLayout()
        configureTableView()
        fetchRsultsController.delegate = self
        view.backgroundColor = .white
    }
    
    //MARK: - Internal Methods
    
    func getItems() {
        do {
            try fetchRsultsController.performFetch()
        } catch {
            print("I can fetch items")
        }
    }
    
    func getItems(for lesson: String) {
        var predicate: NSPredicate?
        
        if !lesson.isEmpty {
            predicate = NSPredicate(format: "lesson contains[c] '\(lesson)'")
        } else {
            predicate = nil
        }
        
        fetchRsultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchRsultsController.performFetch()
        } catch {
            print("I can't fetch items")
        }
        
    }
    
    func save(with lesson: String) {
        let context = coreDataStack.managedContext
        
        let item = Lesson(context: context)
        item.lesson = lesson
        item.created = Date()

        coreDataStack.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = fetchRsultsController.object(at: indexPath)
        
        let vc = LessonsWordsController(item: item)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - Private Methods

    private func setUpSegmentedConrol() {
        view.addSubview(segmentedControl)
        segmentedControl.frame = CGRect(x: view.center.x - segmentedControl.frame.width / 1.45, y: 51, width: view.frame.width / 1.75, height: 40)
        segmentedControl.addTarget(self, action: #selector(screenSelection(_:)), for: .valueChanged)
        segmentedControl.layer.cornerRadius = 20
        segmentedControl.layer.masksToBounds = true
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.selectedSegmentTintColor = mainColor
    }

    @objc func screenSelection(_ screenSelection: UISegmentedControl) {
        switch (screenSelection.selectedSegmentIndex) {
        case 0:
            let vc = DictionaryController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 1:
            break
        default:
            break
        }
    }
    
    private func setUpToolsButtons() {
        view.addSubview(bellView)
        view.addSubview(gearshapeView)
        bellView.image = Images.ImageNames.bellSlashImage.image
        gearshapeView.image = Images.ImageNames.gearshapeImage.image
        
        let imageViews = [bellView, gearshapeView]
        imageViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalTo: segmentedControl.heightAnchor),
                $0.heightAnchor.constraint(equalTo: segmentedControl.heightAnchor),
                $0.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            bellView.trailingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: -30),
            gearshapeView.leadingAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: 30)
        ])
    }
    
    private func addingGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goBack(_:)))
        gearshapeView.addGestureRecognizer(tapGesture)
        gearshapeView.isUserInteractionEnabled = true
    }
    
    @objc func goBack(_ sender: UITapGestureRecognizer? = nil) {
        let vc = SettingsController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func setUpBlackLine() {
        view.addSubview(blackLine)
        blackLine.backgroundColor = .black
        blackLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blackLine.widthAnchor.constraint(equalTo: view.widthAnchor),
            blackLine.heightAnchor.constraint(equalToConstant: 1),
            blackLine.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            blackLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackLine.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpTopBarContainer() {
        view.addSubview(topBarContainer)
        topBarContainer.backgroundColor = .white
        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.topAnchor.constraint(equalTo: blackLine.bottomAnchor, constant: 20),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setUpSearchBarLayout() {
        topBarContainer.addSubview(searchBar)
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search for item..."
        searchBar.sizeToFit()
        searchBar.layer.cornerRadius = 15
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints =  false

        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            searchBar.widthAnchor.constraint(equalToConstant: 284),
            searchBar.topAnchor.constraint(equalTo: topBarContainer.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 4)
        ])
    }
    
    private func setUpAddButton() {
        topBarContainer.addSubview(addButton)
        addButton.backgroundColor = mainColor
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.layer.cornerRadius = 15
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addNewWord), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 40),
            addButton.widthAnchor.constraint(equalToConstant: 86),
            addButton.topAnchor.constraint(equalTo: blackLine.bottomAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: gearshapeView.trailingAnchor)
        ])
    }
    @objc func addNewWord() {
        showAddAlert()
    }
    
    private func showAddAlert() {
        let alert = UIAlertController(title: "Add new lesson", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter the name of the lesson"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text, !text.isEmpty else { return }
            
            self.save(with: text)

            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
        
    }
    
    private func setUpTableViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

}

//MARK: - Extension

extension LessonsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRsultsController.sections?.first?.numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
               
        let item = fetchRsultsController.object(at: indexPath)
        
        cell.textLabel?.text = item.lesson
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(at: indexPath)
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

extension LessonsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getItems(for: searchText)
        
        tableView.reloadData()
    }
}

extension LessonsController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}

