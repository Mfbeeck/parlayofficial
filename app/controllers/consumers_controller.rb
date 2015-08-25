class ConsumersController < ApplicationController
    before_action :set_consumer, only: [:notification]
    before_action :redirect_to_else, only: [:index, :destroy]
    before_action :check_if_consumer_logged_in, only: [:edit]
    before_action :check_consumer_id, only: [:show, :edit, :update]

	def index
		@consumers = Consumer.all
	end

	def new
		@consumer = Consumer.new
	end

	def edit
		@consumer = Consumer.find(params[:id])
	end

	def notification
		@consumer = current_consumer
	end

	def create
	  @consumer = Consumer.new(consumer_params)
	  @consumer.texts = false
	  @consumer.result_email = true
		@consumer.total_points = 300
    	#The line below turns this format "(123)-456-7890" into "1234567890"
		@consumer.phone_number = @consumer.phone_number.split('').select{|x| x.to_i.to_s == x.to_s}.join
		# Sends email to user when user is created.
		@consumer.username = @consumer.username.downcase
		if @consumer.save
      	#This method sends a text message to the new user if they entered a valid number.
      	  if current_supplier
            session[:supplier_id] = nil
      	  end
	      if @consumer.phone_number.length == 10
	        message = "Thank you for being part of ParlayVous. If you would like to receive text notifications please visit your notifications settings and allow that option."
	        send_message(@consumer, message)
	      end
			session[:consumer_id] = @consumer.id
			CompanyMailer.welcome_email(@consumer).deliver
			redirect_to consumer_path(@consumer), notice: "#{@consumer.username.capitalize} was successfully created."
		else
			render action: "new"
		end
	end

	def destroy
		@consumer = Consumer.find(params[:id])
		@consumer.destroy
		redirect_to consumers_path
		flash.notice = "The consumer \"#{@consumer.email}\" was successfully deleted."
	end

	def update
		@consumer = Consumer.find(params[:id])
		@consumer.update(consumer_params)
		if @consumer.save
			redirect_to consumer_path(@consumer), notice: "#{@consumer.username.capitalize}'s info was successfully updated."
		else
			render action: "edit"
		end
	end

	def show
		@consumer = Consumer.find(params[:id])
	end

	private

	def check_consumer_id
		if session != nil
			if current_supplier && current_supplier.admin
			else
				if current_consumer.id != params[:id].to_i
					redirect_to consumer_path(current_consumer)
				else
				end
			end
		else
			redirect_to root_path
		end
	end

	def consumer_params
		params.require(:consumer).permit(:username, :email, :password, :password_confirmation, :address, :first_name, :last_name, :created_at, :updated_at, :phone_number, :texts, :result_email)
	end

	def set_consumer
    	@consumer = current_consumer
  	end

  	def redirect_to_else
  		if current_supplier || current_consumer
  			if current_supplier.admin
  			else
  				redirect_to root_path
  			end
		else
			redirect_to root_path
		end
  	end

end
