//
//  CulturaTableViewCell.swift
//  CulturasPeruanas
//

import UIKit

class CulturaTableViewCell: UITableViewCell {

    @IBOutlet weak var imagenCultura: UIImageView!
    @IBOutlet weak var nombreCulturaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
