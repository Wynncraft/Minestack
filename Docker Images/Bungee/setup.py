#!/bin/python
import os
import sys
from pymongo import MongoClient
from bson.objectid import ObjectId

def modifyConfig(expression, value):
    print('Modifying '+expression+' with value '+str(value))
    os.system("sed -i 's/"+str(expression)+"/"+str(value)+"/' config.yml")

def main():

    mongoHosts = os.environ['mongo_addresses'].split(',')
    mongoDB = os.environ['mongo_database']

    client = MongoClient(mongoHosts)
    db = client[mongoDB]
    networksCollection = db['networks']
    bungeesCollection = db['bungees']
    bungeetypesCollection = db['bungeetypes']
    pluginsCollection = db['plugins']

    query = {"_id": ObjectId(os.environ['bungee_id'])}

    bungee = bungeesCollection.find_one(query)

    query = {"_id": ObjectId(bungee['bungee_type_id'])}

    bungeetype = bungeetypesCollection.find_one(query)

    query = {"_id": ObjectId(bungee['network_id'])}

    network = networksCollection.find_one(query)

    if bungeetype is None:
        print('No bungee type found')
        sys.exit(1)

    if network is None:
        print('No network found')
        sys.exit(1)

    plugins = []
    for pluginInfo in bungeetype['plugins']:
        plugin = pluginsCollection.find_one({"_id": ObjectId(pluginInfo['plugin_id'])})
        pluginConfig = None
        pluginVersion = None
        for config in plugin['configs']:
            if config['_id'] == ObjectId(pluginInfo['pluginconfig_id']):
                pluginConfig = config
                break

        for version in plugin['versions']:
            if version['_id'] == ObjectId(pluginInfo['pluginversion_id']):
                pluginVersion = version
                break

        pluginDict = {'plugin': plugin, 'version': pluginVersion, 'config': pluginConfig}
        plugins.append(pluginDict)

    print('Copying Main Bungee files')
    os.system('cp -R /mnt/minestack/bungee/* .')

    os.system('mkdir plugins')
    os.system('mkdir tempPlugins')
    for pluginInfo in plugins:
        plugin = pluginInfo['plugin']
        version = pluginInfo['version']
        config = pluginInfo['config']
        print('Copying plugin '+plugin['name'])

        if config is not None:
            os.system('cp -R /mnt/minestack/plugins/'+plugin['directory']+'/configs/'+config['name']+' plugins/'+plugin['directory'])
        os.system('cp -R /mnt/minestack/plugins/'+plugin['directory']+'/versions/'+version['version']+' plugins')
    os.system('ls -l plugins')

    defaultServer = None
    for serverinfo in network['servertypes']:
        if serverinfo['defaultServerType']:
            defaultServer = serverinfo
            break

    if defaultServer is not None:
        modifyConfig("defaultserver", defaultServer['server_type_id'])
    else:
        print('No default server found')
        sys.exit(1)

    os.system('ls -l')

    os.system("chmod +x start.sh")
    os.system("./start.sh "+str(bungeetype['ram']))

main()