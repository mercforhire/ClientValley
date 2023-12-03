//
//  DashboardAccountPicker.swift
//  Phoenix
//
//  Created by Alexei Akimov on 2019-07-12
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

class DashboardTeamPicker : TeamPicker {
    init(selectedTeamId: String?, teams: [Team] = []) {
        super.init(dataSource: DashboardTeamPickerDataSource(teams: teams), selectedTeamId: selectedTeamId)
    }
}

class DashboardTeamPickerDataSource: TeamPickerDataSource {
    private let teams: [Team]
    
    init(teams: [Team]) {
        self.teams = teams
    }
    
    func numberOfTeams() -> Int {
        return teams.count + 2
    }
    
    func cellForRow(_ index: IndexPath, _ tableView: UITableView, selectedTeamId: String?) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamSelectionCell", for: index) as? TeamSelectionCell else {
            return nil
        }
        if index.row == 0 {
            cell.config(state: selectedTeamId == nil ? .checked : .unchecked, team: nil, showDivider: index.row != numberOfTeams())
        } else if index.row == teams.count + 1 {
            cell.config(state: .add, team: nil, showDivider: index.row != teams.count + 1)
        } else {
            let team = teams[index.row - 1]
            cell.config(state: selectedTeamId == team._id.stringValue ? .checked : .unchecked, team: team, showDivider: index.row != numberOfTeams())
        }
        return cell
    }
    
    func teamId(_ index: Int) -> String? {
        if index == 0 || index == numberOfTeams() - 1 {
            return nil
        }
        
        let team = teams[index - 1]
        return team._id.stringValue
    }
}
