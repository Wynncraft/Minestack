#!/bin/python
import os
import sys
from pymongo import MongoClient
from bson.objectid import ObjectId

def modifyConfig(expression, value):
    print('Modifying server.properties '+expression+' with value '+str(value))
    os.system("sed -i 's/"+str(expression)+"/"+str(value)+"/' server.properties")

def modifyLog(expression, value):
    print('Modifying log4j2.xml '+expression+' with value '+str(value))
    os.system("sed -i 's/"+str(expression)+"/"+str(value)+"/' log4j2.xml")

def main():

    mongoHosts = os.environ['mongo_addresses'].split(',')
    mongoDB = os.environ['mongo_database']

    client = MongoClient(mongoHosts)
    db = client[mongoDB]
    serverCollection = db['servers']
    servertypesCollection = db['servertypes']
    nodesCollection = db['nodes']
    worldsCollection = db['worlds']
    pluginsCollection = db['plugins']

    query = {"_id": ObjectId(os.environ['server_id'])}

    server = serverCollection.find_one(query)

    query = {"_id": ObjectId(server['server_type_id'])}

    servertype = servertypesCollection.find_one(query)

    query = {"_id": ObjectId(server['node_id'])}

    node = nodesCollection.find_one(query)

    if servertype is None:
        print('No server type found')
        sys.exit(1)

    worlds = []
    plugins = []
    if 'worlds' in servertype:
        for worldInfo in servertype['worlds']:
            world = worldsCollection.find_one({"_id": ObjectId(worldInfo['world_id'])})
            worldVersion = None
            if 'versions' in world and 'worldversion_id' in worldInfo:
                for version in world['versions']:
                    if version['_id'] == ObjectId(worldInfo['worldversion_id']):
                        worldVersion = version
                        break

            default = worldInfo['defaultWorld']
            worldDict = {'world': world, 'version': worldVersion, 'default': default}
            worlds.append(worldDict)

    if 'plugins' in servertype:
        for pluginInfo in servertype['plugins']:
            plugin = pluginsCollection.find_one({"_id": ObjectId(pluginInfo['plugin_id'])})
            pluginConfig = None
            pluginVersion = None

            if 'configs' in plugin and 'pluginconfig_id' in pluginInfo:
                for config in plugin['configs']:
                    if config['_id'] == ObjectId(pluginInfo['pluginconfig_id']):
                        pluginConfig = config
                        break

            if 'versions' in plugin and 'pluginversion_id' in pluginInfo:
                for version in plugin['versions']:
                    if version['_id'] == ObjectId(pluginInfo['pluginversion_id']):
                        pluginVersion = version
                        break

            pluginDict = {'plugin': plugin, 'version': pluginVersion, 'config': pluginConfig}
            plugins.append(pluginDict)

    print('Copying Main Server files')
    os.system('cp -R /mnt/minestack/server/bukkit/* .')

    defaultWorld = None
    os.system('mkdir worlds')
    for worldInfo in worlds:
        world = worldInfo['world']
        version = worldInfo['version']
        default = worldInfo['default']
        print('Copying world '+world['name'])

        if version is None:
            print('World '+world['name']+' has no version. Skipping')
            continue

        if default is True:
            defaultWorld = world
        os.system('mkdir worlds/'+world['directory'])
        os.system('cp -R /mnt/minestack/worlds/'+world['directory']+'/versions/'+version['version']+'/world.tar.gz worlds/')
        os.system('tar -zxf world.tar.gz -C worlds/'+world['directory'])
    os.system('ls -l worlds')

    if defaultWorld is None:
        print('No default world set')
        sys.exit(1)

    # modify server config for default world
    modifyConfig('levelname', defaultWorld['name'])

    os.system('mkdir plugins')
    for pluginInfo in plugins:
        plugin = pluginInfo['plugin']
        version = pluginInfo['version']
        config = pluginInfo['config']
        print('Copying plugin '+plugin['name'])

        if version is None:
            print('Plugin '+plugin['name']+' has no version. Skipping')
            continue

        if config is not None:
            os.system('mkdir plugins/'+plugin['directory'])
            os.system('cp -R /mnt/minestack/plugins/'+plugin['directory']+'/configs/'+config['name']+'/* plugins/'+plugin['directory'])
        os.system('cp -R /mnt/minestack/plugins/'+plugin['directory']+'/versions/'+version['version']+'/* plugins')
    os.system('ls -l plugins')

    # modify server config for num of players
    modifyConfig('maxplayers', servertype['players'])

    modifyLog('SYS_HOST', node['privateAddress'])
    modifyLog('SERVERTYPE', servertype['name'])
    modifyLog('NUMBER', server['number'])

    os.system('touch .update-lock')

    os.system('ls -l')

    os.system("chmod +x start.sh")
    os.system("./start.sh "+str(servertype['ram']))

main()