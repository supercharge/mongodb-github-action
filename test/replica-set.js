'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { describe, it, before } = (exports.lab = Lab.script())

const replicaSetName = 'mongodb-test-rs'

describe('MongoDB Replica Set ->', () => {
  before(async () => {
    await expect(
      Mongoose.connect('mongodb://localhost:27017/test', {
        useNewUrlParser: true,
        useUnifiedTopology: false,
        replicaSet: replicaSetName
      })
    ).to.not.reject()
  })

  it('connects to a replica set', async () => {
    const db = Mongoose.connection.db.admin()
    const result = await db.command({ replSetGetStatus: 1 })

    expect(result.ok).to.equal(1)
    expect(result.set).to.equal(`replica set ${replicaSetName} is set up`)
  })

  it('fails to connect to non-existent replica set', async () => {
    await expect(
      Mongoose.connect('mongodb://localhost:27017', {
        useNewUrlParser: true,
        useUnifiedTopology: false,
        replicaSet: 'non-existent-replica-set',
        connectTimeoutMS: 1000,
        serverSelectionTimeoutMS: 1000
      })
    ).to.reject()
  })
})
