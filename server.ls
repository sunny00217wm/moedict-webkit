require(\zappajs) ->
  @get '/:text.png': ->
    @response.type \image/png
    text2png(@params.text.replace(/^[!~:]/, '')).pipe @response
  @get '/:text': ->
    @response.type \text/html
    text = val = (@params.text - /.html$/)
    lang = \a
    if "#val" is /^!/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    err, json <~ require('fs').readFile("#lang/#val.json")
    @render index: { layout: 'layout', text } <<< JSON.parse(json || '{}')

  @view index: ->
    trim = -> (it ? '').replace /[`~]/g ''
    def = ''
    for {d} in (@h || {d:[{f: @t}]})
      for {f} in d => def += f
    def = trim def || (@text + '。')
    doctype 5
    html {prefix:"og: http://ogp.me/ns#"} ->
      meta charset:\utf-8
      meta name:"twitter:card" content:"summary"
      meta name:"twitter:site" content:"@moedict"
      meta name:"twitter:creator" content:"@audreyt"
      meta property:"og:url" content:"https://www.moedict.tw/#{ @text }"
      meta property:"og:image" content:"https://www.moedict.tw/#{ @text.replace(/^[!~:]/, '') }.png"
      meta property:"og:image:type" content:"image/png"
      len = @text.length <? 50
      w = len
      w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
      meta property:"og:image:width" content:"#{ w * 375 }"
      meta property:"og:image:height" content:"#{ w * 375 }"
      meta 'http-equiv':"refresh" content:"0;url=https://www.moedict.tw/##{ @text }" if @t
      t = trim @t
      t += " (#{ @english })" if @english
      t ||= @text
      title "#t - 萌典"
      meta name:"description" content:def
    body -> h1 def unless @t

function text2dim (len)
  len <?= 50
  w = len
  w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
  h = Math.ceil(len / w) <? w
  return [w, h]

function text2png (text)
  text.=slice(0, 50)
  [w, h] = text2dim text.length
  padding = (w - h) / 2

  Canvas = require \canvas
  canvas = new Canvas (w * 375) , (w * 375)

  margin = (w * 15) / 2
  ctx = canvas.getContext('2d');
  ctx.font = '355px TW-MOE-Std-Kai';
  row = 1
  while text.length
    part = text.slice 0, w
    text.=slice w
    for ch, idx in part
      drawBackground ctx, (margin + idx * 360), (10 + (padding + row - 1) * 375), 355
      ctx.fillText ch, (margin + idx * 360), (padding + row - 0.22) * 375
    row++
  return canvas.pngStream!

function drawBackground (ctx, x, y, dim)
  ctx.strokeStyle = \#A33
  ctx.fillStyle = \#F9F6F6
  ctx.beginPath!
  ctx.lineWidth = 8
  ctx.moveTo(x, y)
  ctx.lineTo(x, y+ dim)
  ctx.lineTo(x+ dim, y+ dim)
  ctx.lineTo(x+ dim, y)
  ctx.lineTo(x - (ctx.lineWidth / 2), y)
  ctx.stroke!
  ctx.fill!
  ctx.fillStyle = \#000
  ctx.beginPath!
  ctx.lineWidth = 2
  ctx.moveTo(x, y+ dim / 3)
  ctx.lineTo(x+ dim, y+ dim / 3)
  ctx.moveTo(x, y+ dim / 3 * 2)
  ctx.lineTo(x+ dim, y+ dim / 3 * 2)
  ctx.moveTo(x+ dim / 3, y)
  ctx.lineTo(x+ dim / 3, y+ dim)
  ctx.moveTo(x+ dim / 3 * 2, y)
  ctx.lineTo(x+ dim / 3 * 2, y+ dim)
  ctx.stroke!

/*
require! fs
out = fs.createWriteStream(__dirname + '/tmp/text.png')
stream = canvas.pngStream!
stream.on \data -> out.write it
stream.on \end  -> console.log \OK
*/