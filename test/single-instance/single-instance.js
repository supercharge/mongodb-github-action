'use strict'

const { test } = require('uvu')
const { expect } = require('expect')
const Mongoose = require('mongoose')

const { MONGODB_USERNAME, MONGODB_PASSWORD, MONGODB_DB } = process.env

test('connects to MongoDB', async () => {
  const connection = await Mongoose.createConnection('mongodb://localhost', {
    user: MONGODB_USERNAME,
    pass: MONGODB_PASSWORD,
    dbName: MONGODB_DB,
    authSource: MONGODB_USERNAME && MONGODB_PASSWORD ? 'admin' : undefined
  })

  await connection.close()
})

test('fails to connect to non-existent MongoDB instance', async () => {
  await expect(
    Mongoose.connect('mongodb://localhost:27018', {
      connectTimeoutMS: 1000,
      serverSelectionTimeoutMS: 1000
    })
  ).rejects.toThrow()
})

test.run()
