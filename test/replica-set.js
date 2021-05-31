'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { MONGODB_PORT = 27017 } = process.env
console.log('------------------------------------------------------');
console.log('MONGODB_PORT -> ' + MONGODB_PORT);
console.log('------------------------------------------------------');

const { describe, it, before, after } = (exports.lab = Lab.script())

const replicaSetName = 'mongodb-test-rs'

describe('MongoDB Replica Set ->', () => {
  before(async () => {
    await Mongoose.connect(`mongodb://localhost:${MONGODB_PORT}/test`, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      replicaSet: replicaSetName,
      serverSelectionTimeoutMS: 1500
    })
  })

  after(async () => {
    await Mongoose.connection.db.dropDatabase()
    await Mongoose.disconnect()
  })

  it('queries the replica set status', async () => {
    const db = Mongoose.connection.db.admin()
    const { ok, set } = await db.command({ replSetGetStatus: 1 })

    expect(ok).to.equal(1)
    expect(set).to.equal(replicaSetName)
  })

  it('saves a document', async () => {
    const Dog = Mongoose.model('Dog', { name: String })
    const albert = await new Dog({ name: 'Albert' }).save()
    expect(albert.name).to.equal('Albert')
  })

  it('uses transactions', async () => {
    const Customer = Mongoose.model('Customer', new Mongoose.Schema({ name: String }))
    await Customer.createCollection()

    const session = await Mongoose.startSession()
    session.startTransaction()

    await Customer.create([{ name: 'test-customer' }], { session })

    expect(
      await Customer.findOne({ name: 'test-customer' })
    ).to.not.exist()

    expect(
      await Customer.findOne({ name: 'test-customer' }).session(session)
    ).to.exist()

    await session.commitTransaction()

    expect(
      await Customer.findOne({ name: 'test-customer' })
    ).to.exist()
  })
})
