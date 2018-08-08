require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  setup do
    @team = Team.first
    @project = Project.first
    @event = Event.first
    @team_data_set = TeamDataSet.first
  end

  test 'team associations' do
    assert(@team.current_project == @project)
    assert(@team.event == @event)
    assert(@team.team_data_sets.include?(@team_data_set))
    @team.destroy
    assert(Project.find_by(team: @team).nil?)
  end

  test 'change_event' do
    @second_event = Event.second
    @team.change_event(@second_event)
  end
end
