require "oauth2"
require "json"
require "curb"

	# Instantiate a new OAuth 2.0 client using the
	# client ID and client secret registered to your
	# application.
	#
	# Options:
	#
	# <tt>:site</tt> :: Specify a base URL for your OAuth 2.0 client.
	# <tt>:authorize_path</tt> :: Specify the path to the authorization endpoint.
	# <tt>:authorize_url</tt> :: Specify a full URL of the authorization endpoint.
	# <tt>:access_token_path</tt> :: Specify the path to the access token endpoint.
	# <tt>:access_token_method</tt> :: Specify the method to use for token endpoints, can be :get or :post
	# (note: for Facebook this should be :get and for Google this should be :post)
	# <tt>:access_token_url</tt> :: Specify the full URL of the access token endpoint.
	# <tt>:parse_json</tt> :: If true, <tt>application/json</tt> responses will be automatically parsed.
	# <tt>:ssl</tt> :: Specify SSL options for the connection.
	# <tt>:adapter</tt> :: The name of the Faraday::Adapter::* class to use, e.g. :net_http. To pass arguments
	# to the adapter pass an array here, e.g. [:action_dispatch, my_test_session]
	# <tt>:raise_errors</tt> :: Default true. When false it will then return the error status and response instead of raising an exception.

# Data for connection from api.intrav2.42.fr
UID = "b5ed15659469cdbce9b3f4d8badd61d8d15ce805071dbc43ab00e5f90c5e9fed"
SECRET = "9d47c82282c76d8eb030ec1b7b80e783dbcf2e59e186671cbb47217c9fa052b1"

def get_projects (cursus_name)
	begin
		# Create the client with your credentials
		client = OAuth2::Client.new(UID, SECRET, site: "https://api.intrav2.42.fr", raise_errors: false)

		# Get an access token and print it
		token = client.client_credentials.get_token
		print (token)
		print ("\n")

		# Get the different cursus and save the projects from cursus 42 for later use
		cursus = token.get("/v2/cursus").parsed
		nb_cursus = cursus.length
		cfound = -1
		# p cursus_name
		for i in 0..(nb_cursus-1)
			if cursus_name == "cursus"
				if i == 0
					print ("Here is a list of all available cursuses on the intranet.\n")
				end
				p cursus[i]['name']
				cfound = 2
			else
				if cursus[i]['name'] == cursus_name
					# print ("/v2/cursus/"+cursus[i]['id'].to_s+"/projects")
					# projects = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects?page=3").body
					# p projects
					projects = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects").headers
					# p projects
					if projects['link'] != nil
						buff = projects['link']
						p_index_last = buff[(buff =~ />; rel="last"/)-1].to_i
						# p p_index_last
						if p_index_last > 1
							p_index_next = buff[(buff =~ />; rel="next"/)-1].to_i
						end
						tab_proj = Array.new(p_index_last)
						tab_proj[0] = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects").body
						if tab_proj[0].length > 2
							file = File.open("projects0.json", "w")
							file.write(tab_proj[0])
							file.close
						end
						for j in 2..p_index_last
							# p "/v2/cursus/"+cursus[i]['id'].to_s+"/projects?page="+j.to_s
							# p token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects?page="+j.to_s).body
							tab_proj[j-1] = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects?page="+j.to_s).body
							file = File.open("projects"+(j-1).to_s+".json", "w")
							file.write(tab_proj[j-1])
							file.close
						end
					end

					# projects = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects").headers
					# projects = open ("https://api.intrav2.42.fr/v2/cursus/"+cursus[i]['id'].to_s+"/projects/\?access_token\="+"#{token.token}")
					# projects = Curl.get("https://api.intrav2.42.fr/v2/cursus/"+cursus[i]['id'].to_s+"/projects/\?access_token\="+"#{token.token}")
					# print (projects)
					# file = File.open("projects.json", "w")
					# file.write(projects)
					# file.close
			  		cfound = 1
			  	end
			end
		end
		case cfound
		when 2
			
		when 1
			if tab_proj[0].length > 2
				print (p_index_last.to_s+" files were created with the list of all projects of cursus named : "+cursus_name+"\n")
				return 0
			else
				print ("Seems the cursus named \""+cursus_name+"\" doesn't have any projects so far.\n")
			end
		else
			print ("Cursus not found, so let's go look for a projet.\n")
			# get_p_infos(cursus_name, token)
			return get_p_id(cursus_name, token)
		end
	rescue Exception => e  
		p e.message  
		p e.backtrace.inspect  
	end
end

def get_p_id (project_name, token)
	begin
		# file = File.read('test.json')
		# file = File.read('projects.json')
		# data_hash = JSON.parse(file)
		# p data_hash.length
		print ("The active token is : #{token.token}\n")
		pid = 0
		nb_pj = 0
		nb_files = Dir["./projects*.json"].count
		if nb_files == 0
			print ("Before looking for a project you have to enter a cursus name.\nTry the command with \"cursus\" as project name to get a list of all available cursuses.\n")
		else
			savup = File.open("projects_list.txt", "w")
			for i in 0..(nb_files-1)
				file = File.open("projects"+i.to_s+".json", "r" )
				data_hash = JSON.load(file)
				# size = data_hash.length
				nb_pj = data_hash.length
				for j in 0..(nb_pj-1)
					savup.write (data_hash[j]['name']+"\n")
					# p project_name
					if data_hash[j]['name'] == project_name
						# p j
						# p data_hash[j]
						pid = data_hash[j]['id']
					end
				end
			end
			savup.close
			print ("Cursus found including "+nb_pj.to_s+" projects.\n") 
			if pid != 0
				return get_p_infos(pid, token)
			else
				print ("No projects seems to be name like that, find a list of all available projects in file named \"projects_list.txt\".\n")
			end
		end
	rescue Exception => e
		p e.message
		p e.backtrace.inspect
	end
end

def get_p_infos (project_id, token)
	begin
		print ("The active token is : #{token.token}\n")
		# p "/v2/projects/"+project_name
		status = token.get("/v2/projects/"+project_id.to_s).status
		if status == 200
			print ("Connection successful\n")
		else
			print ("Connection error : "+status.to_s)
		end
		# project = token.get("/v2/projects/"+project_name).parsed
		# project = token.get("/v2/cursus/1/"+project_name).parsed
		project = token.get("/v2/projects/"+project_id.to_s).parsed
		# p project
		if status == 404
			print ("No looking good no project found either.")
		else
			# print (project)
			return project
		end
	rescue Exception => e
		p e.message
		p e.backtrace.inspect
	end
end


if ARGV.length != 1
	print ("Usage: test.rb [cursus_name/project_name]\n")

else
	proj = get_projects(ARGV[0])
	if proj == 0
		file = File.open("projects_list.txt", "r" )
		p file.length
	else
		p proj['min_estimate_time']/86400
		p proj['max_estimate_time']/86400
	end
end
#cursus_name = gets
