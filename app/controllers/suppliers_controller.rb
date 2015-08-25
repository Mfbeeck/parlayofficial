class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]
  before_action :redirect_to_supplier_home, only: [:destroy]
  before_action :check_supplier_id, only: [:show, :edit, :update]
  before_action :check_admin, only: [:index, :edit, :update, :destroy, :create]

  # before_action :require_logged_in

  def index
    @suppliers = Supplier.all
  end

  def new
    @supplier = Supplier.new
  end

  def deals
    @supplier = current_supplier
    @deals = current_supplier.deals.sort {|a,b| b.participants_left <=> a.participants_left}
  end
  
  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.admin = false
    if @supplier.save
      if current_consumer
        session[:consumer_id] = nil
      end
      redirect_to suppliers_path, notice: "Supplier was successfully created"
    else
      render action: "new"
    end
  end

  def show
    @deal = Deal.new
    # @orders = deal.orders.all
  end

  def edit
  end

  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        if @supplier.save
          format.html { redirect_to @supplier, notice: 'Supplier was successfully updated.' }
          format.json { render :show, status: :ok, location: @supplier }
        else
          format.html { render :edit }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :edit }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_path, notice: 'Supplier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def about
  end

  private

  def check_admin
    if current_supplier.admin
    else
      redirect_to supplier_path(current_supplier)
    end
  end

  def check_supplier_id
    if current_supplier.admin
    else  
      if current_supplier.id != params[:id].to_i
        redirect_to supplier_path(current_supplier)
      else
      end
    end
  end

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:company_name, :address, :email, :username, :password, :password_confirmation)
  end

end
