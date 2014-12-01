request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
format  = require('util').format
yaml    = require 'js-yaml'
fs      = require 'fs'

config = ->
  yaml.safeLoad fs.readFileSync 'config.yml'

getProducts = (config) ->
  url   = format '%s/%s', config.target, config.list.url
  pages = [1..config.list.pages]

  async.each pages, (params, next) ->
    listPageUrl = url.replace 'page', params
    console.log listPageUrl
    request listPageUrl, (error, response, body) ->
      throw error if error

      $ = cheerio.load body
      $('#products > li').each ->
        product_id = $(this).attr 'data-productid'
        getProductDetails config, product_id if product_id
      next

getProductDetails = (config, product_id) ->
  params = [product_id]
  url    = format '%s/%s', config.target, config.detail.url

  async.each params, (params, next) ->
    detail_url = url.replace 'product_id', params
    request detail_url, (err, res, bd) ->
      $n      = cheerio.load bd
      title   = $n(config.detail.title).text()
      desc    = $n(config.detail.desc).text()
      link    = $n(config.detail.link).val()
      picture = format '%s%s', config.target, $n(config.detail.picture).attr 'href'
      next

config = config()
getProducts config