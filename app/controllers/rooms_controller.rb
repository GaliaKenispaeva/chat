class RoomsController < ApplicationController
  # Loads:
  # @rooms = all rooms
  # @room = current room when applicable
  before_action :load_entities

  def index
    @rooms = current_user.rooms
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new permitted_parameters
    @guests = params[:guest_ids]
    if @room.save
      User.where(id: @guests).each do |user|
        user.rooms.push(@room)
      end
      current_user.rooms.push(@room)
      flash[:success] = "Room #{@room.name} was created successfully"
      redirect_to rooms_path
    else
      render :new
    end
  end

  def show
    @room_message = RoomMessage.new room: @room
    @room_messages = @room.room_messages.includes(:user)
  end

  def edit
  end

  def update
    if @room.update_attributes(permitted_parameters)
      @room.users = User.where(id: params[:guest_ids])
      @room.users.push(current_user)
      flash[:success] = "Room #{@room.name} was updated successfully"
      redirect_to rooms_path
    else
      render :new
    end
  end

  protected

  def load_entities
    @rooms = current_user.rooms
    @room = current_user.rooms.find(params[:id]) if params[:id]
  end

  def permitted_parameters
    params.require(:room).permit(:name)
  end
end
