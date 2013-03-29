module Models
	module PlmObject
		# modifie les attributs avant edition
		def self.included(base)
			base.extend(ClassMethods)
		# a appelle extend du sous module ClassMethods sur "base", la classe dans laquelle tu as inclue la lib
		end

		module ClassMethods
			# inutilisee, voir application_controller.get_models_and_columns
			def self.get_columns
				ret=[]
				self.content_columns().each do |col|
					if(col.name != 'created_at' && col.name != 'updated_at' && col.name != 'owner')
					ret<<col.name
					end
				end
				ret
			end
		end

		def edit()
			self.date=DateTime::now()
		end

		def is_freeze_old
			if(self.statusobject!=nil && ::Statusobject.get_last(self.class.name)!=nil)
				if(self.statusobject.rank == ::Statusobject.get_last(self.class.name).rank)
				true
				else
				false
				end
			else
			false
			end
		end

		def checked?
			check = ::Check.get_checkout(self)
			#file=self.filename
			if check.nil?
			#non reserve
			false
			else
			#reserve
			true
			end
		end

		def last_revision
			fname= "#{self.model_name}.#{__method__}"
			LOG.debug (fname){"begin"}
			cls=eval self.class.name
			cls.find(:last, :order=>"revision ASC",  :conditions => ["ident = '#{ident}'"])
		end

		def first_revision
			cls=eval self.class.name
			cls.find(:first, :order=>"revision ASC",  :conditions => ["ident = '#{ident}'"])
		end

		def last_revision?
			ret = (self.revision == self.last_revision.revision)
			ret
		end

		def revisable?
			ret = (has_attribute?("revision") && frozen? && last_revision?)
			ret
		end

		#
		# TODO solution d'attente, on teste juste que l'objet est revisionnable
		# on suppose donc qu'un process existe
		#
		def revise_by_action?
			fname= "#{self.model_name}.#{__method__}"
			ret = has_attribute?("revision")
			LOG.debug (fname){"#{self.ident}:#{ret}"}
			ret
		end

		def revise
			fname= "#{self.model_name}.#{__method__}"
			LOG.debug (fname){"#{self.ident}"}
			if(self.frozen?)
				#LOG.debug (fname){"#{self.ident} frozen"}
				# recherche si c'est la derniere revision
				rev_cur=self.revision
				last_rev=last_revision
				if revisable?
					#LOG.debug (fname){"#{self.ident} frozen revisable"}
					admin = User.find_by_name(::SYLRPLM::ROLE_ADMIN)
					obj = self.clone
					LOG.debug (fname){"#{self.ident} frozen revisable 2 :#{obj}"}
					obj.statusobject = ::Statusobject.get_first(self.model_name)
					obj.revision = rev_cur.next
					obj.set_default_values_with_next_seq
					if self.has_attribute?(:filename)
						if(self.filename!=nil)
						content = self.read_file
						obj.write_file(content)
						end
					end
				return obj
				else
					LOG.debug (fname){"#{self.ident} frozen not revisable"}
					return nil
				end
			else
				LOG.debug (fname){"#{self.ident} not frozen"}
				return nil
			end
		end

		# a valider si avant dernier status
		def could_validate?
			mdl = model_name
			!(self.statusobject.nil? || ::Statusobject.get_last(mdl).nil?) &&
			self.statusobject.rank == ::Statusobject.get_last(mdl).rank-1
		end

		def plm_validate
			if could_validate?
				promote
			end
		end

		def promote?
			#(self.respond_to? (:statusobject) ? self.statusobject.promote_id !=0 : false)
			fname="#{self.class.name}.#{__method__}"
			ret=false
			if self.respond_to? :statusobject
				unless  self.statusobject.nil?
					if self.statusobject.promote_id !=0
					ret = true
					end
				else
					LOG.error (fname) {"DATABASE_CONSISTENCY_ERROR: no status for #{self.ident}"}
				end
			end
			ret
		end

		def demote?
			#(self.respond_to? (:statusobject) ? self.statusobject.demote_id !=0 : false)
			fname="#{self.class.name}.#{__method__}"
			ret=false
			if self.respond_to? :statusobject
				unless  self.statusobject.nil?
					if self.statusobject.demote_id !=0
					ret = true
					end
				end
			else
				LOG.error (fname) {"DATABASE_CONSISTENCY_ERROR: no status for #{self.ident}"}
			end
			ret
		end

		def promote_by?(choice)
			#puts "#{__method__} #{self.ident}: promote_id=#{self.statusobject.promote_id} choice#{choice}"
			fname="#{self.class.name}.#{__method__}"
			ret=false
			if self.respond_to? :statusobject
				unless  self.statusobject.nil?
					if self.statusobject.promote_id == choice
					ret = true
					end
				else
					LOG.error (fname) {"DATABASE_CONSISTENCY_ERROR: no status for #{self.ident}"}
				end
			end
			ret
		end

		def demote_by?(choice)
			#( (self.respond_to? (:statusobject)) ? self.statusobject.demote_id == choice : false)
			#puts "#{__method__} #{self.ident}: promote_id=#{self.statusobject.promote_id} choice#{choice}"
			fname="#{self.class.name}.#{__method__}"
			ret=false
			if self.respond_to? :statusobject
				unless  self.statusobject.nil?
					if self.statusobject.demote_id == choice
					ret = true
					end
				else
					LOG.error (fname) {"DATABASE_CONSISTENCY_ERROR: no status for #{self.ident}"}
				end
			end
			ret
		end

		def promote_by_select?
			promote_by?(1)
		end

		def demote_by_select?
			demote_by?(1)
		end

		def promote_by_menu?
			promote_by?(2)
		end

		def demote_by_menu?
			demote_by?(2)
		end

		def promote_by_action?
			promote_by?(3)
		end

		def demote_by_action?
			demote_by?(3)
		end

		def promote
			st_cur_name = statusobject.name
			st = self.statusobject.get_next
			#st=StatusObject.next(statusobject)
			res = update_attributes({:statusobject => st})
			#puts "Document.promote:"+res.to_s+":"+st_cur_name+" -> "+statusobject.name
			self if res
		end

		def demote
			#st_cur_name = statusobject.name
			st = self.statusobject.get_previous
			res = update_attributes({:statusobject => st})
			#puts "Document.demote:"+st_cur_name+" -> "+st_new.name+":"+statusobject.name
			self if res
		end

		def link_relation
			if link_attributes["relation"] == ""
				""
			else
				link_attributes["relation"].name
			end
		end

		def get_workitems
			ret = []
			links = ::Link.find_fathers(self.model_name, self,  "ar_workitem")
			#puts "plm_object.get_workitems:links="+links.inspect
			links.each do |link|
				begin
					father = Ruote::Sylrplm::ArWorkitem.find(link.father_id) unless Ruote::Sylrplm::ArWorkitem.count(link.father_id)==1
					#puts "plm_object.get_workitems:workitem="+father.inspect
					father.link_attributes={"relation"=>link.relation}
					ret << father
				rescue Exception => e
				#puts "plm_object.get_workitems:erreur="+e.inspect
					LOG.info "plm_object.get_workitems:erreur="+e.inspect
				end
			end
			#puts "plm_object.get_workitems:ret="+ret.inspect
			ret
		end

		def get_histories
			ret = []
			links = ::Link.find_fathers(self.model_name, self,  "history_entry")
			links.each do |link|
				begin
					father = Ruote::Sylrplm::HistoryEntry.find(link.father_id) unless Ruote::Sylrplm::HistoryEntry.count(link.father_id)==1
					#puts "plm_object.get_histories:history="+father.inspect
					father.link_attributes={"relation"=>link.relation}
					ret << father
				rescue Exception => e
					puts "plm_object.get_histories:erreur="+e.inspect
					LOG.error "plm_object.get_histories:erreur="+e.inspect
				end
			end
			#puts "plm_object.get_histories:ret="+ret.inspect
			ret
		end

		def add_documents_from_favori(favori)
			favori.items.each do |item|
				documents << item
			end
		end

		def remove_documents()
			documents = nil
		end

		def remove_document(document)
			documents.delete( document)
		end

		def add_parts_from_favori(favori)
			favori.items.each do |item|
				parts << item
			end
		end

		def remove_parts()
			parts = nil
		end

		def remove_part(part)
			parts.delete( part)
		end

		def add_projects_from_favori(favori)
			favori.items.each do |item|
				projects << item
			end
		end

		def remove_projects()
			projects = nil
		end

		def remove_project(item)
			projects.delete( item)
		end

		def add_users_from_favori(favori)
			favori.items.each do |item|
				users << item
			end
		end

		def remove_users()
			users = nil
		end

		def remove_user(item)
			users.delete( item)
		end

		def self.find_all
			find(:all, :order=>"ident")
		end

		def self.find_others(object_id)
			find(:all,
    :conditions => ["id != #{forobject_id}"],
    :order=>"ident")
		end

		# si meme groupe ou confidentialite = public ou confidentiel
		def ok_for_index?(user)
			acc_public = ::Typesobject.find_by_forobject_and_name("project_typeaccess", "public")
			acc_confidential = ::Typesobject.find_by_forobject_and_name("project_typeaccess", "confidential")
			#puts "ok_for_index?:acc_public="+acc_public.inspect
			#puts "ok_for_index?:acc_confidential="+acc_confidential.inspect
			#puts "ok_for_index?:self="+self.inspect
			#puts "ok_for_index?:user="+user.inspect
			#index possible meme sans user connecte
			puts "ok_for_index? acc_public:"+self.projowner.typeaccess.name+"=="+acc_public.name
			puts "ok_for_index? acc_confidential:"+self.projowner.typeaccess.name+"=="+acc_confidential.name
			unless user.nil?
				puts "ok_for_index? group:"+self.group.name+"=="+user.group.name
			(self.group_id==user.group.id || self.projowner.typeaccess_id==acc_public.id || self.projowner.typeaccess_id==acc_confidential.id)
			else
			(self.projowner.typeaccess_id==acc_public.id || self.projowner.typeaccess_id==acc_confidential.id)
			end
			true
		end

		# si meme groupe ou confidentialite = public
		def ok_for_show?(user)
			acc_public = ::Typesobject.find_by_forobject_and_name("project_typeaccess", "public")
			#index possible meme sans user connecte
			#puts "ok_for_show? acc_public:"+self.projowner.typeaccess.name+"=="+acc_public.name
			unless user.nil?
			#puts "ok_for_show? group:"+self.group.name+"=="+user.group.name
			(self.group_id==user.group.id || self.projowner.typeaccess_id==acc_public.id)
			else
			(self.projowner.typeaccess_id==acc_public.id)
			end
		end

		def before_destroy
			#unless Favori.get(self.model_name).count.zero?
			#  raise "Can't delete because of links:"+self.ident
			#end
			if ::Link.linked?(self)
				#raise "Can't delete "+self.ident+" because of links:"
				self.errors.add_to_base "Can't delete "+self.ident+" because of links"
			return false
			end
		end

		def def_user(user)
			fname= "#{self.class.name}.#{__method__}"
			LOG.info (fname) {"user=#{user.inspect} "}
			unless user.nil?
				LOG.info (fname) {"user=#{user.ident} "}
				if self.respond_to? :owner
					self.owner = user
					LOG.info (fname) {"owner=#{self.owner.ident}"}
				end
				if self.respond_to? :group
					self.group     = user.group
					LOG.info (fname) {"group=#{self.group.ident}"}
				end
				if self.respond_to? :projowner
					self.projowner = user.project
					LOG.info (fname) {"projowner=#{self.projowner.ident}"}
				end
				if self.respond_to? :domain
					self.domain = user.session_domain
					LOG.info (fname) {"domain=#{self.domain}"}
				end
			end

		end

		def initialize(*args)
			fname= "#{self.class.name}.#{__method__}"
			LOG.info (fname) {"args=#{args.length}:#{args.inspect}"}
			super
			if self.respond_to? :revision
				if args.size>0 && (!args[0].include?(:revision))
					self.revision = "1"
				end
			end
			if (self.respond_to? :statusobject)
				if args.size>0 && (!args[0].include?(:statusobject))
				self.statusobject = ::Statusobject.get_first(self.model_name)
				end
			end
			if args.size>0
				unless args[0][:user].nil?
				self.set_default_values_with_next_seq
				end
			end
		end

		def before_save
			fname= "#{self.class.name}.#{__method__}"
			if (self.respond_to? :owner) && (self.respond_to? :group)
				unless owner.nil?
					unless  owner.group.nil?
						self.group     = owner.group
					else
						self.group     = owner.groups[0]
					end
					LOG.info (fname) {"owner=#{owner} group=#{group}"}
				end
			end
			if (self.respond_to? :owner) && (self.respond_to? :projowner)
				unless owner.nil?
					unless owner.project.nil?
						self.projowner = owner.project
					else
						self.projowner = owner.projects[0]
					end
					LOG.info (fname) {"owner=#{owner}  projowner=#{projowner}"}
				end
			end

		end

		# identifiant informatique : model + id
		def mdlid
			model_name+"."+id.to_s
		end
	end
end