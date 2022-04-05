const axios = require('axios');
const releaseData = require('./pr-list.json');
const {setTimeout} = require ('timers/promises');

const semverMinor = new Object();
const semverMajor = new Object();
const nodeApiSemverMajor = new Object();
const notable = new Object();

async function generate() {
  for (const [commit, prInfo] of Object.entries(releaseData)) {
    if ((releaseData[commit].length === 1) && (Number.isInteger(releaseData[commit][0]))) {
      const prURL = `https://api.github.com/repos/nodejs/node/issues/${releaseData[commit][0]}/labels`;
      result = await axios.get(prURL, { 
        auth: {
          username: 'mhdawson',
          password: `${process.env['TOKEN']}`
        }
      });
      labels = result.data;

      for (let i=0; i< labels.length; i++) {
        if(labels[i].name === "semver-major") {
          semverMajor[commit] = prInfo;
        } else if(labels[i].name === "semver-minor") {
          semverMinor[commit] = prInfo;
        } else if(labels[i].name === "node-api-semver-minor") {
          nodeApiSemverMajor[commit] = prInfo;
        }
        if(labels[i].name === "notable-change") {
          notable[commit] = prInfo;
        }
      }
    }
    await setTimeout(750);
  }
  for (const [commit, prInfo] of Object.entries(semverMajor)) {
    console.log(`MAJOR ${commit}`);
  };
  for (const [commit, prInfo] of Object.entries(nodeApiSemverMajor)) {
    console.log(`NODE-API_MAJOR ${commit}`);
  }
  for (const [commit, prInfo] of Object.entries(semverMinor)) {
    console.log(`MINOR ${commit}`);
  }
  for (const [commit, prInfo] of Object.entries(notable)) {
    console.log(`NOTABLE ${commit}`);
  }
}

generate();
