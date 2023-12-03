//
//  GenericAccountPicker.swift
//  Phoenix
//
//  Created by Alexei Akimov on 2019-07-12.
//  Copyright © 2019 Symbility Intersect. All rights reserved.
//

import Foundation
import UIKit

protocol TeamPickerViewDelegate: class {
    func didSelectRowAt(pickerSheet: PickerSheet, tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}

protocol TeamPickerDataSource : class {
    func numberOfTeams() -> Int
    func cellForRow(_ index: IndexPath, _ tableView: UITableView, selectedTeamId: String?) -> UITableViewCell?
    func teamId(_ index: Int) -> String?
}

class TeamPicker {
    let topTableMarginHeight: CGFloat = 30.0
    let maxNumberOfVisibleRows = 4
    
    var selectedTeamId: String?
    weak var delegate: TeamPickerViewDelegate?
    var dataSource: TeamPickerDataSource?

    var teamsPickerSheet: PickerSheet!
    
    init(dataSource: TeamPickerDataSource, selectedTeamId: String?) {
        self.selectedTeamId = selectedTeamId
        self.dataSource = dataSource
        
        teamsPickerSheet = PickerSheet()
        teamsPickerSheet.dataSource = self
        teamsPickerSheet.delegate = self
        teamsPickerSheet.setupUI(cell: TeamSelectionCell.self)
        teamsPickerSheet.configure()
    }
    
    func handleDidSelect(_ pickerSheet: PickerSheet, _ teamId: String, _ tableView: UITableView, _ indexPath: IndexPath) {
        selectedTeamId = teamId
        delegate?.didSelectRowAt(pickerSheet: pickerSheet, tableView: tableView, didSelectRowAt: indexPath)
        tableView.reloadData()
    }
}

extension TeamPicker: PickerSheetDataSource {
    func cellHeight(pickerSheet: PickerSheet) -> CGFloat {
        return TeamSelectionCell.DefaultCellHeight
    }
    
    func numberOfRows(pickerSheet: PickerSheet) -> Int {
        return dataSource?.numberOfTeams() ?? 0
    }
    
    func cellForRowAt(pickerSheet: PickerSheet, tableView: UITableView, index: IndexPath) -> UITableViewCell {
        return dataSource?.cellForRow(index, tableView, selectedTeamId: selectedTeamId) ?? UITableViewCell()
    }
    
    func calculateHeight(pickerSheet: PickerSheet) -> CGFloat {
         return topTableMarginHeight + TeamSelectionCell.DefaultCellHeight * CGFloat(min(maxNumberOfVisibleRows, dataSource?.numberOfTeams() ?? 1))
    }
}

extension TeamPicker: PickerSheetDelegate {
    func didSelectRowAt(pickerSheet: PickerSheet, tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedTeamId = nil
        } else if indexPath.row == (dataSource?.numberOfTeams() ?? 0) - 1 {
            // do nothing
        } else {
            guard let teamId = dataSource?.teamId(indexPath.row) else { return }
            
            selectedTeamId = teamId
        }
        
        delegate?.didSelectRowAt(pickerSheet: pickerSheet, tableView: tableView, didSelectRowAt: indexPath)
        tableView.reloadData()
    }
}
