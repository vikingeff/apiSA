import json
import requests
import urllib3
import pycurl
import oauth2
from requests_oauth2 import OAuth2
from pprint import pprint
from io import BytesIO
from requests_oauthlib import OAuth1

token = "b8e1829b964a579fdb645f55111a52ddce43256d"
client_id = "b5ed15659469cdbce9b3f4d8badd61d8d15ce805071dbc43ab00e5f90c5e9fed"
client_secret = "9d47c82282c76d8eb030ec1b7b80e783dbcf2e59e186671cbb47217c9fa052b1"
site = "https://api.intrav2.42.fr"
redirect_uri = "http://www.wethinkcode.co.za/"
with open('pj-list.json') as data_file:
	data = json.load(data_file)
	data_file.close()

# oauth2_handler = OAuth2(client_id, client_secret, site, redirect_uri, [authorization_url='oauth/authorize'])
# response = oauth2_handler.get_token()
pprint(data)
print(len(data))
for i in range(0, len(data)-1):
	#print(data[i]['name'])
	#if (data[i]['name']=="Libft"):
		print(data[i]['id'])
		url = "https://api.intrav2.42.fr/projects/"+str(data[i]['id'])+"/?token="+token
		url2 = "https://api.intrav2.42.fr/cursus/1/projects/?token=b8e1829b964a579fdb645f55111a52ddce43256d"
		url3 = "https://api.intrav2.42.fr/projects/1/?token=b8e1829b964a579fdb645f55111a52ddce43256d"
		response = requests.get(url)
		jdata =  response.json()
		print (response.status_code)
		print (response.headers)
		print (response.json())
		#if jdata['max_estimate_time']:
		print (response.json()['min_estimate_time']/86400)