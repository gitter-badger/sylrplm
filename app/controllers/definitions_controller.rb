#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++
class DefinitionsController < ApplicationController
	# GET /definitions
	# GET /definitions.xml
	#
	before_filter :authorize, :except => nil
	access_control(Access.find_for_controller(controller_class_name))
	#
	def index
		@definitions = Definition.find_all_for(@current_user)
		unless @definitions.length==0
			respond_to do |format|
				format.html # index.html.erb
				format.xml { render :xml => @definitions.to_xml(:request => request) }
				format.json { render :json => @definitions.to_json(:request => request) }
			end
		end
	end

	def new_process
		fname= "#{controller_class_name}.#{__method__}"
		LOG.debug (fname){"begin:params=#{params}"}
		@definitions = Definition.find_all_for(@current_user)
		unless @definitions.length==0
			respond_to do |format|
				format.html # new_process.html.erb
				format.xml { render :xml => @definitions.to_xml(:request => request) }
				format.json { render :json => @definitions.to_json(:request => request) }
			end

		end
	end

	# GET /definitions/1
	# GET /definitions/1.xml
	#
	def show
		@definition = Definition.find(params[:id])
		respond_to do |format|
			format.html # show.html.erb
			format.xml { render :xml => @definition.to_xml(:request => request) }
			format.json { render :json => @definition.to_json(:request => request) }
		end
	end

	# GET /definitions/:id/tree
	# GET /definitions/:id/tree.js
	#
	def tree
		fname= "#{controller_class_name}.#{__method__}"
		LOG.debug (fname){"begin:params=#{params}"}
		@definition = Definition.find(params[:id])
		LOG.debug (fname){"def=#{@definition.inspect}"}
		uri = @definition.local_uri
		# TODO : reject outside definitions ?
		pdef = (open(uri).read rescue nil)
		#LOG.debug (fname){"pdef=#{pdef}"}
		var = params[:var] || 'proc_tree'
		# TODO : use Rails callback thing (:callback)
		tree = pdef ?
			RuotePlugin.ruote_engine.get_def_parser.parse(pdef) :
			nil
		#LOG.debug (fname){"tree=#{tree.inspect}"}
		render(
    :text => "var #{var} = #{tree.to_json};",
    :content_type => 'text/javascript')
	end

	# GET /definitions/new
	# GET /definitions/new.xml
	#
	def new
		@definition = Definition.new
		respond_to do |format|
			format.html # new.html.erb
			format.xml { render :xml => @definition.to_xml(:request => request) }
			format.json { render :json => @definition.to_json(:request => request) }
		end
	end
	
	def new_dup
		fname= "#{self.class.name}.#{__method__}"
		@object_orig = Definition.find(params[:id])
		@object = @object_orig.duplicate(current_user)
		@definition=@object
		respond_to do |format|
			format.html
			format.xml  { render :xml => @object }
		end
	end
	# GET /definitions/1/edit
	#
	def edit
		@definition = Definition.find(params[:id])
	#@dg_locals = {
	#	:in_roles => @definition.roles_definitions,
	#	:out_roles => Role.find(:all) - @definition.roles
	#}
	end

	# POST /definitions
	# POST /definitions.xml
	#
	def create
		@definition = Definition.new(params[:definition])
		respond_to do |format|
			if params[:fonct] == "new_dup"
				object_orig=Definition.find(params[:object_orig_id])
				st = @definition.create_duplicate(object_orig)
			else
				st = @definition.save
			end
			if st
				flash[:notice] = t(:ctrl_object_created, :typeobj => t(:ctrl_definition), :ident => @definition.name)
				format.html {
					redirect_to(@definition)
				}
				format.xml {
					render(
          :xml => @definition.to_xml(:request => request),
          :status => :created,
          :location => @definition)
				}
				format.json {
					render(
          :json => @definition.to_json(:request => request),
          :status => :created,
          :location => @definition)
				}

			else
			#LOG.error @definition.errors.inspect
			#LOG.error @definition.inspect
				flash[:error] = t(:ctrl_object_not_created, :typeobj => t(:ctrl_definition), :msg => nil)
				format.html {
					render(:action => 'new')
				}
				format.xml {
					render(:xml => @definition.errors, :status => :unprocessable_entity)
				}
				format.json {
					render(:json => @definition.errors, :status => :unprocessable_entity)
				}
			end
		end
	end

	# PUT /definitions/1
	# PUT /definitions/1.xml
	#
	def update
		@definition = Definition.find(params[:id])
		@definition.update_accessor(current_user)
		respond_to do |format|
			if @definition.update_attributes(params[:definition])
				flash[:notice] = t(:ctrl_object_updated, :typeobj => t(:ctrl_definition), :ident => @definition.name)
				format.html { redirect_to :action => 'index' }
				format.xml { head :ok }
				format.json { head :ok }
			else # there is an error
				LOG.error @definition.errors.inspect
				LOG.error @definition.inspect
				flash[:error] = t(:ctrl_object_not_updated, :typeobj => t(:ctrl_definition), :ident => @definition.name)
				p @definition.errors
				format.html {
					render(:action => 'edit')
				}
				format.xml {
					render(:xml => @definition.errors, :status => :unprocessable_entity)
				}
				format.json {
					render(:json => @definition.errors, :status => :unprocessable_entity)
				}
			end
		end
	end

	# DELETE /definitions/1
	# DELETE /definitions/1.xml
	#
	def destroy
		@definition = Definition.find(params[:id])
		@definition.destroy
		flash[:notice] = t(:ctrl_object_deleted, :typeobj => t(:ctrl_definition), :ident => @definition.name)
		respond_to do |format|
			format.html { redirect_to(definitions_url) }
			format.xml { head :ok }
			format.json { head :ok }
		end
	end

end

