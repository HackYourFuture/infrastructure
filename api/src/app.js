
const bodyParser = require('body-parser');
const cors = require('cors');
const express = require('express');

const AuthController = require('./controllers/AuthController');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use((req, res, next) => {
    console.log('--- Debug request ---');
    console.log(req);
    console.log('--- End Debug request ---');
    next();
});

app.get('/auth', AuthController.auth);
app.get('/auth_token', AuthController.authToken);
app.get('/auth/console', AuthController.authCallbackConsole);
app.get('/auth/token', AuthController.authCallbackToken);

module.exports = app;
