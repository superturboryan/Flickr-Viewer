//
//  UICollectionViewExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-13.
//

import UIKit

extension UICollectionView {
    
    func useGridLayout(withCellsPerRow cellsPerRow: CGFloat) {
        
        self.layoutIfNeeded()
        
        let margin = Constants.ImageGridUI.cellMargin
        
        // "Equal spacing"
        let cellSize: CGFloat = (self.frame.size.width - ((cellsPerRow + 1) * margin)) / cellsPerRow
        let cellDimension = NSCollectionLayoutDimension.absolute(cellSize)
        
        self.collectionViewLayout = UICollectionViewCompositionalLayout(
            sectionProvider: { (sectionNumber, _) -> NSCollectionLayoutSection? in
                
                // Return different NSCollectionLayoutSection based on sectionNumber
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: cellDimension,
                                                                    heightDimension: cellDimension))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: cellDimension),
                                                               subitems: [item])
                group.interItemSpacing = .fixed(margin)
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.interGroupSpacing = margin
                section.contentInsets = NSDirectionalEdgeInsets(top: margin,
                                                                leading: margin,
                                                                bottom: margin,
                                                                trailing: margin)
                return section
            })
    }
}
