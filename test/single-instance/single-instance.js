'use strict'

const { test } = require('uvu')
const expect = require('expect')
const Mongoose = require('mongoose')

test('connects to MongoDB', async () => {
  const connection = await Mongoose.createConnection('mongodb://localhost', {
    user: process.env.MONGODB_USERNAME,
    pass: process.env.MONGODB_PASSWORD,
    dbName: process.env.MONGODB_DB,
    authSource: 'admin'
  }).asPromise()

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
