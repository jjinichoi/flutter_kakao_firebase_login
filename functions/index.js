const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const admin = require("firebase-admin");
const auth = require("firebase-auth");

var serviceAccount = require("./logintest-f48d8-firebase-adminsdk-3hose-e459a18847.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.createCustomToken = onRequest(async (request, response) => {
  const user = request.body;

  const uid = `kakao:${user.uid}`;
  const updateParams = {
    email: user.email,
    photoURL: user.photoURL,
    displayName: user.displayName,
  };

  try {
    await admin.auth().updateUser(uid, updateParams);
  } catch (e) {
    updateParams["uid"] = uid;
    await admin.auth().createUser(updateParams);
  }

  const token = await admin.auth().createCustomToken(uid);

  response.send(token);
});
