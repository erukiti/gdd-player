#! /usr/bin/env coffee

http = require 'http'
https = require 'https'

id = process.env['ID']
password = process.env['PASSWORD']

reCookie = /^nicosid=([0-9]+\.[0-9]+)/

login = new Promise (resolv, reject) =>
	opt = {
		hostname: 'secure.nicovideo.jp'
		port: 443
		path: '/secure/login?site=niconico'
		method: 'POST'
	}
	req = https.request opt, (res) =>
		console.dir res

		# console.dir res.statusCode
		# console.dir res.headers
		# console.dir res.headers['set-cookie']
		matched = reCookie.exec(res.headers['set-cookie'])
		if matched
			resolv {nicosid: matched[1]}
	req.write "mail=#{id}&password=#{password}"
	req.end()

watch = (agent) =>
	new Promise (resolv, reject) =>
		opt = {
			hostname: 'www.nicovideo.jp'
			port: 80
			path: "/watch/sm27341702"
			method: 'GET'
			headers:
				cookies: "nicosid=#{agent.nicosid}"
		}
		req = http.request opt, (res) =>
			console.dir res.statusCode
			console.dir res.headers
			# console.dir res.statusCode
			# console.dir res.headers
			# res.on 'data', (data) =>
				# console.log data.toString()
			resolv(agent)
		req.end()

getFlv = (agent) =>
	new Promise (resolv, reject) =>
		opt = {
			hostname: 'flapi.nicovideo.jp'
			port: 80
			path: "/api/getflv?v=sm27341702"
			method: 'GET'
			headers:
				cookies: "nicosid=#{agent.nicosid}"
		}
		req = http.request opt, (res) =>
			res.on 'data', (data) =>
				console.log data.toString()
			resolv(agent)
		req.end()



login
# .then (agent) =>
# 	watch(agent)
# .then (agent) =>
# 	getFlv(agent)
.then =>
	console.dir 'done'
.catch (err) =>
	console.dir err


