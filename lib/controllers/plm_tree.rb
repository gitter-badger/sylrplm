############################################
# construction des arbres descendants
############################################
def build_tree(obj, view_id)
	fname="plm_tree:#{controller_class_name}.#{__method__}"
	lab=t(:ctrl_object_explorer, :typeobj => t("ctrl_"+obj.model_name), :ident => obj.label)
	tree = Tree.new({:js_name=>"tree_down", :label => lab, :open => true })
	relations = View.find(view_id).relations unless  view_id.nil?
	LOG.debug (fname) {"view_id=#{view_id}"}
	relations.each {|rel| LOG.debug (fname){"#{rel.id}.#{rel.ident}"}} unless relations.nil?
	follow_tree(tree, obj, relations, 0)
	group_tree(tree, 0)
	tree
end

def group_tree(thenode, level)
	# elimination des doublons avec comptage
	fname="plm_tree:#{controller_class_name}.#{__method__}"
	cur_quantity = thenode.nodes.count
	tab=" "*(level+1)
	LOG.debug (fname){"#{tab} begin ************ #{cur_quantity} noeuds devient #{thenode.nodes.count} "}
	begin
	# on sauve le tableau des fils
		old_nodes = thenode.nodes
		# on vide les fils
		thenode.nodes = []
		# parcours des fils
		old_nodes.each do |node|
			LOG.debug (fname) {"#{tab}node=#{node.id}:#{node.obj_child.ident}:#{node.quantity}"}
			# on ajoute la 1ere occurence de ce noeud
			if node.quantity.nil?
			node.quantity = 1
			thenode << node
			end
			# on cumule les noeuds identiques a celui ci
			old_nodes.each do |other_node|
			# pas celui en cours
				unless other_node == node
					# egalite des objets fils des 2 noeuds
					if other_node.equals?(node)
					node.quantity += 1
					other_node.quantity = 0
					end
				end
			end
			# fin de ce fils, on maj son label avec la quantite
			node.label="#{node.label} *#{node.quantity}"
			group_tree(node, level+=1)
		end
	rescue Exception => e
		LOG.debug (fname){"#{tab}error:#{e}"}
	end
	LOG.debug (fname){"#{tab} end ************ #{cur_quantity} noeuds devient #{thenode.nodes.count} "}
end

#

# descente de l'arbre (recursif)
#
def follow_tree(node, father, relations, level)
	fname="plm_tree:#{controller_class_name}.#{__method__}"
	##LOG.info (fname) {"tree or node=#{node} , father=#{father.ident}, relations=#{relations}"}
	usersnode = tree_level(t("label_#{father.model_name}_user"), icone_plmtype("user"), icone_plmtype("user"))
	tree_users(usersnode, father)
	LOG.debug (fname) {"usersnode.size=#{usersnode.size}"}
	node << usersnode if usersnode.size > 0
	# LOG.info (fname) {"SYLRPLM::TREE_GROUP=#{SYLRPLM::TREE_GROUP}"}
	ico_node="/images/node.png"
	ico_node_open="/images/node_open.png"
	SYLRPLM::TREE_ORDER.each do |mdl_child|
		if SYLRPLM::TREE_GROUP
			snode = tree_level(t("label_#{father.model_name}_#{mdl_child}"), icone_plmtype(mdl_child), icone_plmtype(mdl_child))
		else
			snode = nil
		end
		links = Link.find_childs(father,  mdl_child)
		LOG.debug (fname) {"links(#{mdl_child})=#{links.inspect}"}
		links.each do |link|
			child = PlmServices.get_object(link.child_plmtype, link.child_id)
			# edit du lien
			relation = Relation.find(link.relation_id)
			LOG.info (fname){"relation=#{relation.id}.#{relation.ident}"}
			if relations.nil?
			show_relation = false
			else
			show_relation = relations.include?(relation)
			end
			if show_relation
				LOG.info (fname){"show_relation:#{relation.id}.#{relation.ident}, type=#{relation.typesobject.ident}"}
				img_rel="<img class=\"icone\" src=\"#{icone(link)}\" title=\"#{link.id}.#{clean_text_for_tree(link.tooltip)}\" />"
				unless relation.typesobject.fields.nil?
					link_values = link.values.gsub('\\','').gsub('"','') unless link.values.nil?
					edit_link_url = url_for(:controller => 'links',
              :action => "edit_in_tree",
              :id => link.id,
              :object_model => father.model_name,
              :object_id => father.id)
					edit_link_a = "<a href=#{edit_link_url} title=\"#{link_values}\">#{img_rel}</a>"
				else
					edit_link_a = "#{img_rel}"
				end
				LOG.debug (fname){"edit_link_a=#{edit_link_a}"}
				# destroy du lien
				if child.frozen?
					remove_link_a = ""
				else
					remove_link_url = url_for(:controller => 'links',
              :action => "remove_link",
              :id => link.id,
              :object_model => father.model_name,
              :object_id => father.id)
					remove_link_a = "<a href=\"#{remove_link_url}\">#{img_cut}</a>"
				end
				# show child
				show_url={:controller => child.controller_name,
					:action => 'show',
					:id => "#{child.id}"}
				ctrl_name="ctrl_#{child.model_name}"
				ico = icone(child)
				if ico.empty?
					img=t(ctrl_name)
				else
					img = "<img class=\"icone\" src=\"#{ico}\" title=\"#{link.id}.#{child.tooltip}\" />"
				end
				show_a="<a href=\"#{url_for(show_url)}\">#{img}-#{child.label}</a>"
				options={
					:label  => "#{edit_link_a} | #{show_a} | #{remove_link_a}",
					:icon => ico_node,
					:icon_open => ico_node_open,
					:title => clean_text_for_tree("#{t(ctrl_name)}:#{child.label}"),
					:url => url_for(edit_link_url),
					:open => false,
					:obj_child => child,
					:link => link
				}
				html_options = {
					:alt => "alt:"+child.ident
				}
				#LOG.debug (fname){"options=#{options.inspect}"}
				cnode = Node.new(options)
				follow_tree(cnode, child, relations, level+=1)
				unless snode.nil?
				snode << cnode
				else
				node << cnode
				end
			else
			# on parcours la branche sans afficher ce noeud
				LOG.info (fname){"no show_relation:#{relation.id}.#{relation.ident}, type=#{relation.typesobject.ident}"}
				unless snode.nil?
				thenode=snode
				else
				thenode=node
				end
				follow_tree(thenode, child, relations, level+=1)
			end
		#LOG.debug (fname){"node=#{node}"}
		end
		unless snode.nil?
			LOG.debug (fname) {"snode.size=#{snode.size}"}
		node << snode if snode.size > 0
		end
	end
	if father.model_name == "project"
		snode = tree_level(t(:label_projowners))
		node << snode
		tree_projowners(snode,  father)
	end
