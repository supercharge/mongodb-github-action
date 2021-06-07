'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { describe, it, afterEach } = (exports.lab = Lab.script())

const { MONGODB_HOST = 'localhost', MONGODB_PORT = 27017 } = process.env

const connectionString = `mongodb://${MONGODB_HOST}:${MONGODB_PORT}/test`

console.log('---------------------------------------------------------------------')
console.log('connecting to MongoDB using connection string -> ' + connectionString)
console.log('---------------------------------------------------------------------')

describe('MongoDB Single Instance ->', () => {
  afterEach(async () => {
    await Mongoose.disconnect()
  })

  it('connects to MongoDB', async () => {
    await expect(
      Mongoose.connect(connectionString, {
        useNewUrlParser: true,
        useUnifiedTopology: true
      })
    ).to.not.reject()
  })

  it('fails to connect to non-existent MongoDB instance', async () => {
    await expect(
      Mongoose.connect('mongodb://localhost:27018/test', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        connectTimeoutMS: 1000,
        serverSelectionTimeoutMS: 1000
      })
    ).to.reject()
  })
})
