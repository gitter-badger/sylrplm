require 'openwfe/extras/participants/ar_participants'

module Ruote
	module Sylrplm
		class ArWorkitem < OpenWFE::Extras::ArWorkitem
			#include Models::PlmObject
			attr_accessor :link_attributes
			def link_attributes=(att)
				@link_attributes = att
			end

			def link_attributes
				@link_attributes
			end

			def typesobject
				Typesobject.find_by_object(model_name)
			end

			def model_name
				"ar_workitem"
			end

			def ident
				#fei+"_"+wfid+"_"+expid+"_"+wfname
				[wfid,expid,wfname].join("_")
			end

			def cancel?
				histo=Ruote::Sylrplm::HistoryEntry.find_by_wfid_and_source_and_event(self.wfid,"expool","cancel")
				!histo.nil?
			end

			# delete of workitems of a process
			def self.destroy_process(wfid)
				fname="ArWorkitem."+__method__.to_s+":"
				LOG.info (fname) {"wfid=#{wfid}"}
				find_by_wfid_(wfid).each do |ar|
				  LOG.info (fname) {"workitem to destroy=#{ar}"}
					ar.destroy
				end
			end

			def before_destroy
				fname="ArWorkitem."+__method__.to_s+":"
				links=Link.find_childs(self)
				LOG.info (fname) {(links.nil? ? "0" : links.count.to_s)+" liens a detruire"}
				links.each {|lnk| lnk.destroy}
			end

			def get_wi_links
				fname="ArWorkitem."+__method__.to_s+":"
				ret=[]
				Link.find_childs(self,"document").each do |link|
					ret<<{:typeobj =>Document.find(link.child_id), :link=>link}
				end
				Link.find_childs(self,"part").each do |link|
					ret<<{:typeobj =>Part.find(link.child_id), :link=>link}
				end
				Link.find_childs(self,"project").each do |link|
					ret<<{:typeobj =>Product.find(link.child_id), :link=>link}
				end
				Link.find_childs(self,"customer").each do |link|
					ret<<{:typeobj =>Customer.find(link.child_id), :link=>link}
				end
				Link.find_childs(self,"user").each do |link|
					ret<<{:typeobj =>User.find(link.child_id), :link=>link}
				end
				##LOG.debug {fname+id.to_s+":"+ret.size.to_s+":"+ret.inspect}
				ret
			end

			#return associated objects during process
			def objects
				fname="ArWorkitem."+__method__.to_s
				params=self.field_hash[:params]
				ret=[]
				unless params.nil?
					activity=params[:activity]
					params.delete(:activity)
					ret = {:act => activity, :obj => params.values}
				end
				LOG.debug (fname) {"objects:params=#{params.inspect} ret=#{ret}"}
				ret
			end
			
			def self.get_workitem(wfid)
				fname="ArWorkitem."+__method__.to_s
				#LOG.debug (fname) {"wfid=#{wfid}"}
				require 'pg'
				#show_activity		  
				ret = find(:first, :conditions => ["wfid = '#{wfid}'"])
				#ret = find_by_wfid(wfid)
				#LOG.debug (fname) {"ret=#{ret}"}
				ret
			end
			
			def show_activity
				# Output a table of current connections to the DB
			  conn = PG.connect( dbname: 'sylrplm_development' , user: "postgres", password: "pa33zp62" )
			  conn.exec( "SELECT * FROM pg_stat_activity" ) do |result|
			    puts "     PID | User             | Query"
			  result.each do |row|
			      puts " %7d | %-16s | %s " %
			        row.values_at('pid', 'usename', 'query')
			    end
			  end
			end
			
			# add an object in fields
			def add_object(object)
				fname="ArWorkitem."+__method__.to_s
				ret=0
				type_object=object.model_name
				fields = self.field_hash
				if fields == nil
					fields = {}
					fields["params"] = {}
				end
				url="/"+type_object+"s"
				url+="/"+object.id.to_s
				label=type_object+":"+object.ident
				unless fields["params"][url]==label
					fields["params"][url]=label	
					ret+=1
					self.replace_fields(fields)
				else
					LOG.info (fname) {"objet deja present dans cette tache"}
				end
				ret
			end
		end
	end
end
