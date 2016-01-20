require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ProductController < Rho::RhoController
  include BrowserHelper

  # GET /Product
  def index
    @products = Product.find(:all)
    render :back => '/app'
  end

  # GET /Product/{1}
  def show
    @product = Product.find(@params['id'])
    if @product
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Product/new
  def new
    @product = Product.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Product/{1}/edit
  def edit
    @product = Product.find(@params['id'])
    if @product
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Product/create
  def create
    @product = Product.create(@params['product'])
    redirect :action => :index
  end

  # POST /Product/{1}/update
  def update
    @product = Product.find(@params['id'])
    @product.update_attributes(@params['product']) if @product
    redirect :action => :index
  end

  # POST /Product/{1}/delete
  def delete
    @product = Product.find(@params['id'])
    @product.destroy if @product
    redirect :action => :index  
  end

  def crd
    #lets create few new records
    # Product.create({"name"=>"Acme6", "industry"=>"Electronics6"})
    # Product.create({"name"=>"Best6", "industry"=>"Software6"})
    # Product.create({"name"=>"Acme7", "industry"=>"Electronics7"})
    # Product.create({"name"=>"Best7", "industry"=>"Software7"})
    #Lets Update existing records
    id = 1
    @product = Product.find(id)
    @product.update_attributes("name"=>"BHAKTA1_1", "industry"=>"BHElectronics1") if @product
    # id = 2
    # @product = Product.find(id)
    # @product.update_attributes("name"=>"BHAKTA1_2", "industry"=>"Software1") if @product
    # #Lets Delete existing records
    # id = 3
    # @product = Product.find(id)
    # @product.destroy if @product
    # id = 4
    # @product = Product.find(id)
    # @product.destroy if @product
    redirect :action => :index 
  end
end
