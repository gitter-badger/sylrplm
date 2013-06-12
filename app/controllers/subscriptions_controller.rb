class SubscriptionsController < ApplicationController
	include Controllers::PlmObjectControllerModule
	before_filter :authorize, :except => nil
	# GET /subscriptions
	# GET /subscriptions.xml
	def index
		if params.include? :current_user
			authorize
			params[:query] = current_user.login
		end
		@subscriptions = Subscription.find_paginate({:user=> current_user,:page=>params[:page],:query=>params[:query],:sort=>params[:sort], :nb_items=>get_nb_items(params[:nb_items])})
		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @subscriptions }
		end
	end

	# GET /subscriptions/1
	# GET /subscriptions/1.xml
	def show
		@subscription = Subscription.find(params[:id])
		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @subscription }
		end
	end

	# GET /subscriptions/new
	# GET /subscriptions/new.xml
	def new
		@subscription = Subscription.new(user: current_user)
		@ingroups  = Group.all
		@inprojects  = Project.all
		@fortypesobjects = Typesobject.get_from_observer
		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @subscription }
		end
	end

	# GET /subscriptions/1/edit
	def edit
		@subscription = Subscription.find(params[:id])
		@ingroups  = Group.all
		@inprojects  = Project.all
		@fortypesobjects=Typesobject.get_from_observer
	end

	# POST /subscriptions
	# POST /subscriptions.xml
	def create
		@subscription = Subscription.new(params[:subscription])

		respond_to do |format|
			if @subscription.save
				format.html { redirect_to(@subscription, :notice => 'Subscription was successfully created.') }
				format.xml  { render :xml => @subscription, :status => :created, :location => @subscription }
			else
				@ingroups  = Group.all
				@inprojects  = Project.all
				@fortypesobjects=Typesobject.get_from_observer
				format.html { render :action => "new" }
				format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /subscriptions/1
	# PUT /subscriptions/1.xml
	def update
		@subscription = Subscription.find(params[:id])

		respond_to do |format|
			if @subscription.update_attributes(params[:subscription])
				format.html { redirect_to(@subscription, :notice => 'Subscription was successfully updated.') }
				format.xml  { head :ok }
			else
				@ingroups  = Group.all
				@inprojects  = Project.all
				@fortypesobjects=Typesobject.get_from_observer
				format.html { render :action => "edit" }
				format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /subscriptions/1
	# DELETE /subscriptions/1.xml
	def destroy
		@subscription = Subscription.find(params[:id])
		@subscription.destroy

		respond_to do |format|
			format.html { redirect_to(subscriptions_url) }
			format.xml  { head :ok }
		end
	end
end
