# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec
fs = require 'fs'
uuid = require 'node-uuid'


@db = db =
    iface: require('dirty') '/tmp/iface.db'
    dhcp:  require('dirty') '/tmp/dhcp.db'


#schema to validate incoming JSON      
ifaceSchema =
    name: "interface"
    type: "object"
    additionalProperties: false
    properties:
        static: {"type":"boolean", "required":false}
        dhcp: {"type":"boolean", "required":false}
        inetaddr: {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        network: {"type":"string", "required":true}
        vlan: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        gateway: {"type":"string", "required":true}
        'bridge_ports': {"type":"string", "required":false}
        'bridge_fd': {"type":"number" , "required":false}
        'bridge_hello': {"type":"number", "required":false}
        'bridge_maxage': {"type":"number", "required":false}
        'bridge_stp': {"type":"string", "required":false}

#schema to validate incoming JSON dhcp configuration
dhcpSchema =
    name: "dhcp"
    type: "object"
    additionalProperties: false
    properties:
        start:              {"type":"string", "required":true}
        end:                {"type":"string", "required":true}
        interface:          {"type":"string", "required":false}
        max_leases:         {"type":"number", "required":false}
        remaining:          {"type":"string", "required":false}
        auto_time:          {"type":"number", "required":false}
        decline_time:       {"type":"number", "required":false}
        conflict_time:      {"type":"number", "required":false}
        offer_time:         {"type":"number", "required":false}
        min_lease:          {"type":"number", "required":false}
        lease_file:         {"type":"string", "required":false}
        pidfile:            {"type":"string", "required":false}
        notify_file:        {"type":"string", "required":false}
        siaddr:             {"type":"string", "required":false}
        sname:              {"type":"string", "required":false}
        boot_file:          {"type":"string", "required":false}
        option:
           items:           {"type":"string"}

#schema to validate incoming JSON addresses
addrSchema =
      name: "dhcp"
      type: "object"
      additionalProperties: false
      properties:
          optionparam:        {"type":"string", "required":"true"}
          address:
              items:          { type: "string" }

            

class interfaces
    constructor:  ->
        console.log 'networklib initialized'
        ifdb = db.iface
        dhcpdb = db.dhcp

    getDevType: (type) ->
        res = type
        switch type
            when '1'
                res = "Ether"
            when '512'
                res = "PPP"
            when '768'
                res = "Tunnel"
            when '769'
                res = "Tunnel6"
            when '772'
                res = "lo"
            when '778'
                res = "GRE"
        return res

    list: (callback) ->
        res = []
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            iface = {}
            iface.name = ifid
            iface.upstatus = fileops.readFileSync "/sys/class/net/#{ifid}/operstate"
            iface.mtu = fileops.readFileSync "/sys/class/net/#{ifid}/mtu"
            iface.address = fileops.readFileSync "/sys/class/net/#{ifid}/address"
            type = fileops.readFileSync  "/sys/class/net/#{ifid}/type"
            typenumber = type.split('\n')
            iface.devtype = @getDevType(typenumber[0])
            console.log iface
            res.push iface
        callback (res)

    getConfig: (devName) ->
        console.log 'listing device configuration'
        entry = db.iface.get  devName
        console.log entry
        return entry

    getStats: ->
        console.log 'listing device stats'

    updateConfig: ->
        console.log 'loading config on unix system'
        ifaces = fileops.readdirSync "/sys/class/net"
        config = "auto "
        for ifid in ifaces
            config += ifid
            config += " "
        config += "\n"

        console.log config
        files = fileops.readdirSync "/config/network/interfaces"
        console.log 'files present ' + files
        for file in files
            config += fileops.readFileSync "/config/network/interfaces/#{file}"
            console.log config
        #for now I do not want to mess up my ubuntu system :)    
        fileops.updateFile "/etc/network/interfaces", config
        for ifid in ifaces
            console.log 'running ifup on device ' + ifid
            exec "ifup #{ifid}"

    config: (devName, body, callback) ->
        exists = 0
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            if ifid == devName then exists = 1
        return new Error "Invalid Device " + devName + " name posting!" unless exists
        if body.static and body.dhcp
            return new Error "Invalid config posting. Must be either static or dhcp interface"
        config = "iface " + devName + " inet "
        console.log body 
        '''
        if body.static
            config += "static\n"
        else
            config += "dhcp\n"
        '''
        for key, val of body
            switch (typeof val)
                when "number", "string"
                    config += key + ' ' + val + "\n"
                when "boolean"
                    config += key + "\n"

        console.log 'config is ' + config
        filename = "/config/network/interfaces/#{devName}"
        fileops.createFile filename, (result) =>
            return new Error "Unable to create configuration file for device: #{devName}!" if result instanceof Error
            fileops.updateFile filename, config
            try
                db.iface.set devName, body, =>
                    console.log "#{devName} added to network interfaces"
                @updateConfig()
                callback({result:true})

            catch err
                console.log err
                callback(err)

    getInfo: (devName, callback) ->
        # get status, running stats, configuration for the given device
        res = {}
        res.config = @getConfig devName
        #res.stats = @getStats devName
        res.operstate = fileops.readFileSync "/sys/class/net/#{devName}/operstate"
        callback (res)

    delete: (devName, callback) ->
        console.log 'deleting the devname ' + devName
        fileops.removeFile "/config/network/interfaces/#{devName}", (result) =>
            if result instanceof Error
                err = new Error "Invalid or unconfigured device posting!: #{devName}"
                callback(err)
            else
                @updateConfig()
                callback({result:true})

    # createConfig: Function to create the config from the input JSON
    createConfig: (optionvalue, @body, callback) ->
        config = ''
        for key, val of @body.address
          switch (typeof val)
            when "string"
              config += optionvalue + ' ' + val + "\n"
        callback (config)

    # writeConfig: Function to add/modify configuration and update the dhcp db with id 
    writeConfig: (filename, config, id, body, callback) ->
        console.log 'inside writeConfig' 
        fileops.fileExists filename, (result) ->
           unless result instanceof Error
               fs.createWriteStream(filename, flags: "a").write config
           else
               fileops.createFile filename, (result) ->
                  return result if result instanceof Error

               fileops.updateFile filename, config, (result) ->
                  return result if result instanceof Error
        try
           db.dhcp.set id, body, ->
              console.log "#{id} added to dhcp service configuration"
           callback({result:true})
        catch err
           console.log err
           callback(err)

    # removeConfig: Function to remove configuration with given id
    removeConfig: (id, optionvalue, filename) ->
        entry = db.dhcp.get id
        if !entry
            return { "deleted" : "no data to delete"}
        configList = []
        if optionvalue=='subnet'
          optionvalue = ''
          for key, val of entry
            switch (typeof val)
                when "number", "string"
                   config = key + ' ' + val
                   configList.push(config)
                when "object"
                   if val instanceof Array
                        for i in val
                            config = "#{key} #{i}" if key is "option"
                            configList.push(config)
        else
          configList = entry.address
        newconfig = ''
        fileops.readFile filename, (result) ->
            throw new Error result if result instanceof Error
            for line in result.toString().split '\n'
                j = 0
                flag = 0
                while j < configList.length
                    config = optionvalue
                    config += configList[j]
                    if line==config
                       flag = 1
                       j++
                    else
                       j++
                if flag == 0
                   newconfig += line + '\n'
            try
               db.dhcp.rm id, ->
                  console.log "removed config id: #{id}"
            catch err
               return { "deleted" : "failed"}

            fileops.createFile filename, (result) ->
                return result if result instanceof Error

            fileops.updateFile filename, newconfig, (result) ->
                return result if result instanceof Error
        return { "deleted" : "success"}

    new: (config) ->
        instance = {}
        instance.id = uuid.v4()
        instance.config = config
        return instance

    getConfigEntryByID: (id, callback) ->
        entry = db.dhcp.get id
        instance = {}
        if entry
            instance.id = id
            instance.config = entry
            callback( instance )
        else
            callback ({ "id": "invalid" })


module.exports = interfaces
module.exports.schema = ifaceSchema
module.exports.dhcpSchema = dhcpSchema
module.exports.addrSchema = addrSchema
