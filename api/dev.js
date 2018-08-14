const { resolve } = require('path');
require('dotenv').config({
    path: resolve(__dirname, '../.env')
});
const app = require('./src/app.js');

app.listen(3003);
