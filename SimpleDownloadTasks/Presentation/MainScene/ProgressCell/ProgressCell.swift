//
//  DownloadCell.swift
//  SimpleDownloadTasks
//
//  Created by user200328 on 6/23/21.
//

import UIKit

class ProgressCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    
    var item: DownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let item = item else { return }
        configure(with: item)
    }
    
    func configure(with task: DownloadTask) {
        txtLabel.text = "\(task.state.description) #\(task.identifier)"
        imgView.image = UIImage.randomImage(seed: Int(task.identifier) ?? 0)
    }
}

fileprivate extension UIImage {
    static func randomImage(seed: Int) -> UIImage {
        let images = (1...10).map { UIImage(named: "\($0)")! }
        return images[seed % images.count]
    }
}
