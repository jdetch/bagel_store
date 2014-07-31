class OrderItemsController < ApplicationController
  before_action :set_order, only: [:new, :create]

  def default_serializer_options
    { root: false }
  end

  respond_to :json, :html

  def new
    @order_item = OrderItem.new
    @order_item.menu_item_id = params[:menu_item_id]
    @order_item.price = @order_item.menu_item.price
    @order_item.options = Option.where(menu_item_id: @order_item.menu_item_id)

    @order_item.selections.each do |selection|
      if selection.option.is_addon == true
        selection.is_selected = false
      else
        selection.is_selected = true
      end
    end
    respond_with(@order_item)
  end

  def create
    @order_item = @order.order_items.new(order_item_params)
    @order_item.user_id = current_or_guest_user.id

    #set unselected
    menu_item_option_ids = @order_item.menu_item.options.map(&:id)
    selection_option_ids = @order_item.selections.map(&:option_id)

    menu_item_option_ids.each do |menu_item_option_id|
      unless selection_option_ids.include?(menu_item_option_id)
        @order_item.selections.new(option_id: menu_item_option_id, is_selected: false)
      end
    end

    # calculate price
    @order_item.price = @order_item.menu_item.price
    @order_item.selections.each do |selection|
      if selection.is_selected && selection.option.is_addon
        @order_item.price += selection.option.ingredient.price
      end
    end
    @order_item.order.price += (@order_item.price * @order_item.quantity)
    @order_item.order.save
    if @order_item.save!
      respond_with(@order_item)
    end
  end

  def edit
    @order_item = OrderItem.find(params[:id])
    respond_with(@order_item)
  end

  def update
    @order_item = OrderItem.find(params[:id])
    order = @order_item.order
    @order_item.selections = []
    if @order_item.update!(order_item_params)
      respond_with(@order_item)
    end
  end

  def destroy
    @order_item = OrderItem.find(params[:id])
    order = @order_item.order
    order.price -= (@order_item.price * @order_item.quantity)
    @order_item.destroy
    redirect_to order, alert: "You have removed the item."
  end

  private

  def order_item_params
    params.require(:order_item).permit(:menu_item_id, :quantity, selections_attributes: [:option_id, :is_selected])
  end

end
