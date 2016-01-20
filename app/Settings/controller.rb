require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
  
  def index
    @msg = @params['msg']
    render
  end

    
  def login
    @msg = @params['msg']
    render :action => :login
  end

  def login_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      # run sync if we were successful
      Rho::WebView.navigate Rho::Application.settingsPageURI
      Rho::RhoConnectClient.doSync
    else
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      end
        
      if !@msg || @msg.length == 0   
        @msg = Rho::RhoError.new(errCode).message
      end
      
      Rho::WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    end  
  end

  def do_login
    if @params['login'] and @params['password']
      begin
        Rho::RhoConnectClient.login(@params['login'], @params['password'], (url_for :action => :login_callback) )
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        render :action => :login
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :login
    end
  end
  
  def logout
    Rho::RhoConnectClient.logout
    @msg = "You have been logged out."
    render :action => :login
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
    Rho::RhoConnectClient.doSync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    Rho::RhoConnectClient.doSync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def sync_notify
  	status = @params['status'] ? @params['status'] : ""
  	
  	# un-comment to show a debug status pop-up
  	#Rho::Notification.showStatus( "Status", "#{@params['source_name']} : #{status}", Rho::RhoMessages.get_message('hide'))
  	
  	if status == "in_progress" 	
  	  # do nothing
  	elsif status == "complete"
      Rho::WebView.navigate Rho::RhoConfig.start_path if @params['sync_type'] != 'bulk'
  	elsif status == "error"
      puts "BHAKTA:"
      puts "#{@params.inspect}"	
      puts "END:"
      # if @params['server_errors'] && @params['server_errors']['create-error']
      #   Rho::RhoConnectClient.on_sync_create_error(
      #     @params['source_name'], @params['server_errors']['create-error'].keys, :recreate )
      # end
      #Product.onSyncCreateError(@params['server_errors']['create-error'].keys, :recreate)
      #Product.onSyncCreateError(@params['server_errors']['create-error'].keys, :delete)
      
      @params['server_errors']['update-error'].each do |key,value|
        Product.onSyncUpdateError(key,value['attributes'],{},:retry)
      end

      # @params['server_errors']['update-rollback'].each do |key,value|
      #   Product.onSyncUpdateError(key,{},value['attributes'],:rollback)
      # end

      # @params['server_errors']['delete-error'].each do |key,value|
      #   Product.onSyncDeleteError(key,value['attributes'],:retry)
      # end
      
      # Product.onSyncUpdateError(@params['server_errors']['update-rollback'],:rollback)

      # Product.onSyncDeleteError(@params['server_errors']['delete-error'],:retry)

      # if @params['server_errors'] && @params['server_errors']['update-error']
      #   Rho::RhoConnectClient.on_sync_update_error(
      #     @params['source_name'], @params['server_errors']['update-error'], :retry )
      # end
      
      # err_code = @params['error_code'].to_i
      # rho_error = Rho::RhoError.new(err_code)
      
      # @msg = @params['error_message'] if err_code == Rho::RhoError::ERR_CUSTOMSYNCSERVER
      # @msg = rho_error.message unless @msg && @msg.length > 0   

      # if rho_error.unknown_client?( @params['error_message'] )
      #   Rhom::Rhom.database_client_reset
      #   Rho::RhoConnectClient.doSync
      # elsif err_code == Rho::RhoError::ERR_UNATHORIZED
      #   Rho::WebView.navigate(
      #     url_for :action => :login, 
      #     :query => {:msg => "Server credentials are expired"} )                
      # elsif err_code != Rho::RhoError::ERR_CUSTOMSYNCSERVER
      #   Rho::WebView.navigate( url_for :action => :err_sync, :query => { :msg => @msg } )
      # end    
	end
  end  

  def push_callback
    Alert.show_popup "BHAKTA #{@params.inspect}"
  end

  def test_spec
    db_path = Rho::Application.databaseFilePath("user")
    puts "DB PATH IS #{db_path}"
    Alert.show_popup "#{db_path}"
    begin
      Rho::RhoFile.copy("#{db_path}", '/sdcard/test/test.sqlite')
    rescue ex
      Alert.show_popup "#{ex.inspect}"
    end
  end

  def test_has
    data = Product.find(:all)
    data.each do |obj|
      Alert.show_popup "#{obj.inspect}"
      Alert.show_popup "#{Product.hasChanges(obj.object)}"
    end
  end
end
