class GoalsController < AuthenticatedController

  def index
    # Goals in order of priority
    @goals = Goal.where('user' => current_user).joins(:goal_priorities).order('goal_priorities.priority DESC')

    #@goals.each do |g|
    #  width = g.goal_priorities.private * 100
    #  width = wdith + '%'
    #  @goal_priorities[g.id] = width
    #end

  end

  def new
    @goal = Goal.new
    @goal.goal_resources.build
    @goal.goal_priorities.build
    @goal_timeline_categories = timeline_categories
    @goal_resources = resources
  end

  def create
    @goal = Goal.create(permitted_goal_params)
    @goal.user = current_user
    if @goal.timeline_category != 'date'
      @goal.timeline_target_completion_date = nil
    end
    @goal.goal_resources.each do |g|
      if g.name == 'other'
        g.name = g.freeform_name
      end
    end
    @goal.save
    redirect_to goals_path
  end

  def edit
    @goal = Goal.find(params[:id])
    if @goal.user != current_user
      raise 'Goal not owned by user'
    end


    @goal.goal_resources.each do |r|
      is_other = true
      resources.each do |choice|
        if choice['value'] == r.name
          is_other = false
        end
      end
      if is_other
        r.freeform_name = r.name
        r.name = 'other'
      end
    end

    @goal_timeline_categories = timeline_categories
    @goal_resources = resources

  end

  def update
    @goal = Goal.find(params[:id])
    if @goal.user != current_user
      raise 'Goal not owned by user'
    end

    @goal.update(permitted_goal_params)

    if @goal.timeline_category != 'date'
      @goal.timeline_target_completion_date = nil
    end

    @goal.goal_resources.each do |g|
      if g.name == 'other'
        g.name = g.freeform_name
        g.save
      end
    end

    @goal.save

    redirect_to goals_path
  end


  def permitted_goal_params
    params.require(:goal).permit(:title, :timeline_category, :timeline_target_completion_date,
                                 :belief_statement,
                                 goal_priorities_attributes: [:id, :priority],
                                 goal_resources_attributes: [:id, :name, :allocation, :freeform_name])
  end

  private

  def timeline_categories
    [
        {
            'title' => 'Short Term',
            'value' => 'short'
        },
        {
            'title' => 'Long Term',
            'value' => 'long'
        },
        {
            'title' => 'Lifetime',
            'value' => 'life'
        },
        {
            'title' => 'On Date',
            'value' => 'date'
        }
    ]
  end

  def resources
    [
        {
            'title' => 'Time',
            'value' => 'time'
        },
        {
            'title' => 'Money',
            'value' => 'money'
        },
        {
            'title' => 'Health',
            'value' => 'health'
        },
        {
            'title' => 'Confidence',
            'value' => 'confidence'
        },
        {
            'title' => 'Education',
            'value' => 'education'
        },
        {
            'title' => 'Discipline',
            'value' => 'discipline'
        },
        {
            'title' => 'Bravery',
            'value' => 'bravery'
        },
        {
            'title' => 'Other',
            'value' => 'other'
        }

    ]
  end
end