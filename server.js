const express = require('express')
const app = express()

let keys = []

app.get('/api/create', (req, res) => {
  const { userid } = req.query

  if (!userid) return res.json({ error: "no userid" })

  const key = "HXH-" + Math.random().toString(36).substring(2,8).toUpperCase()

  keys.push({ userId: userid, key: key, time: Date.now() })

  res.json({ key: key })
})

app.get('/api/validate', (req, res) => {
  const { key, userid } = req.query

  const data = keys.find(k => k.key == key && k.userId == userid)

  if (!data) return res.json({ valid: false })

  if (Date.now() - data.time > 86400000) return res.json({ valid: false })

  res.json({ valid: true })
})

app.listen(3000)
