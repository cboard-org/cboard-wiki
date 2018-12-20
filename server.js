const dotenv = require('dotenv');
dotenv.config();

const debug = require('debug')('raneto');
const raneto = require('raneto');
const config = require('./config.js');

// We initialize Raneto
// with our configuration object
const app = raneto(config);

const PORT = process.env.PORT || process.env.WIKI_PORT || 3000;

// Load the HTTP Server
const server = app.listen(PORT, function () {
  debug('Raneto Server listening on port ' + server.address().port);
});