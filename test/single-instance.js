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
        useUnifiedTopology: true
      })
    ).to.not.reject()
  })
})
