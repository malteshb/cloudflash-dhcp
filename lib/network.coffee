validate = require('json-schema').validate
interfaces = require './interfaces'
@include = ->

    iface = new interfaces
    filename = "/etc/network/interfaces.tmp"
    dhcpfilename = "/etc/udhcpd.conf"
  
    validateIfaceSchema = ->
        console.log 'in validate schema'
        console.log @body
        result = validate @body, interfaces.schema
        console.log result
        return @next new Error "Invalid network interface configuration posting!: #{result.errors}" unless result.valid
        @next()

    # Function to validate the dhcp subnet configuration with dhcpSchema
    validateDhcpSchema = ->
        console.log 'in validateDhcpSchema'
        console.log @body
        result = validate @body, interfaces.dhcpSchema
        console.log result
        return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
        @next()

    # Function to validate the addresses with addrSchema
    validateAddressSchema = ->
        console.log 'in validateAddressSchema'
        console.log @body
        result = validate @body, interfaces.addrSchema
        console.log result
        return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
        @next()


    @post '/network/interfaces/:id', validateIfaceSchema,  ->
        iface.config @params.id, @body, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid network posting! #{res}"
    
    @get '/network/interfaces' : ->
        iface.list (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

    @get "/network/interfaces/:id" : ->
        iface.getInfo @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

    @del "/network/interfaces/:id" : ->
        iface.delete @params.id, (res) =>
            console.log res
            unless res instanceof Error
                @send res
            else
                @next res

    @post '/network/dhcp/subnet', validateDhcpSchema, ->
       instance = iface.new @body
       config = ''
       for key, val of @body
           switch (typeof val)
               when "number", "string"
                   config += key + ' ' + val + "\n"
               when "boolean"
                   config += key + "\n"
               when "object"
                   if val instanceof Array
                        for i in val
                            config += "#{key} #{i}\n" if key is "option"
       body = @body
       iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
            unless res instanceof Error
                @send instance
            else
                @next new Error "Invalid dhcp posting! #{res}"

    @get "/network/dhcp/subnet/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/subnet/:id', ->
        id = @params.id
        optionvalue = 'subnet'
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/router', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option router'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"  

    @get "/network/dhcp/router/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/router/:id', ->
        id = @params.id
        optionvalue = 'option router '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/timesvr', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option timesvr'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/timesvr/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/timesvr/:id', ->
        id = @params.id
        optionvalue = 'option timesvr '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/namesvr', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option namesvr'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/namesvr/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/namesvr/:id', ->
        id = @params.id
        optionvalue = 'option namesvr '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/dns', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option dns'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/dns/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/dns/:id', ->
        id = @params.id
        optionvalue = 'option dns '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result
     
    @post '/network/dhcp/logsvr', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option logsvr'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/logsvr/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/logsvr/:id', ->
        id = @params.id
        optionvalue = 'option logsvr '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/cookiesvr', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option cookiesvr'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/cookiesvr/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/cookiesvr/:id', ->
        id = @params.id
        optionvalue = 'option cookiesvr '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/lprsvr', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option lprsvr'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/lprsvr/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/lprsvr/:id', ->
        id = @params.id
        optionvalue = 'option lprsvr '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/ntpsrv', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option ntpsrv'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/ntpsrv/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/ntpsrv/:id', ->
        id = @params.id
        optionvalue = 'option ntpsrv '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result

    @post '/network/dhcp/wins', validateAddressSchema, ->
       instance = iface.new @body
       optionvalue = 'option wins'
       iface.createConfig optionvalue, @body, (config) =>
            unless config instanceof Error
                body = @body
                iface.writeConfig dhcpfilename, config, instance.id, body, (res) =>
                     unless res instanceof Error
                         @send instance
                     else
                         @next new Error "Invalid dhcp posting! #{res}"
            else
                @next new Error "Invalid config getting! #{config}"

    @get "/network/dhcp/wins/:id" : ->
       iface.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/wins/:id', ->
        id = @params.id
        optionvalue = 'option wins '
        result = iface.removeConfig(id, optionvalue, dhcpfilename)
        @send result



