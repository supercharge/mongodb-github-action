const core = require('@actions/core')
const { exec } = require('@actions/exec')

async function run () {
  await exec(`docker run --name mongodb --publish 27017:27017 --detach mongo:${core.getInput('mongodb-version')}`)
}

run()
