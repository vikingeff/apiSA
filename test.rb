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
		cfound = 0
		for i in 0..(nb_cursus-1)
			if cursus[i]['name'] == cursus_name
				# print ("/v2/cursus/"+cursus[i]['id'].to_s+"/projects")
				# projects = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects?page=3").body
				# p projects
				projects = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects").headers
				if projects['link'] != nil
					buff = projects['link']
					p_index_next = buff[(buff =~ />; rel="next"/)-1].to_i
					p_index_last = buff[(buff =~ />; rel="last"/)-1].to_i
					tab_proj = Array.new(p_index_last)
					tab_proj[0] = token.get("/v2/cursus/"+cursus[i]['id'].to_s+"/projects").body
					file = File.open("projects0.json", "w")
					file.write(tab_proj[0])
					file.close
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
		if cfound == 0
			print ("Cursus not found, so let's go look for a projet.\n")
			# get_p_infos(cursus_name, token)
			get_p_id("libft", token)
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
		p "token = #{token.token}"
		nb_files = Dir["./projects*.json"].count
		for i in 0..(nb_files-1)
			file = File.open("projects"+i.to_s+".json", "r" )
			data_hash = JSON.load(file)
			# size = data_hash.length
			p data_hash.length
		end
	rescue Exception => e
		p e.message
		p e.backtrace.inspect
	end
end

def get_p_infos (project_name, token)
	begin
		p "token = #{token.token}"
		# p "/v2/projects/"+project_name
		status = token.get("/v2/projects/"+project_name).status
		p status
		# project = token.get("/v2/projects/"+project_name).parsed
		# project = token.get("/v2/cursus/1/"+project_name).parsed
		project = token.get("/v2/project/"+project_name).parsed
		p project
		if status == 404
			print ("No looking good no project found either.")
		else
			print (project)
		end
	rescue Exception => e
		p e.message
		p e.backtrace.inspect
	end
end


if ARGV.length != 1
	print ("Usage: test.rb [cursus_name]\n")
else
	get_projects(ARGV[0])
end
#cursus_name = gets