end

def tree_projowners(node,  father)
	tree_objects(node, Customer.find_by_projowner_id(father.id))
	tree_objects(node, Part.find_by_projowner_id(father.id))
	tree_objects(node, Document.find_by_projowner_id(father.id))
end

def tree_objects(node, objs)
	if objs.is_a?(Array)
		objs.each do |obj|
			pnode=tree_object(obj)
			node<<pnode
		end
	else
		unless objs.nil?
			pnode=tree_object(objs)
		node<<pnode
		end
	end
end

def tree_object(obj)
	url={:controller => obj.controller_name, :action => :show, :id => "#{obj.id}"}
	options={
		:label => t("ctrl_"+obj.model_name)+':'+obj.ident ,
		:icon=>icone(obj),
		:icon_open=>icone(obj),
		:title => obj.designation,
		:open => false,
		:url=>url_for(url)
	}
	cnode = Node.new(options,nil)
end

def tree_users(node, father)
	fname="plm_tree:#{controller_class_name}.#{__method__}"
	begin
		father.users.each do |child|
			url={:controller => 'users', :action => 'show', :id => child.id}
			options={
				:label => child.ident ,
				:icon  => icone(child),
				:icon_open => icone(child),
				:title => child.designation,
				:open => false,
				:url  => url_for(url)
			}
			LOG.debug (fname){"user:#{child.ident}"}
			cnode = Node.new(options, nil)
			node << cnode
		end
	rescue Exception => e
		LOG.warn (__method__.to_s){e}
	end
end

############################################
# construction des arbres montants
############################################

def build_tree_up(obj, view_id)
	lab=t(:ctrl_object_referencer, :typeobj => t("ctrl_"+obj.model_name), :ident => obj.label)
	tree = Tree.new({:js_name=>"tree_up", :label => lab ,:open => true})
	relations = View.find(view_id).relations unless  view_id.nil?
	SYLRPLM::TREE_ORDER.each do |mdl_child|
		follow_father(mdl_child, tree, obj, relations)
		session[:tree_object_up] = obj
	end
	tree
end

def follow_father(model_name, node, obj, relations)
	ico_node="/images/node.png"
	ico_node_open="/images/node_open.png"
	model=eval model_name.capitalize
	links=Link.find_fathers(get_model_name(obj), obj,  model_name)
	links.each do |link|
		father = model.find(link.father_id)
		url={:controller => get_controller_from_model_type(model_name), :action => 'show', :id => "#{father.id}"}
		relation = Relation.find(link.relation_id)
		ctrl_name="ctrl_#{father.model_name}"
		img_rel="<img class=\"icone\" src=\"#{icone(link)}\" title=\"#{link.tooltip}\" />"
		ico = icone(father)
		if ico.empty?
			img=t(ctrl_name)
		else
			img = "<img class=\"icone\" src=\"#{ico}\" title=\"#{clean_text_for_tree(father.tooltip)}\" />"
		end
		options={
			:label => "#{img_rel}-#{img}-#{father.label}",
			:icon => ico_node,
			:icon_open => ico_node_open,
			:title => clean_text_for_tree(father.designation),
			:url => url_for(url),
			:open => false
		}
		html_options = {
			:alt => "alt:"+father.ident
		}
		cnode = Node.new(options, html_options)
		node << cnode
	end
end

############################################
# utilitaires des arbres
############################################

# cree un noeud intermediaire pour definir un niveau de regroupement d'objets de meme nature par exemple
def tree_level(title, icon = nil, icon_open = nil, designation = nil, open = true)
	fname="plm_tree:#{controller_class_name}.#{__method__}"
	LOG.debug (fname) {"icon=#{icon}"}
	options={
		:label => title,
		:icon => icon,
		:icon_open => icon_open,
		:title => designation,
		:open => open
		#:url=>url_for(url)
	}
	cnode = Node.new(options,nil)
end

def clean_text_for_tree(txt)
	txt.gsub!('\n\n','\n')
	txt.gsub!('\n','<br/>')
	txt.gsub!(10.chr,'<br/>')
	txt.gsub!('\t','')
	txt.gsub!("'"," ")
	txt.gsub!('"',' ')
	txt
end

def img(name)
	"<img class=\"icone\" src=\"../images/#{name}.png\"/>"
end

def img_cut
	img("cut")
end

############################################
# fin des arbres
############################################

