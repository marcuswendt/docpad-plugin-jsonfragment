fs = require 'fs'
async = require 'async'
jquery = require 'jquery'
jsdom = require "jsdom"


module.exports = (BasePlugin) ->
    
    class JSONFragment extends BasePlugin

        name: 'jsonfragment'

        config: 
            # wether to use Docpads contentRenderedWithoutLayouts or the contents of a user-specified HTML element
            contentFromDOMQuery: null

        writeAfter: (opts, next) ->
            {collection, templateData} = opts

            async.each collection.models, (model, cbEach) =>
                attributes = model.attributes

                outputJSON = (content) ->
                    data = 
                        meta: model.meta.attributes
                        content: content

                    outputFile = attributes.outPath.replace '.html', '.json'

                    fs.writeFile outputFile, JSON.stringify(data), (err) ->
                        console.log err if(err)
                        cbEach()


                # only parse HTML documents
                return cbEach() unless attributes.outExtension == 'html'

                # get content either from DOM or via Docpad template
                if @config.contentFromDOMQuery?
                    html = attributes.contentRendered
                    return cbEach() unless html?

                    jsdom.env html, (err, window) =>
                        console.log err if err?
                        $ = jquery.create(window)
                        outputJSON $(@config.contentFromDOMQuery).html()
                        
                else
                    html = attributes.contentRenderedWithoutLayouts
                    return cbEach() unless html?
                    outputJSON html

                

            , (err) ->
                console.log "Wrote all JSON fragments."
                next()