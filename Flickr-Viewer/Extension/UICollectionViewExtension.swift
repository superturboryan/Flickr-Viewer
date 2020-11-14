//
//  UICollectionViewExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-13.
//

import UIKit

extension UICollectionView {
    
    func useGridLayout(withCellsPerRow cellsPerRow: CGFloat,
                       cellPadding padding: CGFloat) {
        
        let cellSize = NSCollectionLayoutDimension.absolute((self.frame.size.width - ((cellsPerRow + 1) * padding)) / cellsPerRow)
        
        self.collectionViewLayout = UICollectionViewCompositionalLayout(
            sectionProvider: { (sectionNumber, _) -> NSCollectionLayoutSection? in
                
                // Return different NSCollectionLayoutSection based on sectionNumber
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: cellSize,
                                                                    heightDimension: cellSize))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: cellSize),
                                                               subitems: [item])
                group.interItemSpacing = .fixed(padding)
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.interGroupSpacing = padding
                section.contentInsets = NSDirectionalEdgeInsets(top: padding,
                                                                leading: padding,
                                                                bottom: padding,
                                                                trailing: padding)
                
                return section
            })
    }
}
