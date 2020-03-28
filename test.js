const mongoose = require('mongoose'),
  { to } = require('await-to-js'),
  { Schema } = mongoose,
  test = require('ava')

const [DB_ADDR, DB_PORT, REPLICA_NAME] = ['localhost', 27017, 'rsTest']

const mongoUri = `mongodb://${DB_ADDR}:${DB_PORT}/test`,
  options = {
    useUnifiedTopology: false,
    useNewUrlParser: true,
    replicaSet: REPLICA_NAME,
  }

test.before('setup', async t => {
  const [err, _res] = await to(mongoose.connect(mongoUri, options))
  t.log(`mongouri "${mongoUri}"`)
  if (err) {
    t.fail(err)
  }
  t.pass('connected')
})

test('replica set', async t => {
  const admin = mongoose.connection.db.admin()
  const [err, res] = await to(admin.command({ replSetGetStatus: 1 }))
  t.is(res.set, REPLICA_NAME, `replica set ${REPLICA_NAME} is set up`)
  t.truthy(res.ok)
})

test('model', async t => {
  const Cat = mongoose.model('Cat', { name: String })
  const kitty = new Cat({ name: 'Zildjian' })
  const [err, res] = await to(kitty.save())
  if (err) t.fail(err)
  t.is(res.name, 'Zildjian', 'model saved')
})

test('transaction', async t => {
  const Customer = mongoose.model('Customer', new Schema({ name: String }))
  await Customer.createCollection()
  const [_err, session] = await to(mongoose.startSession())
  session.startTransaction()
  await Customer.create([{ name: 'Test transaction customer' }], { session })
  const [err1, noCustomer] = await to(
    Customer.findOne({ name: 'Test transaction customer' })
  )
  t.falsy(noCustomer)
  const [err2, customerT] = await to(
    Customer.findOne({ name: 'Test transaction customer' }).session(session)
  )
  t.truthy(customerT)
  await session.commitTransaction()
  const [err3, customer] = await to(
    Customer.findOne({
      name: 'Test transaction customer',
    })
  )
  t.truthy(customer)
})

test.after('teardown', async t => {
  await mongoose.connection.db.dropDatabase()
})
