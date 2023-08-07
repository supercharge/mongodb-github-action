'use strict'

const { test } = require('uvu')
const Mongoose = require('mongoose')

test('connects to MongoDB on custom port 12345', async () => {
  const connection = await Mongoose.createConnection('mongodb://localhost:12345')
  await connection.close()
})

test.run()
