'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { describe, it } = (exports.lab = Lab.script())

const { MONGODB_HOST = 'localhost', MONGODB_PORT = 27017 } = process.env

describe('MongoDB Single Instance ->', () => {
  const connectionString = `mongodb://${MONGODB_HOST}:${MONGODB_PORT}/test`

  console.log('---------------------------------------------------------------------')
  console.log('connecting to MongoDB using connection string -> ' + connectionString)
  console.log('---------------------------------------------------------------------')

  it('connects to MongoDB', async () => {
    await expect(async () => {
      const db = await Mongoose.connect(connectionString, {
        useNewUrlParser: true,
        useUnifiedTopology: true
      })

      await db.disconnect()
    }).to.not.reject()
  })

  it('fails to connect to non-existent MongoDB instance', async () => {
    await expect(async () => {
      await Mongoose.connect('mongodb://localhost:27018', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        connectTimeoutMS: 1000,
        serverSelectionTimeoutMS: 1000
      })
    }).to.reject()
  })
})
