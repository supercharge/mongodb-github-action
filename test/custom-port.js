'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')

const { describe, it } = (exports.lab = Lab.script())

describe('MongoDB Instance on Custom Port ->', () => {
  it('connects to MongoDB on custom port 12345', async () => {
    await expect(
      Mongoose.connect('mongodb://localhost:12345')
    ).to.not.reject()
  })
})
