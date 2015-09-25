require "oauth2"
require "json"
require "curb"

token = "dZ4s1EFpNK-SFb3469Jv"

def receive ()

end

def buy ()

curl -X POST --data "kind=buy&btc_amount=2" http://intra-test.42.fr/exchange\?user_token=dZ4s1EFpNK-SFb3469Jv
curl http://intra-test.42.fr/value.json\?user_token=dZ4s1EFpNK-SFb3469Jv
buy
{"succes":true,"current":1055,"fees":107.5}1108,75
sell
{"succes":true,"current":1145,"fees":116.5}1086,75
buy
{"succes":true,"current":969,"fees":98.9}1018,45
sell
{"succes":true,"current":1225,"fees":124.5}1162,75

end

if ARGV.length != 1
	print ("Usage: bitcoin.rb [1->get_info/2->sell_X/3->buy_X/4->transactions]\n")

else
	get_projects(ARGV[0])
end