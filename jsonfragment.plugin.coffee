fs = require 'fs'
async = require 'async'

module.exports = (BasePlugin) ->
    
    class JSONFragment extends BasePlugin

        name: 'jsonfragment'

        writeAfter: (opts, next) ->
            {collection, templateData} = opts

            async.each collection.models, (model, cbEach) ->
                attributes = model.attributes
                essentialContent = attributes.contentRenderedWithoutLayouts

                if attributes.isDocument and essentialContent? and attributes.outExtension == 'html'
                    data = 
                        meta: model.meta.attributes
                        content: essentialContent

                    outputFile = attributes.outPath.replace '.html', '.json'

                    fs.writeFile outputFile, JSON.stringify(data), (err) ->
                        console.log err if(err)
                        cbEach()

                # continue for all non-html files
                else
                    cbEach()

            , (err) ->
                console.log "finished writing .json fragments"
                next()