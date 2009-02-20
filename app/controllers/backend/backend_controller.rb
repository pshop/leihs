class Backend::BackendController < ApplicationController
  require_role "manager", :for_current_inventory_pool => true
  
  before_filter :init
  
  $theme = '00-patterns'
  $modal_layout_path = 'layouts/backend/' + $theme + '/modal'
  $modal_timeline_layout_path = 'layouts/backend/' + $theme + '/modal_timeline'
  $general_layout_path = 'layouts/backend/' + $theme + '/general'
  $layout_public_path = '/layouts/' + $theme
  
  layout $general_layout_path
 
###############################################################  

   # add a new line
   def generic_add_line(document)
    if request.post?
      if params[:model_group_id]
        model = ModelGroup.find(params[:model_group_id]) # TODO scope current_inventory_pool ?
      else
        model = current_inventory_pool.models.find(params[:model_id])
      end
      params[:user_id] ||= current_user.id # OPTIMIZE
      
      model.add_to_document(document, params[:user_id], params[:quantity], nil, nil, current_inventory_pool)

      flash[:notice] = document.errors.full_messages unless document.save
      redirect_to :action => 'show', :id => document.id unless @prevent_redirect # TODO 29**
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI']
    end
  end


  # swap model for a given line
  def generic_swap_model_line(document)
    if request.post?
      if params[:model_id].nil?
        flash[:notice] = _("Model must be selected")
      else
        document.swap_line(params[:line_id], params[:model_id], current_user.id)
      end
      redirect_to :action => 'show', :id => document.id     
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI']
    end
  end
  
  # change time frame for OrderLines or ContractLines 
  def generic_time_lines(document, write_start = true, write_end = true)
    @write_start = write_start
    @write_end = write_end

    if request.post?
      begin
        start_date = Date.new(params[:line]['start_date(1i)'].to_i, params[:line]['start_date(2i)'].to_i, params[:line]['start_date(3i)'].to_i) if params[:line]['start_date(1i)']
        end_date = Date.new(params[:line]['end_date(1i)'].to_i, params[:line]['end_date(2i)'].to_i, params[:line]['end_date(3i)'].to_i) if params[:line]['end_date(1i)']
        params[:lines].each {|l| document.update_time_line(l, start_date, end_date, current_user.id) }
      rescue
      end 
      flash[:notice] = document.errors.full_messages
      redirect_to :action => 'show', :id => document.id
    else
      @lines = document.lines.find(params[:lines].split(','))
      render :template => 'backend/backend/time_lines', :layout => $modal_layout_path
    end   
  end    
  
  # remove OrderLines or ContractLines
  def generic_remove_lines(document)
    if request.post?
      params[:lines].each {|l| document.remove_line(l, current_user.id) }
      redirect_to :action => 'show', :id => document.id
    else
      @lines = document.lines.find(params[:lines].split(','))
      render :template => 'backend/backend/remove_lines', :layout => $modal_layout_path
    end   
  end    
###############################################################  

  protected
    
    def current_inventory_pool
      # TODO 28** patch to Rails: actionpack/lib/action_controller/...
      if !params[:inventory_pool_id] and params[:id]
        request.path_parameters[:inventory_pool_id] = params[:id]
        request.parameters[:inventory_pool_id] = params[:id]
      end
      @current_inventory_pool ||= current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
    end

####################################################  
  
  private
  
  def init
    unless logged_in?
      store_location
      redirect_to :controller => '/session', :action => 'new' and return
    end

    @current_inventory_pool = current_inventory_pool

    if @current_inventory_pool
      @to_acknowledge_size = @current_inventory_pool.orders.submitted.size
      @to_hand_over_size = @current_inventory_pool.hand_over_visits.size
      @to_take_back_size = @current_inventory_pool.take_back_visits.size
      @to_remind_size = @current_inventory_pool.remind_visits.size
    end

  end
  
  def set_order_to_session(order)
    session[:current_order] = { :id => order.id,
                                :user_id => order.user.id,
                                :user_login => order.user.login }
  end
  
  def remove_order_from_session
    session[:current_order] = nil
  end
  
end
