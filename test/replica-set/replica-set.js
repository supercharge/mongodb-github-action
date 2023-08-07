'use strict'

const { test } = require('uvu')
const { expect } = require('expect')
const Mongoose = require('mongoose')

const { MONGODB_PORT = 27017, MONGODB_REPLICA_SET = 'mongodb-test-rs' } = process.env

test.before(async () => {
  const connectionString = `mongodb://localhost:${MONGODB_PORT}/test?replicaSet=${MONGODB_REPLICA_SET}`

  console.log('---------------------------------------------------------------------')
  console.log('connecting to MongoDB using connection string -> ' + connectionString)
  console.log('---------------------------------------------------------------------')

  await Mongoose.connect(connectionString, {
    serverSelectionTimeoutMS: 1500
  })
})

test.after(async () => {
  await Mongoose.connection.db.dropDatabase()
  await Mongoose.disconnect()
})

test('queries the replica set status', async () => {
  const db = Mongoose.connection.db.admin()
  const { ok, set } = await db.command({ replSetGetStatus: 1 })

  expect(ok).toBe(1)
  expect(set).toEqual(MONGODB_REPLICA_SET)
})

test('saves a document', async () => {
  const Dog = Mongoose.model('Dog', { name: String })
  const albert = await new Dog({ name: 'Albert' }).save()
  expect(albert.name).toEqual('Albert')
})

test('uses transactions', async () => {
  const Customer = Mongoose.model('Customer', new Mongoose.Schema({ name: String }))
  await Customer.createCollection()

  const session = await Mongoose.startSession()
  session.startTransaction()

  await Customer.create([{ name: 'test-customer' }], { session })

  expect(
    await Customer.findOne({ name: 'test-customer' })
  ).toBeNull()

  expect(
    await Customer.findOne({ name: 'test-customer' }).session(session)
  ).not.toBeNull()

  await session.commitTransaction()

  expect(
    await Customer.findOne({ name: 'test-customer' })
  ).not.toBeNull()
})

test.run()
