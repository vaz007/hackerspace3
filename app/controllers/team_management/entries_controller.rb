class TeamManagement::EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_team_privileges!

  def index
    @competition = @team.event.competition
  end

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @entry = @team.entries.new(challenge: @challenge)
    @checkpoints = @team.available_checkpoints(@challenge)
  end

  def create
    create_variables
    checkpoint = Checkpoint.find(params[:entry][:checkpoint_id])
    checkpoint_not_passed = @checkpoints.include?(checkpoint)
    handle_create(checkpoint_not_passed, checkpoint)
  end

  def edit
    @entry = Entry.find(params[:id])
    @team = @entry.team
    @challenge = @entry.challenge
    @checkpoints = (@team.available_checkpoints(@challenge) << @entry.checkpoint).uniq
  end

  def update
    update_variables
    checkpoint = Checkpoint.find(params[:entry][:checkpoint_id])
    checkpoint_not_passed = @checkpoints.include?(checkpoint)
    handle_update(checkpoint_not_passed, checkpoint)
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    flash[:notice] = 'Challenge Entry Removed'
    redirect_to team_management_team_entries_path(@entry.team)
  end

  private

  def entry_params
    params.require(:entry).permit(:checkpoint_id, :justification, :challenge_id)
  end

  def create_variables
    @entry = @team.entries.new(entry_params)
    @challenge = Challenge.find(params[:challenge_id])
    @entry.challenge = @challenge
    @checkpoints = @team.available_checkpoints(@challenge)
  end

  def update_variables
    @entry = Entry.find(params[:id])
    @challenge = @entry.challenge
    @checkpoints = (@team.available_checkpoints(@challenge) << @entry.checkpoint).uniq
  end

  def handle_create(checkpoint_not_passed, checkpoint)
    if checkpoint_not_passed && @entry.save
      flash[:notice] = 'Challenge Entered'
      redirect_to challenge_path(@entry.challenge.identifier)
    else
      flash_alert(checkpoint_not_passed, checkpoint)
      render :new
    end
  end

  def handle_update(checkpoint_not_passed, checkpoint)
    if checkpoint_not_passed && @entry.update(entry_params)
      flash[:notice] = 'Entry Updated Successfully'
      redirect_to team_management_team_entries_path(@team)
    else
      flash_alert(checkpoint_not_passed, checkpoint)
      render :edit
    end
  end

  def flash_alert(checkpoint_not_passed, checkpoint)
    flash[:alert] = if checkpoint_not_passed
                      @entry.errors.full_messages.to_sentence
                    else
                      "#{checkpoint.name} has passed."
                    end
  end

  # IMPROVEMENT - Multiple move up to ApplicationController
  def check_user_team_privileges!
    @team = Team.find(params[:team_id])
    @competition = @team.competition
    return if @team.permission?(current_user) && @competition.in_competition_window?(@team.time_zone)

    check_team_permission
  end

  def check_team_permission
    if @team.permission?(current_user)
      flash[:notice] = 'The competition has closed.'
      redirect_to project_path(@team.current_project.identifier)
    else
      flash[:notice] = 'You do not have access permissions for this team.'
      redirect_to root_path
    end
  end
end
