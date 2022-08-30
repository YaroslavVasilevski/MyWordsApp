import UIKit
import CoreData

final class DictionaryController: UIViewController {
    
    var items: [NSManagedObject] = []
    
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
    public var tintColor: UIColor! = UIColor("61FFD2")
    
    lazy var fetchRsultsController: NSFetchedResultsController<Item> = {
        let fetchRquest = Item.fetchRequest()

        let sort = NSSortDescriptor(key: #keyPath(Item.createdAt), ascending: true)
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
    
    func getItems(for word: String) {
        var predicate: NSPredicate?
        
        if !word.isEmpty {
            predicate = NSPredicate(format: "word contains[c] '\(word)'")
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
    
    func save(with word: String) {
        let context = coreDataStack.managedContext
        
        let item = Item(context: context)
        item.word = word
        item.createdAt = Date()

        coreDataStack.save()
    }
    
    // MARK: - Private Methods
    
    private func setUpSegmentedConrol() {
        view.addSubview(segmentedControl)
        segmentedControl.frame = CGRect(x: view.center.x - segmentedControl.frame.width / 1.45, y: 51, width: view.frame.width / 1.75, height: 40)
        segmentedControl.addTarget(self, action: #selector(screenSelection(_:)), for: .valueChanged)
        segmentedControl.layer.cornerRadius = 20
        segmentedControl.layer.masksToBounds = true
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = mainColor
    }
    
    @objc func screenSelection(_ screenSelection: UISegmentedControl) {
        switch (screenSelection.selectedSegmentIndex) {
        case 0:
            break
        case 1:
            let vc = LessonsController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
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
//        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

}

//MARK: - Extension

extension DictionaryController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRsultsController.sections?.first?.numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
               
        let item = fetchRsultsController.object(at: indexPath)
        
        cell.textLabel?.text = item.word
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

extension DictionaryController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getItems(for: searchText)
        
        tableView.reloadData()
    }
}

extension DictionaryController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}

extension UIColor {
  
  convenience init(_ hex: String, alpha: CGFloat = 1.0) {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if cString.hasPrefix("#") { cString.removeFirst() }
    
    if cString.count != 6 {
      self.init("ff0000") // return red color for wrong hex input
      return
    }
    
    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

}







