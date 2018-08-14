const AWS = require('aws-sdk');
const axios = require('axios');
const oauth = require('oauth').OAuth2;
const octonode = require('octonode');

const AuthClient = new oauth(
    process.env.GITHUB_APP_TOKEN || process.env.TF_VAR_GITHUB_APP_TOKEN,
    process.env.GITHUB_APP_SECRET || process.env.TF_VAR_GITHUB_APP_SECRET,
    'https://github.com/',
    'login/oauth/authorize',
    'login/oauth/access_token'
);

const AUTH_MAP = {
    'teachers': 'arn:aws:iam::786836144270:role/sso_student_role',
    'class8': 'arn:aws:iam::786836144270:role/sso_student_role',
    'class14': 'arn:aws:iam::786836144270:role/sso_student_role',
};

const GITHUB_APP_URL = process.env.GITHUB_APP_URL || process.env.TF_VAR_GITHUB_APP_URL;
const AWS_URL_CONSOLE = 'https://console.aws.amazon.com/';
const AWS_URL_FEDERATE = 'https://signin.aws.amazon.com/federation';

let githubClient;
let ghMe;

const login = (code) => {

    return new Promise((resolve, reject) => {

        AuthClient.getOAuthAccessToken(
            code,
            {
                'grant_type':'client_credentials'
            },
            (err, access_token) => {

                if (err) {
                    reject(err);
                    return;
                }

                resolve(access_token);
            }
        );

    }).then((access_token) => {

        githubClient = octonode.client(access_token);
        ghMe = githubClient.me();

        return new Promise((resolve, reject) => {
            ghMe.teams((err, data) => {

                if (err) {
                    reject(err);
                    return;
                }

                resolve(data);

            });
        })

    }).then((data) => {

        data = data.filter(team => team.organization.name === 'HackYourFuture');

        if (data.length === 0) {

            throw new Error('User is not part of any team');

        }

        return data.reduce((state, next) => state.concat([next.name]), []);

    }).then((teams) => {

        const RoleArn = AUTH_MAP[teams[0]];

        return new Promise((resolve, reject) => {

            ghMe.info((err, { login }) => {

                if (err) {
                    reject(err);
                    return;
                }

                const RoleSessionName = login;

                resolve({ RoleArn, RoleSessionName });

            });

        });

    }).then((RoleParams) => {

        const sts = new AWS.STS();
        return sts.assumeRole(RoleParams).promise();

    });
}

module.exports = {

    auth(request, response) {

        response.writeHead(303, {
            Location: AuthClient.getAuthorizeUrl({
                redirect_uri: `${GITHUB_APP_URL}/auth/console`,
                scope: "user"
            })
        });

        response.end();

    },

    authToken(request, response) {

        response.writeHead(303, {
            Location: AuthClient.getAuthorizeUrl({
                redirect_uri: `${GITHUB_APP_URL}/auth/token`,
                scope: "user"
            })
        });

        response.end();

    },

    authCallbackConsole(request, response) {

        const code = request.query.code;

        login(code).then(({ Credentials }) => {

            const credetials = encodeURIComponent(JSON.stringify({
                sessionId: Credentials.AccessKeyId,
                sessionKey: Credentials.SecretAccessKey,
                sessionToken: Credentials.SessionToken
            }));

            return axios.get(`${AWS_URL_FEDERATE}?Action=getSigninToken&Session=${credetials}`);

        }).then(({ data }) => {

            response.redirect([
                `${AWS_URL_FEDERATE}?Action=login`,
                `Destination=${AWS_URL_CONSOLE}`,
                `SigninToken=${data.SigninToken}`
            ].join('&'));

        }).catch((err) => {

            console.log(err);
            response.status(500).json({ error: 'Something went wrong' });

        });

    },

    authCallbackToken(request, response) {

        const code = request.query.code;

        login(code).then(({ Credentials }) => {

            response.json(Credentials);

        }).catch((err) => {

            console.log(err);
            response.status(500).json({ error: 'Something went wrong' });

        });

    }

}
