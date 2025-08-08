import UIKit

class InsecureWebContentViewController: UIViewController {
    
    @IBOutlet weak var webContentTextView: UITextView!
    @IBOutlet weak var loadContentButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Insecure Web Content"
        setupUI()
    }
    
    private func setupUI() {
        webContentTextView.layer.borderColor = UIColor.lightGray.cgColor
        webContentTextView.layer.borderWidth = 1.0
        webContentTextView.layer.cornerRadius = 5.0
        webContentTextView.isEditable = false
        
        statusLabel.text = "Ready to load content"
        statusLabel.textColor = UIColor.darkGray
    }
    
    @IBAction func loadContentButtonTapped(_ sender: Any) {
        loadWebContent()
    }
    
    @IBAction func loadContentWithPinningButtonTapped(_ sender: Any) {
        loadWebContentWithPinning()
    }
    
    @IBAction func loadContentWithoutPinningButtonTapped(_ sender: Any) {
        loadWebContentWithoutPinning()
    }
    
    // Vulnerabilidade: - Não está utilizando a o método NSURLSessionPinningDelegate para verificar se o certificado é válido    
    func loadWebContent() {
        statusLabel.text = "Loading content..."
        statusLabel.textColor = UIColor.orange
        
        if let url = NSURL(string: "https://siteinseguro.com") {
            let task = URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if error != nil {
                        self.statusLabel.text = "Error: \(error!.localizedDescription)"
                        self.statusLabel.textColor = UIColor.red
                        self.webContentTextView.text = "Network error occurred"
                        print("error: \(error!.localizedDescription): \(error!)")
                    } else if data != nil {
                        if let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                            self.webContentTextView.text = str as String
                            self.statusLabel.text = "Content loaded successfully"
                            self.statusLabel.textColor = UIColor.green
                            print("Received data:\n\(str)")
                        } else {
                            self.webContentTextView.text = "Unable to convert data to text"
                            self.statusLabel.text = "Data conversion failed"
                            self.statusLabel.textColor = UIColor.red
                            print("Unable to convert data to text")
                        }
                    } else {
                        self.webContentTextView.text = "No data received"
                        self.statusLabel.text = "No data received"
                        self.statusLabel.textColor = UIColor.red
                    }
                }
            })
            task.resume()
        } else {
            statusLabel.text = "Unable to create URL"
            statusLabel.textColor = UIColor.red
            webContentTextView.text = "Invalid URL"
            print("Unable to create NSURL")
        }
    }    
}
