//
//  Percolatable.swift
//  
//
//  Created by Ray Tso on 06/04/2018.
//

import Foundation

protocol Percolatable {
    
    /// Open site (row, col) if it is not open already
    func open(row: Int, col: Int)
    
    /// Is site (row, col) open?
    func isOpen(row: Int, col: Int) -> Bool
    
    /// Is site (row, col) full?
    func isFull(row: Int, col: Int) -> Bool
    
    /// Number of open sites
    var numberOfOpenSites: Int { get }
    
    // Does the system percolate?
    var percolates: Bool { get }
}

class Site {
    var isOpen: Bool = false
    var isFull: Bool = false
    var index: Int
    var parentIndex: Int
    var size: Int = 1
    
    init(index: Int) {
        self.index = index
        self.parentIndex = index
    }
    
    convenience init(index: Int, isOpen: Bool, isFull: Bool) {
        self.init(index: index)
        self.isOpen = isOpen
        self.isFull = isFull
    }
}

class PercolationCalculator: Percolatable {
    
    // MARK: - Percolatable protocol
    
    func open(row: Int, col: Int) {
        guard !isOpen(row: row, col: col) else { return }
        opened += 1
        getSite(index: indexFor(row: row, col: col)).isOpen = true
        checkSurroundingsOf(row: row, col: col)
    }
    
    func isOpen(row: Int, col: Int) -> Bool {
        return getSite(index: indexFor(row: row, col: col)).isOpen
    }
    
    func isFull(row: Int, col: Int) -> Bool {
        return getSite(index: indexFor(row: row, col: col)).isFull
    }
    
    var numberOfOpenSites: Int {
        return opened
    }
    
    var percolates: Bool {
        return scanPercolation()
    }
    
    // MARK: - Properties
    
    private var grid: [Site]
    
    private let topSite: Site = {
        return Site(index: -1, isOpen: true, isFull: true)
    }()
    
    private let bottomSite: Site = {
        return Site(index: -2, isOpen: true, isFull: true)
    }()
    
    private let gridLength: Int
    
    private var opened: Int = 0
    
    // MARK: - Initialization
    
    init(n: Int) {
        self.gridLength = n
        self.grid = Array(0...(n * n - 1)).map { Site(index: $0) }
    }
    
    // MARK: - UDF
    
    private func indexFor(row: Int, col: Int) -> Int {
        return (row - 1) * gridLength + col - 1
    }
    
    private func scanPercolation() -> Bool {
        return topSite.parentIndex == bottomSite.parentIndex
    }
    
    private func surroundingsIndexOf(row: Int, col: Int) -> [Int] {
        let up: (row: Int, col: Int) = (row: row - 1, col: col)
        let down: (row: Int, col: Int) = (row: row + 1, col: col)
        let left: (row: Int, col: Int) = (row: row, col: col - 1)
        let right: (row: Int, col: Int) = (row: row, col: col + 1)
        var results: [Int] = []
        for position in [up, down, left, right] {
            if position.col > 0 && position.col <= self.gridLength {
                if position.row > -1 && position.row <= (self.gridLength + 1) {
                    if position.row == 0 {
                        results.append(-1)
                    } else if position.row == self.gridLength + 1 {
                        results.append(-2)
                    } else {
                        results.append(self.indexFor(row: position.row, col: position.col))
                    }
                }
            }
        }
        return results
    }
    
    private func getSite(index: Int) -> Site {
        var site: Site
        switch index {
        case -1:
            site = topSite
        case -2:
            site = bottomSite
        default:
            site = grid[index]
        }
        return site
    }
    
    private func checkSurroundingsOf(row: Int, col: Int) {
        let center = getSite(index: indexFor(row: row, col: col))
        surroundingsIndexOf(row: row, col: col).forEach {
            let site = getSite(index: $0)
            if site.isOpen {
                union(site, center)
            }
        }
    }
    
    private func getParent(of site: Site) -> Site {
        return siftUp(site)
    }
    
    private func union(_ first: Site, _ second: Site) {
        let shouldFill = (first.isFull || second.isFull)
        let firstParent = getParent(of: first)
        let secondParent = getParent(of: second)
        if shouldFill {
            firstParent.isFull = true
            secondParent.isFull = true
        }
        guard firstParent.index != secondParent.index else { return }
        guard firstParent.index != -1, firstParent.index != -2 else {
            add(site: secondParent, to: firstParent)
            return
        }
        guard secondParent.index != -1, secondParent.index != -2 else {
            add(site: firstParent, to: secondParent)
            return
        }
        if firstParent.size > secondParent.size {
            add(site: secondParent, to: firstParent)
        } else {
            add(site: firstParent, to: secondParent)
        }
    }
    
    private func siftUp(_ site: Site) -> Site {
        let parent = getSite(index: site.parentIndex)
        if parent.index != parent.parentIndex {
            site.parentIndex = parent.parentIndex
        } else {
            return parent
        }
        return siftUp(parent)
    }
    
    private func add(site child: Site, to parent: Site) {
        parent.size += child.size
        child.parentIndex = parent.index
    }
}
