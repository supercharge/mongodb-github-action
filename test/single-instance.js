'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { describe, it } = (exports.lab = Lab.script())

describe('MongoDB Single Instance ->', () => {
  it('connects to MongoDB', async () => {
    await expect(
      Mongoose.connect('mongodb://localhost', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        user: process.env.MONGODB_USERNAME,
        pass: process.env.MONGODB_PASSWORD,
        dbName: process.env.MONGODB_DB,
        authSource: 'admin'
      })
    ).to.not.reject()
  })

  it('fails to connect to non-existent MongoDB instance', async () => {
    await expect(
      Mongoose.connect('mongodb://localhost:27018', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        connectTimeoutMS: 1000,
        serverSelectionTimeoutMS: 1000
      })
    ).to.reject()
  })
})
