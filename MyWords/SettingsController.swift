import UIKit

final class SettingsController: UIViewController {
    
    private let label = UILabel()
    private let colorsLabel = UILabel()
    private let blackLine = UIView()
    private let arrowView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabel()
        setUpArrowView()
        setUpBlackLine()
        view.backgroundColor = .white
    }
    
    private func setUpLabel() {
        view.addSubview(label)
        label.text = "Settings"
        label.font = label.font.withSize(25)
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
        let vc = DictionaryController()
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
}
