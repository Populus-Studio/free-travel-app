import requests
import json

url_base = "https://restapi.amap.com/v3/geocode/geo?address={0}&output=JSON&key={1}"

key = "dfe40994ab0b6fcc60a35a04ee30ef41"


def get_geocode(address):
    url = url_base.format(address, key)
    json_res = requests.get(url)
    data = json_res.json()
    code = data['geocodes'][0]['location']
    return code
