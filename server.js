const dotenv = require('dotenv');
dotenv.config();

const debug = require('debug')('raneto');
const raneto = require('raneto');
const config = require('./config.js');

// We initialize Raneto
// with our configuration object
const app = raneto(config);

// Load the HTTP Server
const server = app.listen(app.get('port'), function () {
  debug('Raneto Server listening on port ' + server.address().port);
});