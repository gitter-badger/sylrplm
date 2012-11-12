class RolesUsersController < ApplicationController
  include Controllers::PlmObjectControllerModule
  access_control (Access.find_for_controller(controller_class_name()))
  # GET /roles_users
  # GET /roles_users.xml
  def index
    @roles_users = RolesUser.find_paginate({:user=> current_user,:page=>params[:page],:query=>params[:query],:sort=>params[:sort], :nb_items=>get_nb_items(params[:nb_items])})  
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles_users }
    end
  end
  
  # GET /roles_users/1
  # GET /roles_users/1.xml
  def show
    @roles_user = RolesUser.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @roles_user }
    end
  end
  
  # GET /roles_users/new
  # GET /roles_users/new.xml
  def new
    @roles_user = RolesUser.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @roles_user }
    end
  end
  
  # GET /roles_users/1/edit
  def edit
    @roles_user = RolesUser.find(params[:id])
  end
  
  # POST /roles_users
  # POST /roles_users.xml
  def create
    @roles_user = RolesUser.new(params[:roles_user])
    
    respond_to do |format|
      if @roles_user.save
        flash[:notice] = 'RolesUser was successfully created.'
        format.html { redirect_to(@roles_user) }
        format.xml  { render :xml => @roles_user, :status => :created, :location => @roles_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @roles_user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /roles_users/1
  # PUT /roles_users/1.xml
  def update
    @roles_user = RolesUser.find(params[:id])
    @roles_user.update_accessor(current_user)
    respond_to do |format|
      if @roles_user.update_attributes(params[:roles_user])
        flash[:notice] = 'RolesUser was successfully updated.'
        format.html { redirect_to(@roles_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @roles_user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /roles_users/1
  # DELETE /roles_users/1.xml
  def destroy
    @roles_user = RolesUser.find(params[:id])
    @roles_user.destroy
    
    respond_to do |format|
      format.html { redirect_to(roles_users_url) }
      format.xml  { head :ok }
    end
  end
end
