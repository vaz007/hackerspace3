class Scorecard < ApplicationRecord
  has_many :judgments, dependent: :destroy

  belongs_to :assignment
  has_one :user, through: :assignment
  belongs_to :judgeable, polymorphic: true

  validate :only_one_scorecard_per_judgeable, :cannot_judge_your_own_team

  def update_judgments
    criteria_ids = Competition.current.criteria.where(category: type).pluck(:id)
    score_card_criteria_ids = judgments.pluck(:criterion_id)
    (criteria_ids - score_card_criteria_ids).each do |criterion_id|
      judgments.create(criterion_id: criterion_id)
    end
  end

  def type
    return CHALLENGE if judgeable_type == 'Entry'

    PROJECT
  end

  def only_one_scorecard_per_judgeable
    existing = Scorecard.find_by(assignment: assignment, judgeable: judgeable)
    if existing.present? && existing != self
      errors.add(:assignment_id, 'Only one scorecard allowed per judgeable entity')
    end
  end

  def cannot_judge_your_own_team
    return if judgeable_type == 'Entry'
    if judgeable.users.include? user
      errors.add(:assignment_id, 'Participants are not permitted to vote for a team they are a member in.')
    end
  end

  def total_score
    score = 0
    judgments.each do |judgment|
      return nil if judgment.score.nil?

      score += judgment.score
    end
    score
  end

  def display_score
    score = total_score
    return 'Scorecard Incomplete' if score.nil?

    score
  end

  def max_score
    judgeable.competition.score_total type
  end

  def self.participant_scorecards(teams, include_judges)
    all_scorecards = Scorecard.where(judgeable: teams).order(:assignment_id)
    return all_scorecards if include_judges

    judge_user_ids = Assignment.where(title: JUDGE).pluck(:user_id)
    judge_assignment_ids = Assignment.where(title: EVENT_ASSIGNMENTS, user_id: judge_user_ids).pluck(:id)
    judge_scorecards = Scorecard.where(assignment_id: judge_assignment_ids)
    all_scorecards - judge_scorecards
  end

  def self.region_scorecard_helper(teams, type, include_judges)
    scorecards = participant_scorecards(teams, include_judges)

    region_scorecard_helper = {}
    teams.each do |team|
      region_scorecard_helper[team.id] = { scorecards: [], scores: [] }
    end

    scorecards.each do |scorecard|
      region_scorecard_helper[scorecard.judgeable_id][:scorecards] << scorecard.id
    end

    scorecards.each do |scorecard|
      scorecard_count = region_scorecard_helper[scorecard.judgeable_id][:scorecards].count
      region_scorecard_helper[scorecard.judgeable_id][:total_card_count] = scorecard_count
    end

    judgments = Judgment.where(scorecard: scorecards)
    id_scorecard_scores = {}
    scorecards.each { |scorecard| id_scorecard_scores[scorecard.id] = [] }
    judgments.each do |judgment|
      id_scorecard_scores[judgment.scorecard_id] << judgment.score
    end

    correct_score_count = Competition.current.criteria.where(category: type).count
    scorecards.each do |scorecard|
      scores = id_scorecard_scores[scorecard.id]
      next unless scores.count == correct_score_count
      next if scores.include? nil
      next unless scorecard.included

      region_scorecard_helper[scorecard.judgeable_id][:scores] << scores.mean
    end
    region_scorecard_helper
  end

  def self.team_scorecard_helper(scorecards)
    judgments = Judgment.where(scorecard: scorecards).order(:criterion_id)
    team_scorecard_helper = {}
    scorecards.each do |scorecard|
      team_scorecard_helper[scorecard.id] = { scores: [] }
    end
    judgments.each do |judgment|
      team_scorecard_helper[judgment.scorecard_id][:scores] << judgment.score
    end
    team_scorecard_helper
  end

  def self.assignment_scorecard_helper(assignments)
    assignment_scorecard_helper = {}
    assignments.each do |assignment|
      assignment_scorecard_helper[assignment.id] = { all_scores: [], scorecards: [] }
    end

    scorecards = Scorecard.where(assignment: assignments)
    id_scorecards = {}
    scorecards.each do |scorecard|
      assignment_scorecard_helper[scorecard.assignment_id][:scorecards] << scorecard.id
      id_scorecards[scorecard.id] = scorecard
    end

    Judgment.where(scorecard: scorecards).each do |judgment|
      assignment_id = id_scorecards[judgment.scorecard_id].assignment_id
      assignment_scorecard_helper[assignment_id][:all_scores] << judgment.score
    end
    assignment_scorecard_helper
  end
end
